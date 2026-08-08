--!strict

const types = require './types'

const function record(archetype: types.Archetype, index: number): types.Record
	return {
		archetype = archetype,
		index = index,
	}
end

return record
