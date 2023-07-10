local ls = require "luasnip"

local f = ls.function_node

local M = {}

M.same = function(index)
	return f(function(args)
		return args[1]
	end, { index })
end

M.capture_at = function(index)
	return function(_, snip)
		if not snip.captures or not snip.captures[index] then
			return ""
		end
		return snip.captures[index]
	end
end

return M
