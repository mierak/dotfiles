import { Workspaces } from "./widgets/workspaces";
import { Window } from "./widgets/window";
import { Systray } from "./widgets/tray";
import type { Monitor } from "types/service/hyprland";
import { HyprToGdkMonitor as hyprToGdkMonitor } from "./utils";
import { Volume } from "./widgets/volume";
import { Network } from "./widgets/network";
import { Cpu } from "./widgets/cpu";
import { Time } from "./widgets/time";

App.addIcons(`${App.configDir}/assets`);
App.addIcons(`${App.configDir}/assets/window-icons`);

const hyprland = await Service.import("hyprland");

function Bar(monitor: Monitor) {
    return Widget.Window({
        gdkmonitor: hyprToGdkMonitor(monitor),
        name: `bar${monitor.id}`,
        anchor: ["top", "left", "right"],
        exclusivity: "exclusive",
        className: "bar",
        child: Widget.CenterBox({
            start_widget: Workspaces(monitor),
            center_widget: Window(monitor),
            end_widget: Widget.Box({
                hpack: "end",
                className: "right",
                children: [Network(), Cpu(), Volume(), Systray(), Time()],
            }),
        }),
    });
}

export default {
    windows: hyprland.monitors.map((m) => Bar(m)),
};
