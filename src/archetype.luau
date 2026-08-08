--!strict

const types = require './types'

type Entity = types.Entity
type Component<T = unknown> = types.Component<T>
type Archetype = types.Archetype

const function create(components: { Component }): Archetype
	const componentSet = {}
	const columns = {}

	for _, component in components do
		const name = component.name
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

const function addEntity(archetype: Archetype, entity: Entity): number
	const index = #archetype.entities + 1
	archetype.entities[index] = entity
	archetype.entityIndex[entity] = index

	return index
end

const function removeEntity(archetype: Archetype, entity: Entity)
	const index = archetype.entityIndex[entity]
	if not index then
		return
	end

	const lastIndex = #archetype.entities
	const lastEntity = archetype.entities[lastIndex]
	archetype.entities[index] = lastEntity
	archetype.entities[lastIndex] = nil

	if lastEntity ~= entity then
		archetype.entityIndex[lastEntity] = index

		for _, column in archetype.columns do
			column[index] = column[lastIndex]
			column[lastIndex] = nil
		end
	else
		for _, column in archetype.columns do
			column[index] = nil
		end
	end

	archetype.entityIndex[entity] = nil
end

const function getEntities(archetype: Archetype)
	return archetype.entities
end

const function insertComponent(archetype: Archetype, entity: Entity, component: Component)
	const column = archetype.columns[component.name]
	if not column then
		return
	end

	const index = archetype.entityIndex[entity]
	if not index then
		return
	end

	column[index] = component.value
end

const function getComponent(archetype: Archetype, entity: Entity, component: Component): Component?
	const column = archetype.columns[component.name]
	if not column then
		return
	end

	const index = archetype.entityIndex[entity]
	if not index then
		return
	end

	return {
		name = component.name,
		value = column[index],
	}
end

const function getComponents(archetype: Archetype, entity: Entity): { Component }
	const index = archetype.entityIndex[entity]
	const components = {}

	for _, column in archetype.columns do
		components[#components + 1] = column[index]
	end

	return components
end

const function getComponentColumn(archetype: Archetype, component: Component)
	return archetype.columns[component.name]
end

const function hasComponent(archetype: Archetype, component: Component): boolean
	return archetype.componentSet[component.name] == true
end

return table.freeze {
	create = create,

	addEntity = addEntity,
	removeEntity = removeEntity,
	getEntities = getEntities,

	insertComponent = insertComponent,
	getComponent = getComponent,
	getComponents = getComponents,
	getComponentColumn = getComponentColumn,
	hasComponent = hasComponent,
}
