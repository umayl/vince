--!strict

const record = require './record'
const archetype = require './archetype'
const types = require './types'

type Entity = types.Entity
type Archetype = archetype.Archetype
type Record = record.Record

export type RecordStore = {
	records: { [Entity]: Record },
}

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

const function get(recordStore: RecordStore, entity: Entity): Record?
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
