--!strict

local types = require './types'

type EntityStore = types.EntityStore

local function create(): EntityStore
	return {
		nextEntityId = 0,
	}
end

local function allocate(store: EntityStore)
	local id = store.nextEntityId
	store.nextEntityId += 1

	return id
end

return table.freeze {
	create = create,

	allocate = allocate,
}
