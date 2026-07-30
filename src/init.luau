--!strict

const world = require '@self/world'
const entity = require '@self/entity'
const query = require '@self/query'
const component = require '@self/component'

return table.freeze {
	world = world,
	entity = entity,
	query = query,
	component = component,
}
