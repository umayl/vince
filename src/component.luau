--!strict

local types = require './types'

local function component<T>(name: string, initialValue: T): types.Component<T>
	return {
		name = name,
		value = initialValue,
	}
end

return component
