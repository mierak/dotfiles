import { Gdk } from "astal/gtk3";
import Hyprland from "gi://AstalHyprland";

export function HyprToGdkMonitor(monitor: Hyprland.Monitor): Gdk.Monitor | undefined {
    try {
        return Gdk.Display?.get_default()?.get_monitor_at_point(monitor.x + 1, monitor.y + 1);
    } catch (_err) {
        return undefined;
    }
}
export function windowIcon(name: string): string {
    return `/home/mrk/.config/ags/assets/window-icons/${name}.png`;
}
