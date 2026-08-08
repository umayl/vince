--!strict

local archetype = require './archetype'
local types = require './types'

type Component<T = unknown> = types.Component<T>
type Archetype = types.Archetype
type ArchetypeStore = types.ArchetypeStore

local function deriveSignature(components: { Component }): string
	local componentNames = table.create(#components)

	for _, component in components do
		componentNames[#componentNames + 1] = component.name
	end

	table.sort(componentNames)

	return table.concat(componentNames, '|')
end

local function create(): ArchetypeStore
	return {
		archetypes = {},
		componentArchetypes = {},
	}
end

local function register(store: ArchetypeStore, components: { Component }): Archetype
	local signature = deriveSignature(components)

	local newArchetype = archetype.create(components)
	store.archetypes[signature] = newArchetype

	for _, component in components do
		local name = component.name
		store.componentArchetypes[name] = store.componentArchetypes[name] or {}

		local archetypes = store.componentArchetypes[name]
		archetypes[#archetypes + 1] = newArchetype
	end

	return newArchetype
end

local function getOrCreate(store: ArchetypeStore, components: { Component }): Archetype
	local signature = deriveSignature(components)

	local existingArchetype = store.archetypes[signature]
	if existingArchetype then
		return existingArchetype
	end

	return register(store, components)
end

local function getComponentArchetypes(store: ArchetypeStore, componentName: string): { Archetype }?
	return store.componentArchetypes[componentName]
end

return table.freeze {
	create = create,

	register = register,
	getOrCreate = getOrCreate,
	getComponentArchetypes = getComponentArchetypes,
}
