--!strict

const types = require './types'

const function componentAccessor<T>(column: { any }, index: number, onChange: (() -> ())?): types.ComponentAccessor<T>
	return function(...)
		if select('#', ...) == 0 then
			return column[index]
		end

		const newValue = select(1, ...)
		column[index] = newValue

		if onChange then
			onChange()
		end

		return newValue :: T
	end
end

return componentAccessor
