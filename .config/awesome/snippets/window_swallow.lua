local beautiful = require("beautiful")

beautiful.parent_filter_list = { "Vivaldi-stable", "code-oss", "code", "discord", "firefox" }
beautiful.dont_swallow_filter_activated  = true   

local bling = require("bling")
bling.module.window_swallowing.start()