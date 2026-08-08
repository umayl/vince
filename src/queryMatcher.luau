--!strict

local archetype = require './archetype'
local archetypeStore = require './archetypeStore'
local types = require './types'

type Component<T = unknown> = types.Component<T>
type World = types.World

local function queryMatcher(world: World, targetComponents: { Component }, excludedComponents: { Component })
	local requiredCount = #targetComponents
	local counts = {}

	for _, component in targetComponents do
		local archetypes = archetypeStore.getComponentArchetypes(world.archetypes, component.name)
		if not archetypes then
			continue
		end

		for _, archetype in archetypes do
			counts[archetype] = (counts[archetype] or 0) + 1
		end
	end

	local matching = {}

	for archetypeCandidate, count in counts do
		if count ~= requiredCount then
			continue
		end

		local excluded = false

		for _, component in excludedComponents do
			if not archetype.hasComponent(archetypeCandidate, component) then
				continue
			end

			excluded = true

			break
		end

		if not excluded then
			table.insert(matching, archetypeCandidate)
		end
	end

	return matching
end

return queryMatcher
