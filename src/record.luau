--!strict

local types = require './types'

local function record(archetype: types.Archetype, index: number): types.Record
	return {
		archetype = archetype,
		index = index,
	}
end

return record
