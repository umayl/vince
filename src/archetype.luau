--!strict

local types = require './types'

type Entity = types.Entity
type Component<T = unknown> = types.Component<T>
type Archetype = types.Archetype

local function clone<T>(value: T): T
	if type(value) ~= 'table' then
		return value
	end

	local copy = {}
	for key, child in value :: any do
		copy[key] = clone(child)
	end

	return copy :: any
end

local function create(components: { Component }): Archetype
	local componentSet = {}
	local columns = {}

	for _, component in components do
		local name = component.name

		componentSet[name] = true
		columns[name] = {}
	end

	return {
		componentSet = componentSet,
		entities = {},
		entityIndex = {},
		columns = columns,
	}
end

local function addEntity(archetype: Archetype, entity: Entity): number
	local index = #archetype.entities + 1
	archetype.entities[index] = entity
	archetype.entityIndex[entity] = index

	return index
end

local function removeEntity(archetype: Archetype, entity: Entity): (Entity?, number?)
	local index = archetype.entityIndex[entity]
	if not index then
		return
	end

	local lastIndex = #archetype.entities
	local lastEntity = archetype.entities[lastIndex]

	archetype.entities[index] = lastEntity
	archetype.entities[lastIndex] = nil
	archetype.entityIndex[entity] = nil

	if lastEntity ~= entity then
		archetype.entityIndex[lastEntity] = index

		for _, column in archetype.columns do
			column[index] = column[lastIndex]
			column[lastIndex] = nil
		end

		return lastEntity, index
	end

	for _, column in archetype.columns do
		column[index] = nil
	end

	return
end

local function getEntities(archetype: Archetype)
	return archetype.entities
end

local function insertComponent(archetype: Archetype, entity: Entity, component: Component)
	local column = archetype.columns[component.name]
	if not column then
		return
	end

	local index = archetype.entityIndex[entity]
	if not index then
		return
	end

	column[index] = clone(component.value)
end

local function getComponent(archetype: Archetype, entity: Entity, component: Component): Component?
	local column = archetype.columns[component.name]
	if not column then
		return
	end

	local index = archetype.entityIndex[entity]
	if not index then
		return
	end

	return {
		name = component.name,
		value = column[index],
	}
end

local function getComponentValue(archetype: Archetype, entity: Entity, componentName: string): any
	local column = archetype.columns[componentName]
	if not column then
		return
	end

	local index = archetype.entityIndex[entity]
	if not index then
		return
	end

	return column[index]
end

local function getComponentColumn(archetype: Archetype, component: Component)
	return archetype.columns[component.name]
end

local function hasComponent(archetype: Archetype, component: Component): boolean
	return archetype.componentSet[component.name] == true
end

return table.freeze {
	create = create,

	addEntity = addEntity,
	removeEntity = removeEntity,
	getEntities = getEntities,

	insertComponent = insertComponent,
	getComponent = getComponent,
	getComponentValue = getComponentValue,
	getComponentColumn = getComponentColumn,
	hasComponent = hasComponent,
}
