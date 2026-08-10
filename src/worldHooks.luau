--!strict

local types = require './types'

const function worldHooks(): types.WorldHooks
	return table.freeze {
		insert = {},
		remove = {},
		change = {},
		despawn = {},
		clear = {},
	}
end

return worldHooks
