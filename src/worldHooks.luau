--!strict

local types = require './types'

const function worldHooks(): types.WorldHooks
	return {
		insert = {},
		remove = {},
		change = {},
		despawn = {},
		clear = {},
	}
end

return worldHooks
