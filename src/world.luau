--!strict

const entityStore = require './entityStore'
const recordStore = require './recordStore'
const archetypeStore = require './archetypeStore'
const types = require './types'
const archetype = require './archetype'
const query = require './query'
const componentAccessor = require './componentAccessor'

type Entity = types.Entity
type Component<T = unknown> = types.Component
type Archetype = types.Archetype
type World = types.World

-- Components

const function findComponentByName(components: { Component }, name: string): Component?
	for _, component in components do
		if component.name ~= name then
			continue
		end

		return component
	end

	return
end

-- Archetype Migration

const function migrate(world: World, entity: Entity, newArchetype: Archetype, newComponents: { Component })
	const record = recordStore.get(world.records, entity)
	archetype.removeEntity(record.archetype, entity)

	const newEntityIndex = archetype.addEntity(newArchetype, entity)
	record.archetype = newArchetype
	record.index = newEntityIndex

	for _, component in newComponents do
		archetype.insertComponent(newArchetype, entity, component)
	end
end

-- Components

const function insert(world: World, entity: Entity, ...)
	const componentsToInsert = { ... }

	const record = recordStore.get(world.records, entity)
	const currentArchetype = record.archetype

	for _, component in archetype.getComponents(currentArchetype, entity) do
		if findComponentByName(componentsToInsert, component.name) then
			continue
		end

		componentsToInsert[#componentsToInsert + 1] = component
	end

	const newArchetype = archetypeStore.getOrCreate(world.archetypes, componentsToInsert)

	migrate(world, entity, newArchetype, componentsToInsert)
end

const function remove(world: World, entity: Entity, ...: Component)
	const componentsToRemove = { ... }

	const record = recordStore.get(world.records, entity)
	const currentArchetype = record.archetype

	const remainingComponents = {}

	for _, component in archetype.getComponents(currentArchetype, entity) do
		if findComponentByName(componentsToRemove, component.name) then
			continue
		end

		remainingComponents[#remainingComponents + 1] = component
	end

	const newArchetype = archetypeStore.getOrCreate(world.archetypes, remainingComponents)

	migrate(world, entity, newArchetype, remainingComponents)
end

const function has(world: World, entity: Entity, ...: Component): boolean
	const record = recordStore.get(world.records, entity)
	const currentArchetype = record.archetype

	for _, component in { ... } do
		if not archetype.hasComponent(currentArchetype, component) then
			return false
		end
	end

	return true
end

const function get<T>(world: World, entity: Entity, component: Component<T>): types.ComponentAccessor<T>?
	const record = recordStore.get(world.records, entity)
	const currentArchetype = record.archetype

	const column = currentArchetype.columns[component.name]
	if not column then
		return
	end

	return componentAccessor(column, record.index)
end

-- Entity Lifecycle

const function spawn(world: World, entity: Entity)
	const records = world.records
	const rootArchetype = world.rootArchetype

	const newEntity = entityStore.allocate(world.entities)

	const newEntityIndex = archetype.addEntity(rootArchetype, newEntity)
	recordStore.insert(records, newEntity, rootArchetype, newEntityIndex)

	return newEntity
end

const function despawn(world: World, entity: Entity)
	const record = recordStore.get(world.records, entity)

	archetype.removeEntity(record.archetype, entity)

	recordStore.remove(world.records, entity)
end

const function clear(world: World)
	table.clear(world.records.records)

	table.clear(world.archetypes.archetypes)
	table.clear(world.archetypes.componentArchetypes)

	world.entities.nextEntityId = 0

	world.rootArchetype = archetype.create {}
end

-- World

const function world(): World
	const entities = entityStore.create()
	const archetypes = archetypeStore.create()
	const records = recordStore.create()

	const rootArchetype = archetype.create {}

	return table.freeze {
		entities = entities,
		archetypes = archetypes,
		records = records,

		rootArchetype = rootArchetype,

		-- Entity lifecycle
		spawn = spawn,
		despawn = despawn,
		clear = clear,

		-- Components
		insert = insert,
		remove = remove,
		has = has,
		get = get,

		-- Queries
		query = query,
	} :: any
end

return world
