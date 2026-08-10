--!strict

const types = require './types'

type EntityStore = types.EntityStore

const function create(): EntityStore
	return {
		nextEntityId = 0,
	}
end

const function allocate(store: EntityStore)
	const id = store.nextEntityId
	store.nextEntityId += 1

	return id
end

return table.freeze {
	create = create,

	allocate = allocate,
}
