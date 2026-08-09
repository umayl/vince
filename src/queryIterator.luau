--!strict

local archetype = require './archetype'
local componentAccessor = require './componentAccessor'
local queryMatcher = require './queryMatcher'
local types = require './types'

type Entity = types.Entity
type Component = types.Component
type Archetype = types.Archetype
type World = types.World

local function queryIterator<A, B, C, D, E, F, G>(
	world: World,
	includedComponents: { Component },
	excludedComponents: { Component }
): types.QueryIterator<A, B, C, D, E, F, G>
	if #includedComponents == 0 then
		local records = world.records.records
		local nextEntity: Entity?

		return function()
			while true do
				local entity = next(records, nextEntity)
				nextEntity = entity

				if not entity then
					return
				end

				local record = records[entity]
				local currentArchetype = record.archetype

				local excluded = false

				for _, component in excludedComponents do
					if currentArchetype.componentSet[component.name] then
						excluded = true

						break
					end
				end

				if not excluded then
					return entity
				end
			end
		end :: any
	end

	local matchingArchetypes = queryMatcher(world, includedComponents, excludedComponents)

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

			local currentEntity = currentEntities[entityIndex]

			if currentEntity and currentArchetype then
				local row = currentArchetype.entityIndex[currentEntity]
				entityIndex += 1

				local accessors = table.create(#includedComponents)

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
