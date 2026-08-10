--!strict

const record = require './record'
const types = require './types'

type Entity = types.Entity
type Archetype = types.Archetype
type Record = types.Record
type RecordStore = types.RecordStore

const function create(): RecordStore
	return {
		records = {},
	}
end

const function insert(recordStore: RecordStore, entity: Entity, archetype: Archetype, index: number): Record
	const newRecord = record(archetype, index)
	recordStore.records[entity] = newRecord

	return newRecord
end

const function get(recordStore: RecordStore, entity: Entity): Record
	return recordStore.records[entity]
end

const function remove(recordStore: RecordStore, entity: Entity)
	recordStore.records[entity] = nil
end

return table.freeze {
	create = create,

	insert = insert,
	get = get,
	remove = remove,
}
