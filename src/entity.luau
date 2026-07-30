--!strict

const world = require './world'
const entityStore = require './entityStore'

const function entity(world: world.World)
	return entityStore.allocate(world.entities)
end

return entity
