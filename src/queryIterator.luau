--!strict

const archetype = require './archetype'
const types = require './types'
const queryMatcher = require './queryMatcher'
const componentAccessor = require './componentAccessor'

type Entity = types.Entity
type Component = types.Component
type Archetype = types.Archetype
type World = types.World

const function queryIterator<A, B, C, D, E, F, G>(
	world: World,
	includedComponents: { Component },
	excludedComponents: { Component }
): types.QueryIterator<A, B, C, D, E, F, G>
	const matchingArchetypes = queryMatcher(world, includedComponents, excludedComponents)

	local archetypeIndex = 1
	local entityIndex = 1

	local currentArchetype: Archetype?
	local currentEntities: { Entity }?

	return function()
		while true do
			if not currentArchetype then
				currentArchetype = matchingArchetypes[archetypeIndex]

				if not currentArchetype then
					return
				end

				currentEntities = archetype.getEntities(currentArchetype)
			end

			if not currentEntities then
				continue
			end

			const currentEntity = currentEntities[entityIndex]

			if currentEntity and currentArchetype then
				const row = currentArchetype.entityIndex[currentEntity]
				entityIndex += 1

				const accessors = table.create(#includedComponents)
				for i, component in includedComponents do
					accessors[i] = componentAccessor(currentArchetype.columns[component.name], row)
				end

				return currentEntity, table.unpack(accessors)
			end

			archetypeIndex += 1
			entityIndex = 1
			currentArchetype = nil
			currentEntities = nil
		end
	end :: any
end

return queryIterator
