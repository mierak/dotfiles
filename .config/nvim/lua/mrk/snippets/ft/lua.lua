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

local require_var = function(args, _)
	local text = args[1][1] or ""
	local split = vim.split(text, ".", { plain = true })

	local options = {}
	for len = 0, #split - 1 do
		table.insert(options, t(table.concat(vim.list_slice(split, #split - len, #split), "_")))
	end

	return sn(nil, {
		c(1, options),
	})
end

-- stylua: ignore
return {
    s("s ign", t("-- stylua: ignore")),

	s("req", fmt('local {} = require("{}")', { d(2, require_var, { 1 }), i(1) })),

	s(
        "lf",
        fmt([[
            local function {}({})
                {}
            end
        ]],
        { i(1, "name"), i(2, "args"), i(0) })
    ),

	s(
        "tf",
        fmt([[
            local function {}.{}({})
                {}
            end
        ]],
        { i(1, "table"), i(2, "name"), i(3, "args"), i(0) })
    ),

	s(
		{ trig = "(%w+)([.:])fun", regTrig = true, dscr = "Creates a method on a table" },
        fmt("function {}{}{}({})\n\t{}\nend", { f(shared.capture_at(1)), f(shared.capture_at(2)), i(1, "name"), i(2, "args"), i(0) })
	),

    s(
        { trig = "(%w+)guard", regTrig = true, dscr = "Creates a guard clause around variable" },
        fmt([[
            if {} then
                return {}
            end
        ]],
        { d(1, function (_, parent)
            local var_name = shared.capture_at(1)(nil, parent)
            return sn(nil, { c(1, {
                t("not " .. var_name),
                fmt("{} ~= {}", { t(var_name), i(1) }),
                fmt("not {} or #{} < {}", { t(var_name), t(var_name), i(1) }),
            })})
        end), i(2, "nil") })
    ),

    s(
        "lwdg",
        fmt([[
            local {} = wibox.widget {{
                {} = wibox.{}.{},
                {}
            }}
        ]], { i(1), c(2, { t("widget"),t("layout") } ), rep(2), i(3), i(0) })
    ),
}
