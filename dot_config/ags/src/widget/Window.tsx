import { Gdk } from "astal/gtk3";
import { bind, Binding, Variable } from "astal";
import Hyprland from "gi://AstalHyprland";
import { HyprToGdkMonitor } from "../utils";
import { getAppIcon, windowIcon } from "../icons";

export default function Window(props: {
    gdkmonitor: Gdk.Monitor;
    children?: Array<JSX.Element> | Binding<Array<JSX.Element>>;
}) {
    const hyprland = Hyprland.get_default();
    const floatingIcon = <icon className="icon" icon={windowIcon("floating")} visible={false} />;
    const maximizedIcon = <icon className="icon" icon={windowIcon("maximized")} visible={false} />;
    const title = Variable(hyprland.focusedClient?.title ?? "");

    bind(hyprland, "focusedClient").subscribe((client) => {
        title.set(client?.title ?? "");
    });

    const appIcon = (
        <icon
            vexpand={false}
            icon_size={16}
            className="app-icon"
            icon={bind(hyprland, "focusedClient").as((client) => {
                return getAppIcon(client?.class);
            })}
        />
    );

    hyprland.connect("event", (_, ev, data) => {
        if (HyprToGdkMonitor(hyprland.focusedMonitor) !== props.gdkmonitor) {
            return;
        }
        switch (ev) {
            case "fullscreen": {
                const isMaximized = data === "1";
                maximizedIcon.visible = isMaximized;
                break;
            }
            case "changefloatingmode": {
                const isFloating = data.split(",")[1] === "1";
                floatingIcon.visible = isFloating;
                break;
            }
            case "windowtitle": {
                const result: Hyprland.Client[] = JSON.parse(hyprland.message("j/clients"));
                title.set(result.find((c) => `0x${data}` === c.address)?.title ?? "");
                break;
            }
        }
    });

    return (
        <button
            className="window"
            visible={bind(hyprland, "focusedMonitor").as((mon) => HyprToGdkMonitor(mon) === props.gdkmonitor)}
            onClicked={() => undefined}
            child={
                <box>
                    {floatingIcon}
                    {maximizedIcon}
                    {appIcon}
                    <label className="title" label={bind(title)} truncate={true} />
                </box>
            }
        ></button>
    );
}
