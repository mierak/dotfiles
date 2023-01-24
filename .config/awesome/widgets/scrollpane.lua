local wibox     = require("wibox")
local awful     = require("awful")
local gears     = require("gears")
local beautiful = require("beautiful")

local helpers   = require("helpers.misc")

--- Creates a new Scrollpane instance
-- Parameters are specified using the lone table argument pattern.
-- Due to technical limitations all items must be of the same size and the size(height) has to be
-- known before initialization of the scrollpane
-- @tparam[opt={}] table args
-- @tparam[opt] number args.scroll_speed Speed at which the pane scrolls per tick (px)
-- @tparam[opt] number args.scrollbar_width Width of the scrollbar
-- @tparam[opt] number args.spacing Spacing between items
-- @tparam[opt] number args.width Width of the scrollpane
-- @tparam[opt] number args.height Height of the scrollpane
-- @tparam[opt] number args.item_height Height of each individual item in the scrollpane.
local function new(args)
    args = args or {}
    local ret = {}

    ret._private          = {}
    ret._private.widgets  = {}
    ret.scroll_speed      = args.scroll_speedd or 30
    ret.scrollbar_width   = args.scrollbar_width or 15
    ret.spacing           = args.spacing or 10
    ret.width             = args.width or 400
    ret.height            = args.height or 800
    ret.item_width        = ret.width - ret.scrollbar_width
    ret.item_height       = args.item_height or 150

    ret._private.offset_x          = 0
    ret._private.offset_y          = 0
    ret._private.scrollpane_height = 0

    ret._private.widgets.scrollpane_items = wibox.widget {
        layout       = wibox.layout.fixed.vertical,
        forced_width = ret.item_width,
        spacing      = ret.spacing,
    }

    ret._private.widgets.scrollpane = wibox.widget.base.make_widget()
    function ret._private.widgets.scrollpane:layout(_, _, _)
        return {
            wibox.widget.base.place_widget_at(
                ret._private.widgets.scrollpane_items,
                ret._private.offset_x,
                ret._private.offset_y,
                ret.item_width,
                ret._private.scrollpane_height
            )
        }
    end

    -- Clip the draw area so the widget does not spill outside its area
    -- Unfortunately the widgets are still clickable outside this area
    -- Possible solution is here https://stackoverflow.com/questions/55936636/how-to-make-mouse-events-propagate-to-widgets-in-scroll-containers
    -- but for my purposes I can use separate wiboxes for the scrollpane and the rest of the widget to get around this
    function ret._private.widgets.scrollpane:before_draw_children(_, cr, w, h)
        cr:rectangle(0, 0, w, h)
        cr:clip()
    end

    ret._private.widgets.scrollpane:buttons(
        awful.util.table.join(
            awful.button(
                {},
                4,
                function()
                    if ret._private.offset_y >= 0 then return end
                    ret._private.offset_y = ret._private.offset_y + ret.scroll_speed
                    ret._private.widgets.scrollbar._private.value = -ret._private.offset_y / (ret._private.scrollpane_height - ret.height) * 100

                    ret._private.widgets.scrollbar:emit_signal("widget::redraw_needed")
                    ret._private.widgets.scrollpane:emit_signal("widget::layout_changed")
                end
            ),
            awful.button(
                {},
                5,
                function()
                    if ret._private.offset_y <= -ret._private.scrollpane_height + ret.height then return end
                    ret._private.offset_y = ret._private.offset_y - ret.scroll_speed
                    ret._private.widgets.scrollbar._private.value = -ret._private.offset_y / (ret._private.scrollpane_height - ret.height) * 100

                    ret._private.widgets.scrollbar:emit_signal("widget::redraw_needed")
                    ret._private.widgets.scrollpane:emit_signal("widget::layout_changed")
                end
            )
        )
    )

    -- Scrollbar widget
    ret._private.widgets.scrollbar = wibox.widget {
        widget = wibox.widget.slider,
        handle_shape = gears.shape.rounded_bar,
        handle_cursor = "hand1",
        handle_width = ret.height / ret._private.scrollpane_height,
        handle_color = beautiful.active,
        handle_margins = 2,
        bar_color = beautiful.bg_alt,
        bar_border_width = 1,
        bar_border_color = beautiful.active,
        bar_height = ret.scrollbar_width,
        forced_height = ret.scrollbar_width,
        minimum = 0,
        maximum = 100,
        value = 0,
    }

    -- Container to contain the scrollpane itself and a scrollbar
    ret.widget = wibox.widget {
        layout = wibox.layout.manual,
        ret._private.widgets.scrollpane,
    }
    ret.widget:add_at(ret._private.widgets.scrollpane, { x = 0, y = 0 })
    ret.widget:add_at(
        wibox.widget {
            widget = wibox.container.rotate,
            direction = "west",
            ret._private.widgets.scrollbar
        },
        { x = ret.item_width, y = 0 }
    )

    -- Connect value signal to the scrollbar
    ret._private.widgets.scrollbar:connect_signal("property::value", function (_, value)
        ret._private.offset_y = -value * (ret._private.scrollpane_height - ret.height) / 100
        ret._private.widgets.scrollpane:emit_signal("widget::layout_changed")
    end)

    -- Calculate new height based on the number of items
    function ret:calc_scrollpane_height()
        self._private.scrollpane_height = (ret.item_height + ret.spacing) * #ret._private.widgets.scrollpane_items.children
        return ret._private.scrollpane_height
    end

    -- Add item to the scrollpane
    function ret:add_item(item)
        ret._private.widgets.scrollpane_items:add(item)
        self:calc_scrollpane_height()
        ret._private.widgets.scrollbar.handle_width = math.floor(ret.height / ret._private.scrollpane_height * ret.height)
        ret._private.widgets.scrollbar:emit_signal("widget::redraw_needed")
    end

    -- Remove item from the scrollpane
    function ret:remove_item(item)
        ret._private.widgets.scrollpane_items:remove_widgets(item)
        self:calc_scrollpane_height()
        ret._private.widgets.scrollbar.handle_width = math.floor(ret.height / ret._private.scrollpane_height * ret.height)
        ret._private.widgets.scrollbar:emit_signal("widget::redraw_needed")
    end

    return ret
end

------------------------------------------------

local width = 600
local height = 800

local w = new { width = width, height = height, spacing = 2 }

local widget = wibox {
    screen = screen.primary,
    width  = width,
    height = height+100,
    visible = true,
    type    = "dropdown_menu",
}
awful.placement.bottom_right(widget)

widget:setup {
    layout = wibox.container.background,
    bg = "#9f9f9f",
    w.widget,
}

local scrollbar_width = 20

local wibox_width = 400
local item_width = wibox_width - scrollbar_width
local item_height = 150

local function create_item(args)
    args = args or {}
    local w = wibox.widget {
        layout = wibox.container.background,
        bg = args.color or "#FF0000",
        forced_width = item_width,
        forced_height = item_height,
        border_color = "#FFFFFF",
    }
    w.buttons = {
        awful.button({}, 1, function ()
            w.bg = "#00FF00"
        end),
        awful.button({}, 3, function ()
            args.w:remove_item(w)
        end)
    }
    return w
end
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
w:add_item(create_item { color = "#0000FF", w = w })
local toremove = create_item { color = "#FF0000", w = w }
w:add_item(toremove)

