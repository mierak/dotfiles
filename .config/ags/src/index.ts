import { Workspaces } from "./widgets/workspaces";
import { Window } from "./widgets/window";
import { Systray } from "./widgets/tray";
import type { Monitor } from "types/service/hyprland";
import { HyprToGdkMonitor as hyprToGdkMonitor } from "./utils";
import { Volume } from "./widgets/volume";
import { Network } from "./widgets/network";
import { Cpu } from "./widgets/cpu";
import { Time } from "./widgets/time";
import { Disk } from "./widgets/disk";
import { Memory } from "./widgets/mem";

App.addIcons(`${App.configDir}/assets`);
App.addIcons(`${App.configDir}/assets/window-icons`);

const hyprland = await Service.import("hyprland");

function Bar(monitor: Monitor) {
    const mode = monitor.name === "DP-2" ? "collapsed" : "full";
    const disableHover = monitor.name !== "DP-2";
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
                children: [
                    Memory({ initialMode: mode, disableHover }),
                    Disk({ initialMode: mode, disableHover }),
                    Network({ initialMode: mode, disableHover }),
                    Cpu({ initialMode: mode, disableHover }),
                    Volume(),
                    Systray(),
                    Time(),
                ],
            }),
        }),
    });
}

export default {
    windows: hyprland.monitors.map((m) => Bar(m)),
};
