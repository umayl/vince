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
	Entity?,
	ComponentAccessor?,
	ComponentAccessor?,
	ComponentAccessor?,
	ComponentAccessor?,
	ComponentAccessor?,
	ComponentAccessor?,
	ComponentAccessor?
)

export type Query<A = unknown, B = unknown, C = unknown, D = unknown, E = unknown, F = unknown, G = unknown> = {
	with: (self: Query<A, B, C, D, E, F, G>, ...Component) -> Query<A, B, C, D, E, F, G>,

	without: (self: Query<A, B, C, D, E, F, G>, ...Component) -> Query<A, B, C, D, E, F, G>,

	iter: (self: Query<A, B, C, D, E, F, G>) -> QueryIterator<A, B, C, D, E, F, G>,
}

-- World Hooks

export type WorldHookDisconnect = () -> ()

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

	-- Entity lifecycle
	spawn: (self: World) -> Entity,
	despawn: (self: World, entity: Entity) -> (),
	clear: (self: World) -> (),
	exists: (self: World, entity: Entity) -> boolean,

	-- Hooks
	onInsert: (self: World, callback: WorldInsertHook) -> WorldHookDisconnect,
	onRemove: (self: World, callback: WorldRemoveHook) -> WorldHookDisconnect,
	onChange: (self: World, callback: WorldChangeHook) -> WorldHookDisconnect,
	onDespawn: (self: World, callback: WorldDespawnHook) -> WorldHookDisconnect,
	onClear: (self: World, callback: WorldClearHook) -> WorldHookDisconnect,

	-- Components
	insert: (self: World, entity: Entity, ...Component) -> (),
	remove: (self: World, entity: Entity, ...Component) -> (),
	has: (self: World, entity: Entity, ...Component) -> boolean,
	get: <T>(self: World, entity: Entity, component: Component<T>) -> ComponentAccessor<T>?,

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
