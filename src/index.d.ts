// utility types
type ArrayType<T> = T extends ReadonlyArray<infer U> ? U : never;

interface z {
	// Luau types

	/** checks to see if `type(value) == typeName` */
	type: <T extends keyof CheckablePrimitives>(
		typeName: T,
	) => z.check<CheckablePrimitives[T]>;

	/** checks to see if `typeof(value) == typeName` */
	typeof: <T extends keyof CheckableTypes>(
		typeName: T,
	) => z.check<CheckableTypes[T]>;

	/** checks to see if `value` is not undefined */
	any: z.check<defined>;

	/** checks to see if `value` is a boolean */
	boolean: z.check<boolean>;
	/** checks to see if `value` is a buffer */
	buffer: z.check<buffer>;
	/** checks to see if `value` is a thread */
	thread: z.check<thread>;
	/** checks to see if `value` is a function */
	callback: z.check<Callback>;
	/** alias of t.callback */
	function: z.check<Callback>;
	/** checks to see if `value` is undefined */
	none: z.check<undefined>;
	/** alias of t.none */
	nil: z.check<undefined>;
	/** checks to see if `value` is a string */
	string: z.check<string>;
	/** checks to see if `value` is an object */
	table: z.check<object>;
	/** checks to see if `value` is a userdata */
	userdata: z.check<object>;
	/** checks to see if `value` is a vector (Vector3 in Roblox) */
	vector: z.check<Vector3>;

	/** checks to see if `value` is a number, will _not_ match NaN */
	number: z.check<number>;
	/** checks to see if `value` is NaN */
	nan: z.check<number>;

	// Roblox types

	/** checks to see if `value` is an Axes */
	Axes: z.check<Axes>;
	/** checks to see if `value` is a BrickColor */
	BrickColor: z.check<BrickColor>;
	/** checks to see if `value` is a CatalogSearchParams */
	CatalogSearchParams: z.check<CatalogSearchParams>;
	/** checks to see if `value` is a CFrame */
	CFrame: z.check<CFrame>;
	/** checks to see if `value` is a Color3 */
	Color3: z.check<Color3>;
	/** checks to see if `value` is a ColorSequence */
	ColorSequence: z.check<ColorSequence>;
	/** checks to see if `value` is a ColorSequenceKeypoint */
	ColorSequenceKeypoint: z.check<ColorSequenceKeypoint>;
	/** checks to see if `value` is a DateTime */
	DateTime: z.check<DateTime>;
	/** checks to see if `value` is a DockWidgetPluginGuiInfo */
	DockWidgetPluginGuiInfo: z.check<DockWidgetPluginGuiInfo>;
	/** checks to see if `value` is an Enum */
	Enum: z.check<Enum>;
	/** checks to see if `value` is an EnumItem */
	EnumItem: z.check<EnumItem>;
	/** checks to see if `value` is an Enums */
	Enums: z.check<Enums>;
	/** checks to see if `value` is a Faces */
	Faces: z.check<Faces>;
	/** checks to see if `value` is a FloatCurveKey */
	FloatCurveKey: z.check<FloatCurveKey>;
	/** checks to see if `value` is a Font */
	Font: z.check<Font>;
	/** checks to see if `value` is an Instance */
	Instance: z.check<Instance>;
	/** checks to see if `value` is a NumberRange */
	NumberRange: z.check<NumberRange>;
	/** checks to see if `value` is a NumberSequence */
	NumberSequence: z.check<NumberSequence>;
	/** checks to see if `value` is a NumberSequenceKeypoint */
	NumberSequenceKeypoint: z.check<NumberSequenceKeypoint>;
	/** checks to see if `value` is a OverlapParams */
	OverlapParams: z.check<OverlapParams>;
	/** checks to see if `value` is a PathWaypoint */
	PathWaypoint: z.check<PathWaypoint>;
	/** checks to see if `value` is a PhysicalProperties */
	PhysicalProperties: z.check<PhysicalProperties>;
	/** checks to see if `value` is a Random */
	Random: z.check<Random>;
	/** checks to see if `value` is a Ray */
	Ray: z.check<Ray>;
	/** checks to see if `value` is a RaycastParams */
	RaycastParams: z.check<RaycastParams>;
	/** checks to see if `value` is a RaycastResult */
	RaycastResult: z.check<RaycastResult>;
	/** checks to see if `value` is a RBXScriptConnection */
	RBXScriptConnection: z.check<RBXScriptConnection>;
	/** checks to see if `value` is a RBXScriptSignal */
	RBXScriptSignal: z.check<RBXScriptSignal>;
	/** checks to see if `value` is a Rect */
	Rect: z.check<Rect>;
	/** checks to see if `value` is a Region3 */
	Region3: z.check<Region3>;
	/** checks to see if `value` is a Region3int16 */
	Region3int16: z.check<Region3int16>;
	/** checks to see if `value` is a TweenInfo */
	TweenInfo: z.check<TweenInfo>;
	/** checks to see if `value` is a UDim */
	UDim: z.check<UDim>;
	/** checks to see if `value` is a UDim2 */
	UDim2: z.check<UDim2>;
	/** checks to see if `value` is a Vector2 */
	Vector2: z.check<Vector2>;
	/** checks to see if `value` is a Vector2int16 */
	Vector2int16: z.check<Vector2int16>;
	/** checks to see if `value` is a Vector3 */
	Vector3: z.check<Vector3>;
	/** checks to see if `value` is a Vector3int16 */
	Vector3int16: z.check<Vector3int16>;

