--!strict

const world = require './world'
const component = require './component'
const archetypeStore = require './archetypeStore'
const archetype = require './archetype'
const types = require './types'

type Entity = types.Entity
type World = world.World
type Component<T = unknown> = component.Component<T>
type Archetype = archetype.Archetype

type QueryIterator<A = unknown, B = unknown, C = unknown, D = unknown, E = unknown, F = unknown, G = unknown> = (
) -> (
	Entity,
	QueryAccessor<A>,
	QueryAccessor<B>,
	QueryAccessor<C>,
	QueryAccessor<D>,
	QueryAccessor<E>,
	QueryAccessor<F>,
	QueryAccessor<G>
)

export type QueryAccessor<T = unknown> = (...T?) -> T?

export type Query<A = any, B = any, C = any, D = any, E = any, F = any, G = any> = typeof(setmetatable(
	{} :: {
		next: (self: Query<A, B, C, D, E, F, G>) -> QueryIterator<A, B, C, D, E, F, G>,
		without: (self: Query<A, B, C, D, E, F, G>, ...Component) -> Query<A, B, C, D, E, F, G>,
	},
	{} :: {
		__iter: (self: Query<A, B, C, D, E, F, G>) -> QueryIterator<A, B, C, D, E, F, G>,
		__call: (self: Query<A, B, C, D, E, F, G>) -> QueryIterator<A, B, C, D, E, F, G>,
	}
))

const function createAccessor(column: { any }, index: number): QueryAccessor<any>
	return function(...)
		if select('#', ...) == 0 then
			return column[index]
		end

		column[index] = select(1, ...)

		return
	end
end

const function getMatchingArchetypes(world: World, targetComponents: { Component }, excludedComponents: { Component })
	const requiredCount = #targetComponents
	const counts = {}

	for _, component in ipairs(targetComponents) do
		const archetypes = archetypeStore.getComponentArchetypes(world.archetypes, component.name)

		if archetypes then
			for _, archetype in ipairs(archetypes) do
				counts[archetype] = (counts[archetype] or 0) + 1
			end
		end
	end

	const matching = {}

	for archetypeCandidate, count in pairs(counts) do
		if count ~= requiredCount then
			continue
		end

		local excluded = false

		for _, component in ipairs(excludedComponents) do
			if archetype.hasComponent(archetypeCandidate, component) then
				excluded = true

				break
			end
		end

		if not excluded then
			table.insert(matching, archetypeCandidate)
		end
	end

	return matching
end

const function createQueryIterator(world: World, targetComponents: { Component }, excludedComponents: { Component })
	const matchingArchetypes = getMatchingArchetypes(world, targetComponents, excludedComponents)

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

			const entity = currentEntities[entityIndex]
			if entity and currentArchetype then
				const row = currentArchetype.entityIndex[entity]

				entityIndex += 1

				const accessors = table.create(#targetComponents)

				for i, component in ipairs(targetComponents) do
					accessors[i] = createAccessor(currentArchetype.columns[component.name], row)
				end

				return entity, table.unpack(accessors)
			end

			archetypeIndex += 1
			entityIndex = 1
			currentArchetype = nil
			currentEntities = nil
		end
	end
end

const function createQuery(world: World, targetComponents: { Component }, excludedComponents: { Component }): Query
	const self = {}

	function self.next()
		return createQueryIterator(world, targetComponents, excludedComponents)
	end

	function self.without(...: Component): Query
		const newExcluded = table.clone(excludedComponents)

		for _, component in ipairs { ... } do
			newExcluded[#newExcluded + 1] = component
		end

		return createQuery(world, targetComponents, newExcluded)
	end

	return table.freeze(setmetatable(
		table.freeze(self),
		table.freeze {
			__iter = function()
				return self.next()
			end,

			__call = function()
				return self.next()
			end,
		}
	)) :: any
end

const function query(world: World, ...: Component): Query
	return createQuery(world, { ... }, {})
end

return query
