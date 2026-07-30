--!strict

const entityStore = require './entityStore'
const recordStore = require './recordStore'
const archetypeStore = require './archetypeStore'
const types = require './types'
const archetype = require './archetype'
const component = require './component'

type Entity = types.Entity
type Component<T = unknown> = component.Component<T>
type Archetype = archetype.Archetype

export type World = {
	entities: entityStore.EntityStore,
	archetypes: archetypeStore.ArchetypeStore,
	records: recordStore.RecordStore,

	rootArchetype: Archetype,

	migrate: (self: World, entity: Entity, newArchetype: Archetype, components: { Component }) -> (),
	insert: (self: World, entity: Entity, ...Component) -> (),
}

const function findComponentByName(components: { Component }, name: string): Component?
	for _, component in components do
		if component.name ~= name then
			continue
		end

		return component
	end

	return
end

const function migrate(world: World, entity: Entity, newArchetype: Archetype, components: { Component })
	const record = recordStore.get(world.records, entity)
	const recordArchetype = record.archetype
	archetype.removeEntity(recordArchetype, entity)

	const newIndex = archetype.addEntity(newArchetype, entity)
	record.archetype = newArchetype
	record.index = newIndex

	for _, component in components do
		archetype.insertComponent(newArchetype, entity, component)
	end
end

const function insert(world: World, entity: Entity, ...)
	const componentsToInsert = { ... }

	const record = recordStore.get(world.records, entity)
	const recordArchetype = record.archetype

	const components = archetype.getComponents(recordArchetype, entity)
	for _, component in components do
		if findComponentByName(componentsToInsert, component.name) then
			continue
		end

		componentsToInsert[#componentsToInsert + 1] = component
	end

	const newArchetype = archetypeStore.getOrCreate(world.archetypes, componentsToInsert)
	migrate(world, entity, newArchetype, componentsToInsert)
end

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

		migrate = migrate,
		insert = insert,
	}
end

return world
