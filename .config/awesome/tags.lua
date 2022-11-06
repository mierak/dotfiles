local awful = require("awful")

return function(screen)
    for i=1,9,1 do
        local selected = false
        local gap_single_client = true
        if i == 1 then
            selected = true
            gap_single_client = false
        end
        awful.tag.add(i, {
            layout = awful.layout.layouts[1],
            screen = screen,
            gap_single_client = gap_single_client,
            selected = selected,
        })
    end
end
