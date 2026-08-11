--!strict

local componentAccessor = require './componentAccessor'
local queryIterator = require './queryIterator'
local types = require './types'

type Entity = types.Entity
type Component = types.Component
type Archetype = types.Archetype
type World = types.World
type HookDisconnect = types.HookDisconnect

local function matches(archetype: Archetype, included: { Component }, excluded: { Component }): boolean
	for _, component in included do
		if not archetype.componentSet[component.name] then
			return false
		end
	end

	for _, component in excluded do
		if archetype.componentSet[component.name] then
			return false
		end
	end

	return true
end

local function createQuery<A, B, C, D, E, F, G>(
	world: World,
	included: { Component },
	excluded: { Component }
): types.Query<A, B, C, D, E, F, G>
	local enterHooks: { types.QueryEnterHook<A, B, C, D, E, F, G> } = {}
	local exitHooks: { types.QueryExitHook } = {}

	local isObserving = false

	local self: any = {}

	local function updateObservation()
		local shouldObserve = #enterHooks > 0 or #exitHooks > 0
		if shouldObserve and not isObserving then
			world:_observeQuery(self)
			isObserving = true
		elseif not shouldObserve and isObserving then
			world:_unobserveQuery(self)
			isObserving = false
		end
	end

	function self:iter(): types.QueryIterator<A, B, C, D, E, F, G>
		return queryIterator(world, included, excluded)
	end

	function self:onEnter(callback: types.QueryEnterHook<A, B, C, D, E, F, G>): HookDisconnect
		enterHooks[#enterHooks + 1] = callback

		updateObservation()

		return function()
			local index = table.find(enterHooks, callback)
			if index then
				table.remove(enterHooks, index)
			end

			updateObservation()
		end
	end

	function self:onExit(callback: types.QueryExitHook): HookDisconnect
		exitHooks[#exitHooks + 1] = callback

		updateObservation()

		return function()
			local index = table.find(exitHooks, callback)
			if index then
				table.remove(exitHooks, index)
			end

			updateObservation()
		end
	end

	function self:_matches(archetype: Archetype): boolean
		return matches(archetype, included, excluded)
	end

	function self:_fireEnter(entity: Entity, archetype: Archetype)
		if #enterHooks == 0 then
			return
		end

		local row = archetype.entityIndex[entity]
		if not row then
			return
		end

		local accessors = table.create(#included) :: { types.ComponentAccessor<any> }

		for index, component in included do
			local column = archetype.columns[component.name]

			accessors[index] = componentAccessor(column, row, function()
				for _, callback in world._hooks.change do
					callback(entity, component.name)
				end
			end)
		end

		for _, callback in enterHooks do
			callback(entity, table.unpack(accessors))
		end
	end

	function self:_fireExit(entity: Entity)
		if #exitHooks == 0 then
			return
		end

		for _, callback in exitHooks do
			callback(entity)
		end
	end

	return table.freeze(self)
end

local function query(world: World, ...: Component)
	return createQuery(world, { ... }, {})
end

return query
