--!strict

local record = require './record'
local types = require './types'

type Entity = types.Entity
type Archetype = types.Archetype
type Record = types.Record
type RecordStore = types.RecordStore

local function create(): RecordStore
	return {
		records = {},
	}
end

local function insert(recordStore: RecordStore, entity: Entity, archetype: Archetype, index: number): Record
	local newRecord = record(archetype, index)
	recordStore.records[entity] = newRecord

	return newRecord
end

local function get(recordStore: RecordStore, entity: Entity): Record
	return recordStore.records[entity]
end

local function remove(recordStore: RecordStore, entity: Entity)
	recordStore.records[entity] = nil
end

return table.freeze {
	create = create,

	insert = insert,
	get = get,
	remove = remove,
}
