--!strict

local queryIterator = require './queryIterator'
local types = require './types'

type Component<T = unknown> = types.Component<T>
type World = types.World

local function createQuery<A, B, C, D, E, F, G>(world: World, included: { Component }, excluded: { Component })
	local self = {}

	function self.with(...: Component)
		local newIncluded = table.clone(included)

		for _, component in { ... } do
			newIncluded[#newIncluded + 1] = component
		end

		return createQuery(world, newIncluded, excluded)
	end

	function self.without(...: Component)
		local newExcluded = table.clone(excluded)

		for _, component in { ... } do
			newExcluded[#newExcluded + 1] = component
		end

		return createQuery(world, included, newExcluded)
	end

	function self.iter(): types.QueryIterator<A, B, C, D, E, F, G>
		return queryIterator(world, included, excluded)
	end

	return table.freeze(self)
end

local function query(world: World, ...: Component)
	return createQuery(world, { ... }, {})
end

return query
