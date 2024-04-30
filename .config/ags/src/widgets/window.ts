import type { Monitor } from "types/service/hyprland";
import * as utils from "../utils";

const hyprland = await Service.import("hyprland");

export function Window(monitor: Monitor) {
    const floating_icon = Widget.Icon({
        name: "icon",
        hpack: "center",
        className: "status-icon",
        icon: "floating",
    });

    const maximized_icon = Widget.Icon({
        name: "icon",
        hpack: "center",
        className: "status-icon",
        icon: "maximized",
    });

    const app_icon = Widget.Icon({
        vexpand: false,
        size: 16,
        className: "app-icon",
    });

    return Widget.Button({
        className: "window",
        child: Widget.Box({
            hpack: "start",
            children: [
                floating_icon,
                maximized_icon,
                app_icon,
                Widget.Label({
                    name: "title",
                    hpack: "center",
                    truncate: "end",
                    label: hyprland.active.client.bind("title"),
                }),
            ],
        }),
    }).hook(
        hyprland,
        async (self, eventName, data) => {
            switch (eventName) {
                case "changefloatingmode": {
                    const isFloating = data.split(",")[1] === "1";
                    floating_icon.visible = isFloating;
                    break;
                }
                case "fullscreen": {
                    const isMaximized = data === "1";
                    maximized_icon.visible = isMaximized;
                    break;
                }
                case "focusedmon": {
                    self.visible = hyprland.active.monitor.id === monitor.id;
                    self.toggleClassName("active", hyprland.active.monitor.id === monitor.id);
                    break;
                }
                case "activewindowv2": {
                    const client = (await utils.queryHyprClients()).find((c) => c.address === hyprland.active.client.address);
                    if (!client) {
                        self.visible = false;
                    } else {
                        self.visible = hyprland.active.monitor.id === monitor.id;
                        app_icon.icon = utils.getIconName(client);
                    }
                    floating_icon.visible = !!client?.floating;
                    maximized_icon.visible = !!client?.fullscreen;
                    break;
                }
            }
        },
        "event",
    );
}
