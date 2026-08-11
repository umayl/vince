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

-- Hooks

export type HookDisconnect = () -> ()

-- Queries

export type QueryIterator<A, B, C, D, E, F, G> = (
) -> (
	Entity?,
	ComponentAccessor<A>?,
	ComponentAccessor<B>?,
	ComponentAccessor<C>?,
	ComponentAccessor<D>?,
	ComponentAccessor<E>?,
	ComponentAccessor<F>?,
	ComponentAccessor<G>?
)

export type QueryEnterHook<A, B, C, D, E, F, G> = (
	Entity,
	ComponentAccessor<A>?,
	ComponentAccessor<B>?,
	ComponentAccessor<C>?,
	ComponentAccessor<D>?,
	ComponentAccessor<E>?,
	ComponentAccessor<F>?,
	ComponentAccessor<G>?
) -> ()

export type QueryExitHook = (Entity) -> ()

export type Query<A = unknown, B = unknown, C = unknown, D = unknown, E = unknown, F = unknown, G = unknown> = {
	iter: (self: Query<A, B, C, D, E, F, G>) -> QueryIterator<A, B, C, D, E, F, G>,

	onEnter: (self: Query<A, B, C, D, E, F, G>, callback: QueryEnterHook<A, B, C, D, E, F, G>) -> HookDisconnect,
	onExit: (self: Query<A, B, C, D, E, F, G>, callback: QueryExitHook) -> HookDisconnect,

	_matches: (self: Query<A, B, C, D, E, F, G>, archetype: Archetype) -> boolean,
	_fireEnter: (self: Query<A, B, C, D, E, F, G>, entity: Entity, archetype: Archetype) -> (),
	_fireExit: (self: Query<A, B, C, D, E, F, G>, entity: Entity) -> (),
}

-- World Hooks

export type WorldInsertHook = (entity: Entity, component: Component) -> ()

export type WorldRemoveHook = (entity: Entity, component: Component) -> ()

export type WorldChangeHook = (entity: Entity, componentName: string) -> ()

export type WorldDespawnHook = (entity: Entity) -> ()

export type WorldClearHook = () -> ()

export type WorldHooks = {
	insert: { WorldInsertHook },
	remove: { WorldRemoveHook },
	change: { WorldChangeHook },
	despawn: { WorldDespawnHook },
	clear: { WorldClearHook },
}

-- World

export type World = {
	-- stores
	_entities: EntityStore,
	_archetypes: ArchetypeStore,
	_records: RecordStore,

	-- Root archetype
	_rootArchetype: Archetype,

	-- Hook storage
	_hooks: WorldHooks,

	-- Observed queries
	_observedQueries: { [Query]: boolean },

	-- Entity lifecycle
	spawn: (self: World) -> Entity,
	despawn: (self: World, entity: Entity) -> (),
	clear: (self: World) -> (),
	exists: (self: World, entity: Entity) -> boolean,

	-- Hooks
	onInsert: (self: World, callback: WorldInsertHook) -> HookDisconnect,

	onRemove: (self: World, callback: WorldRemoveHook) -> HookDisconnect,

	onChange: (self: World, callback: WorldChangeHook) -> HookDisconnect,

	onDespawn: (self: World, callback: WorldDespawnHook) -> HookDisconnect,

	onClear: (self: World, callback: WorldClearHook) -> HookDisconnect,

	-- Components
	insert: (self: World, entity: Entity, ...Component) -> (),

	remove: (self: World, entity: Entity, ...Component) -> (),

	has: (self: World, entity: Entity, ...Component) -> boolean,

	get: <T>(self: World, entity: Entity, component: Component<T>) -> ComponentAccessor<T>?,

	-- Internal query observation
	_observeQuery: (self: World, query: Query) -> (),

	_unobserveQuery: (self: World, query: Query) -> (),

	-- Queries
	query: ((self: World) -> Query<unknown, unknown, unknown, unknown, unknown, unknown, unknown>) & (<A>(
		self: World,
		a: Component<A>
	) -> Query<A, unknown, unknown, unknown, unknown, unknown, unknown>) & (<A, B>(
		self: World,
		a: Component<A>,
		b: Component<B>
	) -> Query<A, B, unknown, unknown, unknown, unknown, unknown>) & (<A, B, C>(
		self: World,
		a: Component<A>,
		b: Component<B>,
		c: Component<C>
	) -> Query<A, B, C, unknown, unknown, unknown, unknown>) & (<A, B, C, D>(
		self: World,
		a: Component<A>,
		b: Component<B>,
		c: Component<C>,
		d: Component<D>
	) -> Query<A, B, C, D, unknown, unknown, unknown>) & (<A, B, C, D, E>(
		self: World,
		a: Component<A>,
		b: Component<B>,
		c: Component<C>,
		d: Component<D>,
		e: Component<E>
	) -> Query<A, B, C, D, E, unknown, unknown>) & (<A, B, C, D, E, F>(
		self: World,
		a: Component<A>,
		b: Component<B>,
		c: Component<C>,
		d: Component<D>,
		e: Component<E>,
		f: Component<F>
	) -> Query<A, B, C, D, E, F, unknown>) & (<A, B, C, D, E, F, G>(
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

return nil
