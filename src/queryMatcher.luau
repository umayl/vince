--!strict

const archetypeStore = require './archetypeStore'
const archetype = require './archetype'
const types = require './types'

type Component<T = unknown> = types.Component<T>
type World = types.World

const function queryMatcher(world: World, targetComponents: { Component }, excludedComponents: { Component })
	const requiredCount = #targetComponents
	const counts = {}

	for _, component in targetComponents do
		const archetypes = archetypeStore.getComponentArchetypes(world.archetypes, component.name)
		if not archetypes then
			continue
		end

		for _, archetype in archetypes do
			counts[archetype] = (counts[archetype] or 0) + 1
		end
	end

	const matching = {}

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
