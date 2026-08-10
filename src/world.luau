--!strict

const archetype = require './archetype'
const archetypeStore = require './archetypeStore'
const componentAccessor = require './componentAccessor'
const entityStore = require './entityStore'
const query = require './query'
const recordStore = require './recordStore'
const types = require './types'
const worldHooks = require './worldHooks'

type Entity = types.Entity
type Component<T = unknown> = types.Component
type Archetype = types.Archetype

type World = types.World
type WorldInsertHook = types.WorldInsertHook
type WorldRemoveHook = types.WorldRemoveHook
type WorldChangeHook = types.WorldChangeHook
type WorldDespawnHook = types.WorldDespawnHook
type WorldClearHook = types.WorldClearHook
type WorldHookDisconnect = types.WorldHookDisconnect

const ROOT_ARCHETYPE_KEY = ''

-- Archetype Migration

const function migrate(world: World, entity: Entity, newArchetype: Archetype, components: { Component })
	const record = recordStore.get(world._records, entity)
	const oldArchetype = record.archetype

	const values = {}
	for name in oldArchetype.componentSet do
		values[name] = archetype.getComponentValue(oldArchetype, entity, name)
	end

	const movedEntity, movedIndex = archetype.removeEntity(oldArchetype, entity)
	if movedEntity then
		const movedRecord = recordStore.get(world._records, movedEntity)

		movedRecord.index = movedIndex :: number
	end

	const newEntityIndex = archetype.addEntity(newArchetype, entity)
	record.archetype = newArchetype
	record.index = newEntityIndex

	for name, value in values do
		const column = newArchetype.columns[name]

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

-- Hooks

const function addWorldHook<T>(hooks: { T }, callback: T): () -> ()
	hooks[#hooks + 1] = callback

	return function()
		const index = table.find(hooks, callback)

		if index then
			table.remove(hooks, index)
		end
	end
end

const function onInsert(self: World, callback: WorldInsertHook): WorldHookDisconnect
	return addWorldHook(self._hooks.insert, callback)
end

const function onRemove(self: World, callback: WorldRemoveHook): WorldHookDisconnect
	return addWorldHook(self._hooks.remove, callback)
end

const function onChange(self: World, callback: WorldChangeHook): WorldHookDisconnect
	return addWorldHook(self._hooks.change, callback)
end

const function onDespawn(self: World, callback: WorldDespawnHook): WorldHookDisconnect
	return addWorldHook(self._hooks.despawn, callback)
end

const function onClear(self: World, callback: WorldClearHook): WorldHookDisconnect
	return addWorldHook(self._hooks.clear, callback)
end

-- Components

const function insert(self: World, entity: Entity, ...)
	const componentsToInsert: { Component } = { ... }

	const record = recordStore.get(self._records, entity)
	if not record then
		return
	end

	const currentArchetype = record.archetype

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
	const insertedComponents: { Component } = {}

	for _, component in { ... } do
		if not archetype.hasComponent(currentArchetype, component) then
			insertedComponents[#insertedComponents + 1] = component
		end
	end

	if #insertedComponents == 0 then
		return
	end

	const newArchetype = archetypeStore.getOrCreate(self._archetypes, componentsToInsert)
	migrate(self, entity, newArchetype, componentsToInsert)

	for _, component in insertedComponents do
		for _, callback in self._hooks.insert do
			callback(entity, component)
		end
	end
end

const function remove(self: World, entity: Entity, ...: Component)
	const componentsToRemove: { Component } = { ... }

	const record = recordStore.get(self._records, entity)
	if not record then
		return
	end

	const currentArchetype = record.archetype
	const remainingComponents: { Component } = {}
	const removedComponents: { Component } = {}

	for name in currentArchetype.componentSet do
		local shouldRemove = false

		for _, component in componentsToRemove do
			if component.name ~= name then
				continue
			end

			shouldRemove = true

			break
		end

		const value = archetype.getComponentValue(currentArchetype, entity, name)

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

	const newArchetype = archetypeStore.getOrCreate(self._archetypes, remainingComponents)
	migrate(self, entity, newArchetype, remainingComponents)

	for _, component in removedComponents do
		for _, callback in self._hooks.remove do
			callback(entity, component)
		end
	end
end

const function has(self: World, entity: Entity, ...: Component): boolean
	const record = recordStore.get(self._records, entity)
	if not record then
		return false
	end

	const currentArchetype = record.archetype

	for _, component in { ... } do
		if not archetype.hasComponent(currentArchetype, component) then
			return false
		end
	end

	return true
end

const function get(self: World, entity: Entity, component: Component): types.ComponentAccessor?
	const record = recordStore.get(self._records, entity)
	if not record then
		return
	end

	const currentArchetype = record.archetype

	const column = currentArchetype.columns[component.name]
	if not column then
		return
	end

	return componentAccessor(column, record.index, function()
		for _, callback in self._hooks.change do
			callback(entity, component.name)
		end
	end)
end

-- Entity Lifecycle

const function exists(self: World, entity: Entity): boolean
	return recordStore.get(self._records, entity) ~= nil
end

const function spawn(self: World): Entity
	const records = self._records
	const rootArchetype = self._rootArchetype

	const newEntity = entityStore.allocate(self._entities)
	const newEntityIndex = archetype.addEntity(rootArchetype, newEntity)
	recordStore.insert(records, newEntity, rootArchetype, newEntityIndex)

	return newEntity
end

const function despawn(self: World, entity: Entity)
	const record = recordStore.get(self._records, entity)
	if not record then
		return
	end

	archetype.removeEntity(record.archetype, entity)
	recordStore.remove(self._records, entity)

	for _, callback in self._hooks.despawn do
		callback(entity)
	end
end

const function clear(self: World)
	table.clear(self._records.records)
	table.clear(self._archetypes.archetypes)
	table.clear(self._archetypes.componentArchetypes)

	table.clear(self._rootArchetype.entities)
	table.clear(self._rootArchetype.entityIndex)

	for _, column in self._rootArchetype.columns do
		table.clear(column)
	end

	self._entities.nextEntityId = 0
	self._archetypes.archetypes[ROOT_ARCHETYPE_KEY] = self._rootArchetype

	for _, callback in self._hooks.clear do
		callback()
	end
end

-- World

const function world(): World
	const entities = entityStore.create()
	const archetypes = archetypeStore.create()
	const records = recordStore.create()

	const rootArchetype = archetype.create {}
	const hooks = worldHooks()

	return table.freeze {
		_entities = entities,
		_archetypes = archetypes,
		_records = records,

		_rootArchetype = rootArchetype,
		_hooks = hooks,

		-- Entity lifecycle
		spawn = spawn,
		despawn = despawn,
		clear = clear,
		exists = exists,

		-- Hooks
		onInsert = onInsert,
		onRemove = onRemove,
		onChange = onChange,
		onDespawn = onDespawn,
		onClear = onClear,

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
