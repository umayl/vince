--!strict

const types = require './types'

const function componentAccessor<T>(column: { T }, index: number): types.ComponentAccessor<T>
	return function(...)
		if select('#', ...) == 0 then
			return column[index]
		end

		const newValue = select(1, ...) :: T
		column[index] = newValue

		return newValue
	end
end

return componentAccessor