	/**
	 * Checks to see if value is equal to any of the literal values provided.
	 */
	literal<T>(...literalValues: ReadonlyArray<T>): z.check<T>;

	/** returns a t.union of each key in the table as a t.literal */
	keyOf: <T>(valueTable: T) => z.check<keyof T>;

	/** returns a t.union of each value in the table as a t.literal */
	valueOf: <T>(
		valueTable: T,
	) => T extends { [P in keyof T]: infer U } ? z.check<U> : never;

	/** checks to see if `value` is an integer */
	integer: z.check<number>;

	/**
	 * Checks whether value is a number type and not NaN, inf, -inf.
	 */
	numberFinite: z.check<number>;

	/** checks to see if `value` is a number and is more than `min` */
	numberGt: (min: number) => z.check<number>;
	/** checks to see if `value` is a number and is less than `max` */
	numberLt: (max: number) => z.check<number>;
	/** checks to see if `value` is a number and is more than or equal to `min` */
	numberGte: (min: number) => z.check<number>;
	/** checks to see if `value` is a number and is less than or equal to `max` */
	numberLte: (max: number) => z.check<number>;

	/** checks to see if `value` is a number and is more than 0 */
	numberPositive: z.check<number>;
	/** checks to see if `value` is a number and is less than 0 */
	numberNegative: z.check<number>;

	/** checks to see if `value` is a number and `min <= value <= max` */
	numberConstrained: (min: number, max: number) => z.check<number>;
	/** checks to see if `value` is a number and `min < value < max` */
	numberConstrainedExclusive: (min: number, max: number) => z.check<number>;

	/** checks `t.string` and determines if value matches the pattern via `string.match(value, pattern)` */
	match: (pattern: string) => z.check<string>;

	/** checks to see if `value` is either nil or passes `check` */
	optional: <T>(check: z.check<T>) => z.check<T | undefined | void>;

	/**
	 * Tuples are not really a part of the TypeScript codestyle,
	 * therefore it does not make any sense to use the `tuple` and `strictTuple` checks.
	 */

	/** checks to see if `value` is a table and if its keys match against `check */
	keys: <T>(check: z.check<T>) => z.check<Map<T, unknown>>;
	/** checks to see if `value` is a table and if its values match against `check` */
	values: <T>(check: z.check<T>) => z.check<Map<unknown, T>>;

	/** checks to see if `value` is a table and all of its keys match against `keyCheck` and all of its values match against `valueCheck` */
	map: <K, V>(
		keyCheck: z.check<K>,
		valueCheck: z.check<V>,
	) => z.check<Map<K, V>>;

