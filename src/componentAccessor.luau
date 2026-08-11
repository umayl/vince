--!strict

local types = require './types'

local function componentAccessor<T>(column: { any }, index: number, onChange: (() -> ())?): types.ComponentAccessor<T>
	return function(...)
		if select('#', ...) == 0 then
			return column[index]
		end

		local newValue = select(1, ...)
		column[index] = newValue

		if onChange then
			onChange()
		end

		return newValue :: T
	end
end

return componentAccessor
