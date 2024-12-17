import { App, Astal, Gtk, Gdk } from "astal/gtk3";
import Workspaces from "./Workspaces";
import Window from "./Window";
import Time from "./Time";
import Tray from "./Tray";
import Volume from "./Volume";
import Disk from "./Disk";
import Cpu from "./Cpu";
import Mem from "./Mem";
import Net from "./Network";

export default function Bar(gdkmonitor: Gdk.Monitor) {
    return (
        <window
            className="bar"
            gdkmonitor={gdkmonitor}
            exclusivity={Astal.Exclusivity.EXCLUSIVE}
            anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT}
            application={App}
        >
            <centerbox>
                <Workspaces gdkmonitor={gdkmonitor} />
                <Window gdkmonitor={gdkmonitor} />
                <box halign={Gtk.Align.END}>
                    <Mem />
                    <Disk />
                    <Net />
                    <Cpu />
                    <Volume />
                    <Tray />
                    <Time />
                </box>
            </centerbox>
        </window>
    );
}
