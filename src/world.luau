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

const ROOT_ARCHETYPE_KEY = ''

-- Archetype Migration

const function migrate(world: World, entity: Entity, newArchetype: Archetype, components: { Component })
	const record = recordStore.get(world.records, entity)

	const oldArchetype = record.archetype
	const values = {}

	for name in oldArchetype.componentSet do
		values[name] = archetype.getComponentValue(oldArchetype, entity, name)
	end

	const movedEntity, movedIndex = archetype.removeEntity(oldArchetype, entity)
	if movedEntity then
		const movedRecord = recordStore.get(world.records, movedEntity)
		movedRecord.index = movedIndex :: number
	end

	const newEntityIndex = archetype.addEntity(newArchetype, entity)
	record.archetype = newArchetype
	record.index = newEntityIndex

	for name, value in values do
		const column = newArchetype.columns[name]

		if column then
			column[newEntityIndex] = value
		end
	end

	for _, component in components do
		if values[component.name] ~= nil then
			continue
		end

		archetype.insertComponent(newArchetype, entity, component)
	end
end

-- Components

const function insert(world: World, entity: Entity, ...)
	const componentsToInsert: { Component } = { ... }

	const record = recordStore.get(world.records, entity)
	const currentArchetype = record.archetype

	for name in currentArchetype.componentSet do
		local alreadyRequested = false

		for _, component in componentsToInsert do
			if component.name ~= name then
				continue
			end

			alreadyRequested = true

			break
		end

		if not alreadyRequested then
			componentsToInsert[#componentsToInsert + 1] = {
				name = name,
				value = archetype.getComponentValue(currentArchetype, entity, name),
			}
		end
	end

	const newArchetype = archetypeStore.getOrCreate(world.archetypes, componentsToInsert)
	migrate(world, entity, newArchetype, componentsToInsert)
end

const function remove(world: World, entity: Entity, ...: Component)
	const componentsToRemove: { Component } = { ... }

	const record = recordStore.get(world.records, entity)
	const currentArchetype = record.archetype

	const remainingComponents: { Component } = {}

	for name in currentArchetype.componentSet do
		local shouldRemove = false

		for _, component in componentsToRemove do
			if component.name ~= name then
				continue
			end

			shouldRemove = true

			break
		end

		if not shouldRemove then
			remainingComponents[#remainingComponents + 1] = {
				name = name,
				value = archetype.getComponentValue(currentArchetype, entity, name),
			}
		end
	end

	const newArchetype = archetypeStore.getOrCreate(world.archetypes, remainingComponents)

	migrate(world, entity, newArchetype, remainingComponents)
end

const function has(world: World, entity: Entity, ...: Component): boolean
	const record = recordStore.get(world.records, entity)

	if not record then
		return false
	end

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

	if not record then
		return
	end

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
	if not record then
		return
	end

	archetype.removeEntity(record.archetype, entity)
	recordStore.remove(world.records, entity)
end

const function clear(world: World)
	table.clear(world.records.records)
	table.clear(world.archetypes.archetypes)
	table.clear(world.archetypes.componentArchetypes)
	table.clear(world.rootArchetype.entities)
	table.clear(world.rootArchetype.entityIndex)

	for _, column in world.rootArchetype.columns do
		table.clear(column)
	end

	world.entities.nextEntityId = 0
	world.archetypes.archetypes[ROOT_ARCHETYPE_KEY] = world.rootArchetype
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
