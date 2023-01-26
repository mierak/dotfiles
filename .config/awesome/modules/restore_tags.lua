local awful = require("awful")

-- Restore active tags on awesome restart
return function ()
    awesome.connect_signal("exit", function (is_exit)
        if not is_exit then return end

        local str = ""
        for s in screen do
            str = str .. s.selected_tag.name .."\n"
        end
        awful.spawn.easy_async_with_shell("echo '" .. str .. "' > /tmp/awm_tags", function () end)
    end)
    awesome.connect_signal("startup", function ()
        local index = 1
        awful.spawn.with_line_callback("cat /tmp/awm_tags", {
            stdout = function (line)
                if not line or #line == 0 then return end
                local t = awful.tag.find_by_name(screen[index], line)
                if t then
                    t:view_only()
                end
                index = index + 1
            end
        })
    end)
end
