local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")

local helpers   = require("helpers")
local cfg       = require("config")

local icon_font = beautiful.fonts.symbols_base .. "30"

local info_icon = wibox.widget {
    widget = wibox.widget.textbox,
    markup = helpers.colorize { text = "", fg = beautiful.color4 },
    font   = icon_font,
    valign = "top",
}

local warn_icon = wibox.widget {
    widget = wibox.widget.textbox,
    markup = helpers.colorize { text = "", fg = beautiful.color3 },
    font   = icon_font,
    valign = "top",
}

local err_icon = wibox.widget {
    widget = wibox.widget.textbox,
    markup = helpers.colorize { text = "", fg = beautiful.color1 },
    font   = icon_font,
    valign = "top",
}

local function get_icon(severity)
    if severity == "info" then
        return info_icon
    elseif severity == "warn" then
        return warn_icon
    elseif severity == "err" then
        return err_icon
    end
end

local function get_default_title(severity)
    if severity == "info" then
        return "Confirm"
    elseif severity == "warn" then
        return "Warning"
    elseif severity == "err" then
        return "Error"
    end
end

local grabber = nil
local popup = nil
return function (args)
    if not cfg.use_confirm_dialogs then
        args.on_click()
        return
    end
    local params = args or {}
    if popup then
        grabber:stop()
        popup.visible = false
    end

    popup = awful.popup {
        visible = true,
        ontop   = true,
        screen = awful.screen.focused(),
        placement = awful.placement.centered,
        minimum_width = params.min_width or 250,
        maximum_width = params.max_width or 400,
        widget = {
            widget  = wibox.container.margin,
            margins = beautiful.margin,
            {
                layout  = wibox.layout.fixed.vertical,
                spacing = beautiful.margin,
                {
                    widget = wibox.widget.textbox,
                    text   = params.title or get_default_title(params.severity or "info"),
                    font = beautiful.fonts.base .. "12",
                },
                {
                    layout  = wibox.layout.fixed.horizontal,
                    spacing = beautiful.margin,
                    get_icon(params.severity or "info"),
                    {
                        widget  = wibox.widget.textbox,
                        valign  = "center",
                        text    = params.message or "Are you sure?",
                        justify = params.justify_message or false,
                    },
                },
                {
                    layout = wibox.container.place,
                    halign = "right",
                    {
                        layout = wibox.layout.fixed.horizontal,
                        spacing = beautiful.margin,
                        helpers.text_button {
                            text = params.ok_text or "Confirm",
                            font = beautiful.fonts.base .. "12",
                            margins = {
                                left  = beautiful.margin * 1,
                                right = beautiful.margin * 1,
                            },
                            on_click = function ()
                                grabber:stop()
                                params.on_click()
                            end
                        },
                        helpers.text_button {
                            text = params.cancel_text or "Cancel",
                            font = beautiful.fonts.base .. "12",
                            margins = {
                                left  = beautiful.margin * 1,
                                right = beautiful.margin * 1,
                            },
                            on_click = function ()
                                grabber:stop()
                            end
                        },
                    }
                },
            }
        },
    }

    grabber = awful.keygrabber {
        stop_key           = { "Escape", "Return" },
        stop_event         = "release",
        export_keybindings = false,
        stop_callback      = function ()
            popup.visible = false
        end,
        keybindings = {
            awful.key {
                modifiers = {},
                key       = "Return",
                on_press  = function ()
                    params.on_click()
                end
            },
        },
    }
    grabber:start()
end
