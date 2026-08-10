--!strict

const archetype = require './archetype'
const types = require './types'

type Component<T = unknown> = types.Component<T>
type Archetype = types.Archetype
type ArchetypeStore = types.ArchetypeStore

const function deriveSignature(components: { Component }): string
	const componentNames = table.create(#components)

	for _, component in components do
		componentNames[#componentNames + 1] = component.name
	end

	table.sort(componentNames)

	return table.concat(componentNames, '|')
end

const function create(): ArchetypeStore
	return {
		archetypes = {},
		componentArchetypes = {},
	}
end

const function register(store: ArchetypeStore, components: { Component }): Archetype
	const signature = deriveSignature(components)

	const newArchetype = archetype.create(components)
	store.archetypes[signature] = newArchetype

	for _, component in components do
		const name = component.name
		store.componentArchetypes[name] = store.componentArchetypes[name] or {}

		const archetypes = store.componentArchetypes[name]
		archetypes[#archetypes + 1] = newArchetype
	end

	return newArchetype
end

const function getOrCreate(store: ArchetypeStore, components: { Component }): Archetype
	const signature = deriveSignature(components)

	const existingArchetype = store.archetypes[signature]
	if existingArchetype then
		return existingArchetype
	end

	return register(store, components)
end

const function getComponentArchetypes(store: ArchetypeStore, componentName: string): { Archetype }?
	return store.componentArchetypes[componentName]
end

return table.freeze {
	create = create,

	register = register,
	getOrCreate = getOrCreate,
	getComponentArchetypes = getComponentArchetypes,
}
