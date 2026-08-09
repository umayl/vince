--!strict

-- Entities

export type Entity = number

export type EntityStore = {
	nextEntityId: number,
}

-- Components

export type Component<T = unknown> = {
	name: string,
	value: T,
}

export type ComponentAccessor<T = unknown> = (newValue: T?) -> T

-- Records

export type Record = {
	archetype: Archetype,
	index: number,
}

export type RecordStore = {
	records: { [Entity]: Record },
}

-- Archetypes

export type Archetype = {
	componentSet: { [string]: boolean },
	entities: { Entity },
	entityIndex: { [Entity]: number },
	columns: { [string]: { any } },
}

export type ArchetypeStore = {
	archetypes: { [string]: Archetype },
	componentArchetypes: { [string]: { Archetype } },
}

-- Queries

export type QueryIterator<A, B, C, D, E, F, G> = (
) -> (
	Entity,
	ComponentAccessor<A>,
	ComponentAccessor<B>,
	ComponentAccessor<C>,
	ComponentAccessor<D>,
	ComponentAccessor<E>,
	ComponentAccessor<F>,
	ComponentAccessor<G>
)

export type Query<A = unknown, B = unknown, C = unknown, D = unknown, E = unknown, F = unknown, G = unknown> = {
	without: (self: Query<A, B, C, D, E, F, G>, ...Component) -> Query<A, B, C, D, E, F, G>,

	iter: (self: Query<A, B, C, D, E, F, G>) -> QueryIterator<A, B, C, D, E, F, G>,
}

-- World

export type World = {
	-- stores
	entities: EntityStore,
	archetypes: ArchetypeStore,
	records: RecordStore,

	-- Root archetype
	rootArchetype: Archetype,

	-- Hooks
	hooks: WorldHooks,

	-- Entity lifecycle
	spawn: (self: World) -> Entity,
	despawn: (self: World, entity: Entity) -> (),
	clear: (self: World) -> (),

	-- Components
	insert: (self: World, entity: Entity, ...Component) -> (),
	remove: (self: World, entity: Entity, ...Component) -> (),
	has: (self: World, entity: Entity, ...Component) -> boolean,
	get: <T>(self: World, entity: Entity, component: Component<T>) -> ComponentAccessor<T>?,
	exists: (self: World, entity: Entity) -> boolean,

	-- Queries
	query: (<A>(self: World, a: Component<A>) -> Query<A, unknown, unknown, unknown, unknown, unknown, unknown>)
		& (<A, B>(
			self: World,
			a: Component<A>,
			b: Component<B>
		) -> Query<A, B, unknown, unknown, unknown, unknown, unknown>)
		& (<A, B, C>(
			self: World,
			a: Component<A>,
			b: Component<B>,
			c: Component<C>
		) -> Query<A, B, C, unknown, unknown, unknown, unknown>)
		& (<A, B, C, D>(
			self: World,
			a: Component<A>,
			b: Component<B>,
			c: Component<C>,
			d: Component<D>
		) -> Query<A, B, C, D, unknown, unknown, unknown>)
		& (<A, B, C, D, E>(
			self: World,
			a: Component<A>,
			b: Component<B>,
			c: Component<C>,
			d: Component<D>,
			e: Component<E>
		) -> Query<A, B, C, D, E, unknown, unknown>)
		& (<A, B, C, D, E, F>(
			self: World,
			a: Component<A>,
			b: Component<B>,
			c: Component<C>,
			d: Component<D>,
			e: Component<E>,
			f: Component<F>
		) -> Query<A, B, C, D, E, F, unknown>)
		& (<A, B, C, D, E, F, G>(
			self: World,
			a: Component<A>,
			b: Component<B>,
			c: Component<C>,
			d: Component<D>,
			e: Component<E>,
			f: Component<F>,
			g: Component<G>
		) -> Query<A, B, C, D, E, F, G>),
}

export type WorldHooks = {
	insert: { (entity: Entity, component: Component) -> () },
	remove: { (entity: Entity, component: Component) -> () },
	change: { (entity: Entity, componentName: string) -> () },
	despawn: { (entity: Entity) -> () },
	clear: { () -> () },
}

return nil
