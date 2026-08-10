--!strict

const types = require './types'

const function component<T>(name: string, initialValue: T): types.Component<T>
	return {
		name = name,
		value = initialValue,
	}
end

return component
