--!strict

local types = require './types'

local function worldHooks(): types.WorldHooks
	return table.freeze {
		insert = {},
		remove = {},
		change = {},
		despawn = {},
		clear = {},
	}
end

return worldHooks
