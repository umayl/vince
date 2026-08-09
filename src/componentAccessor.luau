--!strict

local types = require './types'

local function componentAccessor(column: { any }, index: number, onChange: (() -> ())?): types.ComponentAccessor
	return function(...)
		if select('#', ...) == 0 then
			return column[index]
		end

		local newValue = select(1, ...)
		column[index] = newValue

		if onChange then
			onChange()
		end

		return newValue
	end
end

return componentAccessor
