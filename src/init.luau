--!strict

const world = require '@self/world'
const entity = require '@self/entity'
const query = require '@self/query'
const component = require '@self/component'

export type World = world.World
export type Entity = entity.Entity
export type query = query.Query
export type component<T> = component.Component<T>

return table.freeze {
	world = world,
	entity = entity,
	query = query,
	component = component,
}
