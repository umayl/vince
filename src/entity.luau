--!strict

const world = require './world'
const entityStore = require './entityStore'
const types = require './types'
const archetype = require './archetype'
const recordStore = require './recordStore'

export type Entity = types.Entity

const function entity(world: world.World)
	const records = world.records
	const rootArchetype = world.rootArchetype

	const newEntity = entityStore.allocate(world.entities)

	local index = archetype.addEntity(rootArchetype, newEntity)
	recordStore.insert(records, newEntity, rootArchetype, index)

	return newEntity
end

return entity
