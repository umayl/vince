--!strict

local component = require '@self/component'
local types = require '@self/types'
local world = require '@self/world'

export type Entity = types.Entity
export type Component<T = unknown> = types.Component<T>
export type Query<A = unknown, B = unknown, C = unknown, D = unknown, E = unknown, F = unknown, G = unknown> =
	types.Query<A, B, C, D, E, F, G>
export type World = types.World

return table.freeze {
	world = world,
	component = component,
}