	/**
	 * checks to see if `value` is a table and all of its keys match against `keyCheck` and all of its values match against `valueCheck`.
	 *
	 * This function is basically an alias of `map` check except we statically infer checked values.
	 */
	record: <K extends string | number, V>(
		keyCheck: z.check<K>,
		valueCheck: z.check<V>,
	) => z.check<Record<K, V>>;

	/** checks to see if `value` is a table and all of its keys match against `valueCheck` and all of its values are `true` */
	set: <T>(valueCheck: z.check<T>) => z.check<Set<T>>;

	/** checks to see if `value` is an array and all of its keys are sequential integers and all of its values match `check` */
	array: <T>(check: z.check<T>) => z.check<Array<T>>;
	/** ensures value is an array of a strict makeup and size */
	strictArray: <T extends ReadonlyArray<z.check<any>>>(
		...args: T
	) => z.check<{ [K in keyof T]: z.static<T[K]> }>;

	/** checks to see if `value` matches any given check */
	union: <T extends ReadonlyArray<z.check<any>>>(
		...args: T
	) => z.check<z.static<ArrayType<T>>>;

	/** checks to see if `value` matches all given checks */
	intersection: <T extends ReadonlyArray<z.check<any>>>(
		...args: T
	) => T[Exclude<keyof T, keyof Array<any> | "length">] extends infer U
		? (U extends any ? (k: U) => void : never) extends (
				k: z.check<infer I>,
			) => void
			? z.check<I>
			: never
		: never;

	/** checks to see if `value` matches a given interface definition */
	interface: <T extends { [index: string]: z.check<any> }>(
		checkTable: T,
	) => z.check<{ [P in keyof T]: z.static<T[P]> }>;
	/** checks to see if `value` matches a given interface definition with no extra members */
	strictInterface: <T extends { [index: string]: z.check<any> }>(
		checkTable: T,
	) => z.check<{ [P in keyof T]: z.static<T[P]> }>;

	/** ensure value is an Instance and it's ClassName matches the given ClassName */
	instanceOf<S extends keyof Instances>(
		this: void,
		className: S,
	): z.check<Instances[S]>;
	instanceOf<
		S extends keyof Instances,
		T extends { [index: string]: z.check<any> },
	>(
		this: void,
		className: S,
		checkTable: T,
	): z.check<Instances[S] & { [P in keyof T]: z.static<T[P]> }>;

	/** ensure value is an Instance and it's ClassName matches the given ClassName by an IsA comparison */
	instanceIsA<S extends keyof Instances>(
		this: void,
		className: S,
	): z.check<Instances[S]>;
	instanceIsA<
		S extends keyof Instances,
		T extends { [index: string]: z.check<any> },
	>(
		this: void,
		className: S,
		checkTable: T,
	): z.check<Instances[S] & { [P in keyof T]: z.static<T[P]> }>;

	/**
	 * Takes a table where keys are child names and values are functions to check the children against.
	 * Pass an instance tree into the function.
	 * If at least one child passes each check, the overall check passes.
	 *
	 * Warning! If you pass in a tree with more than one child of the same name, this function will always return false
	 */
	children: <T extends { [index: string]: z.check<any> }>(
		checkTable: T,
	) => z.check<Instance & { [P in keyof T]: z.static<T[P]> }>;

	/** checks if `value` is an EnumItem which belongs to `Enum`. */
	enum: <T extends Enum>(Enum: T) => z.check<Extract<T[keyof T], EnumItem>>;

	wrap: <
		Check extends z.check<any>,
		C extends (...args: z.static<Check>) => any,
	>(
		callback: C,
		argCheck: Check,
	) => C;
}

declare namespace z {
	/** creates a static type from a t-defined type */
	export type static<T> = T extends z.check<infer U> ? U : never;

	/** checks to see if `value` is a T */
	export type check<T> = (value: unknown) => value is T;
}

declare const z: z;

export { z };
