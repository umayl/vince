--!strict
--!native
--!optimize 2

const archetype = require './archetype'
const component = require './component'

type Archetype = archetype.Archetype
type Component<T = unknown> = component.Component<T>

export type ArchetypeStore = {
	archetypes: { [string]: Archetype },
	componentArchetypes: { [string]: { Archetype } },
}

const function deriveSignature(components: { Component })
	const componentNames = {}
	for _, component in components do
		table.insert(componentNames, component.name)
	end

	return table.concat(componentNames)
end

const function create(): ArchetypeStore
	return {
		archetypes = {},
		componentArchetypes = {},
	}
end

const function register(store: ArchetypeStore, components: { Component }): Archetype
	const signature = deriveSignature(components)

	const archetype = archetype.create(components)
	store.archetypes[signature] = archetype

	for _, component in components do
		const name = component.name
		store.componentArchetypes[name] = store.componentArchetypes[name] or {}

		const archetypes = store.componentArchetypes[name]
		archetypes[#archetypes + 1] = archetype
	end

	return archetype
end

const function getOrCreate(store: ArchetypeStore, components: { Component }): Archetype
	const signature = deriveSignature(components)

	const archetype = store.archetypes[signature]
	if archetype then
		return archetype
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
