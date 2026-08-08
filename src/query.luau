--!strict

const types = require './types'
const queryIterator = require './queryIterator'

type Component<T = unknown> = types.Component<T>
type World = types.World

const function createQuery<A, B, C, D, E, F, G>(world: World, inclued: { Component }, excluded: { Component })
	const self = {}

	function self.with(...: Component)
		const newIncluded = table.clone(inclued)

		for _, component in { ... } do
			newIncluded[#newIncluded + 1] = component
		end

		return createQuery(world, newIncluded, excluded)
	end

	function self.without(...: Component)
		const newExcluded = table.clone(excluded)

		for _, component in { ... } do
			newExcluded[#newExcluded + 1] = component
		end

		return createQuery(world, inclued, newExcluded)
	end

	function self.iter(): types.QueryIterator<A, B, C, D, E, F, G>
		return queryIterator(world, inclued, excluded)
	end

	return table.freeze(self)
end

const function query(world: World, ...: Component)
	return createQuery(world, { ... }, {})
end

return query
