--!strict

const archetype = require './archetype'

type Archetype = archetype.Archetype

export type Record = {
	archetype: Archetype,
	index: number,
}

const function record(archetype: Archetype, index: number): Record
	return {
		archetype = archetype,
		index = index,
	}
end

return record
