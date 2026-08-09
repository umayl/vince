--!strict

local archetype = require './archetype'
local archetypeStore = require './archetypeStore'
local componentAccessor = require './componentAccessor'
local entityStore = require './entityStore'
local query = require './query'
local recordStore = require './recordStore'
local types = require './types'
local worldHooks = require './worldHooks'

type Entity = types.Entity
type Component<T = unknown> = types.Component
type Archetype = types.Archetype
type World = types.World

local ROOT_ARCHETYPE_KEY = ''

-- Archetype Migration

local function migrate(world: World, entity: Entity, newArchetype: Archetype, components: { Component })
	local record = recordStore.get(world.records, entity)

	local oldArchetype = record.archetype
	local values = {}

	for name in oldArchetype.componentSet do
		values[name] = archetype.getComponentValue(oldArchetype, entity, name)
	end

	local movedEntity, movedIndex = archetype.removeEntity(oldArchetype, entity)
	if movedEntity then
		local movedRecord = recordStore.get(world.records, movedEntity)

		movedRecord.index = movedIndex :: number
	end

	local newEntityIndex = archetype.addEntity(newArchetype, entity)
	record.archetype = newArchetype
	record.index = newEntityIndex

	for name, value in values do
		local column = newArchetype.columns[name]

		if column then
			column[newEntityIndex] = value
		end
	end

	for _, component in components do
		if values[component.name] ~= nil then
			continue
		end

		archetype.insertComponent(newArchetype, entity, component)
	end
end

-- Components

local function insert(self: World, entity: Entity, ...)
	local componentsToInsert: { Component } = { ... }

	local record = recordStore.get(self.records, entity)
	if not record then
		return
	end

	local currentArchetype = record.archetype

	for name in currentArchetype.componentSet do
		local alreadyRequested = false

		for _, component in componentsToInsert do
			if component.name ~= name then
				continue
			end

			alreadyRequested = true

			break
		end

		if not alreadyRequested then
			componentsToInsert[#componentsToInsert + 1] = {
				name = name,
				value = archetype.getComponentValue(currentArchetype, entity, name),
			}
		end
	end

	-- Remember which components are actually new.
	local insertedComponents: { Component } = {}

	for _, component in { ... } do
		if not archetype.hasComponent(currentArchetype, component) then
			insertedComponents[#insertedComponents + 1] = component
		end
	end

	if #insertedComponents == 0 then
		return
	end

	local newArchetype = archetypeStore.getOrCreate(self.archetypes, componentsToInsert)
	migrate(self, entity, newArchetype, componentsToInsert)

	for _, component in insertedComponents do
		for _, callback in self.hooks.insert do
			callback(entity, component)
		end
	end
end

local function remove(self: World, entity: Entity, ...: Component)
	local componentsToRemove: { Component } = { ... }

	local record = recordStore.get(self.records, entity)
	if not record then
		return
	end

	local currentArchetype = record.archetype
	local remainingComponents: { Component } = {}
	local removedComponents: { Component } = {}

	for name in currentArchetype.componentSet do
		local shouldRemove = false

		for _, component in componentsToRemove do
			if component.name ~= name then
				continue
			end

			shouldRemove = true

			break
		end

		local value = archetype.getComponentValue(currentArchetype, entity, name)

		if shouldRemove then
			removedComponents[#removedComponents + 1] = {
				name = name,
				value = value,
			}
		else
			remainingComponents[#remainingComponents + 1] = {
				name = name,
				value = value,
			}
		end
	end

	if #removedComponents == 0 then
		return
	end

	local newArchetype = archetypeStore.getOrCreate(self.archetypes, remainingComponents)
	migrate(self, entity, newArchetype, remainingComponents)

	for _, component in removedComponents do
		for _, callback in self.hooks.remove do
			callback(entity, component)
		end
	end
end

local function has(self: World, entity: Entity, ...: Component): boolean
	local record = recordStore.get(self.records, entity)
	if not record then
		return false
	end

	local currentArchetype = record.archetype

	for _, component in { ... } do
		if not archetype.hasComponent(currentArchetype, component) then
			return false
		end
	end

	return true
end

local function get(self: World, entity: Entity, component: Component): types.ComponentAccessor?
	local record = recordStore.get(self.records, entity)
	if not record then
		return
	end

	local currentArchetype = record.archetype

	local column = currentArchetype.columns[component.name]
	if not column then
		return
	end

	return componentAccessor(column, record.index, function()
		for _, callback in self.hooks.change do
			callback(entity, component.name)
		end
	end)
end

-- Entity Lifecycle

local function exists(self: World, entity: Entity): boolean
	return recordStore.get(self.records, entity) ~= nil
end

local function spawn(self: World): Entity
	local records = self.records
	local rootArchetype = self.rootArchetype

	local newEntity = entityStore.allocate(self.entities)
	local newEntityIndex = archetype.addEntity(rootArchetype, newEntity)
	recordStore.insert(records, newEntity, rootArchetype, newEntityIndex)

	return newEntity
end

local function despawn(self: World, entity: Entity)
	local record = recordStore.get(self.records, entity)
	if not record then
		return
	end

	archetype.removeEntity(record.archetype, entity)
	recordStore.remove(self.records, entity)

	for _, callback in self.hooks.despawn do
		callback(entity)
	end
end

local function clear(self: World)
	table.clear(self.records.records)
	table.clear(self.archetypes.archetypes)
	table.clear(self.archetypes.componentArchetypes)

	table.clear(self.rootArchetype.entities)
	table.clear(self.rootArchetype.entityIndex)

	for _, column in self.rootArchetype.columns do
		table.clear(column)
	end

	self.entities.nextEntityId = 0
	self.archetypes.archetypes[ROOT_ARCHETYPE_KEY] = self.rootArchetype

	for _, callback in self.hooks.clear do
		callback()
	end
end

-- World

local function world(): World
	local entities = entityStore.create()
	local archetypes = archetypeStore.create()
	local records = recordStore.create()

	local rootArchetype = archetype.create {}
	local hooks = worldHooks()

	return table.freeze {
		entities = entities,
		archetypes = archetypes,
		records = records,

		rootArchetype = rootArchetype,
		hooks = hooks,

		-- Entity lifecycle
		spawn = spawn,
		despawn = despawn,
		clear = clear,
		exists = exists,

		-- Components
		insert = insert,
		remove = remove,
		has = has,
		get = get,

		-- Queries
		query = query,
	} :: any
end

return world
