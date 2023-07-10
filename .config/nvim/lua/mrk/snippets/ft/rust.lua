local ls = require("luasnip")
local shared = require("mrk.snippets")

local s = ls.s
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local i = ls.insert_node
local t = ls.text_node
local d = ls.dynamic_node
local c = ls.choice_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

--     count.%w+prn
return {
	s({ trig = "test", regTrig = true, dscr = "test test test" }, t("#[cfg(test)]")),
	s(
		{ trig = "(%w+)prn", regTrig = true, dscr = "Prints a variable" },
		fmt('println!("{}: {{:?}}", {});', { f(shared.capture_at(1)), f(shared.capture_at(1)) })
	),
    s("dp", fmt([[println!("{}: {{:?}}", {});]], { shared.same(1), i(1) })),
	s(
		"print",
		f(function(_, snip)
            local result = {}
			local env = snip.env
			for _, ele in ipairs(env.LS_SELECT_RAW) do
                table.insert(result, 'println!("' .. ele .. ': {{:?}}", ' .. ele .. ');')
			end
			return result
		end)
	),
}
