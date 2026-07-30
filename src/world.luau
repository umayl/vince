--!strict

const entityStore = require './entityStore'
const recordStore = require './recordStore'
const archetypeStore = require './archetypeStore'

export type World = {
	entities: entityStore.EntityStore,
	archetypes: archetypeStore.ArchetypeStore,
	records: recordStore.RecordStore,
}

const function world(): World
	const entities = entityStore.create()
	const archetypes = archetypeStore.create()
	const records = recordStore.create()

	return {
		entities = entities,
		archetypes = archetypes,
		records = records,
	}
end

return world
