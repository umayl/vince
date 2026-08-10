--!strict

const types = require './types'

const function componentAccessor(column: { any }, index: number, onChange: (() -> ())?): types.ComponentAccessor
	return function(...)
		if select('#', ...) == 0 then
			return column[index]
		end

		const newValue = select(1, ...)
		column[index] = newValue

		if onChange then
			onChange()
		end

		return newValue
	end
end

return componentAccessor
