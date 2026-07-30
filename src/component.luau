--!strict

export type Component<T> = {
	name: string,
	value: T,
}

const function component<T>(name: string, initialValue: T): Component<T>
	return {
		name = name,
		value = initialValue,
	}
end

return component
