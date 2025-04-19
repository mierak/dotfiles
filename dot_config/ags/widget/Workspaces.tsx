import { Gtk, Gdk } from "astal/gtk3";
import { bind, Variable } from "astal";
import Hyprland from "gi://AstalHyprland";
import { HyprToGdkMonitor } from "../utils";
import Apps from "gi://AstalApps";
import app from "../../../../../usr/share/astal/gjs/gtk3/app";

const apps = new Apps.Apps({
    nameMultiplier: 2,
    entryMultiplier: 0,
    executableMultiplier: 2,
});

const workspaceRename = Array.from({ length: 30 }, (_, i) => i % 10);

const hyprland = Hyprland.get_default();

class Workspace {
    readonly id: number;
    readonly name: string;
    readonly translatedId: string;
    readonly widget: Gtk.Widget;
    readonly urgent: ReturnType<typeof Variable<boolean>>;
    readonly active: ReturnType<typeof Variable<boolean>>;
    readonly className: ReturnType<typeof Variable<string>>;
    isDestroyed: boolean = false;
    clients: ReturnType<typeof Variable<Hyprland.Client[]>>;
    visible: ReturnType<typeof Variable<boolean>>;

    constructor(args: { id: number; name: string; translatedId: number | undefined }) {
        this.id = args.id;
        this.name = args.name;
        this.translatedId = args.translatedId?.toString() ?? args.name;
        this.urgent = Variable(false);
        this.active = Variable(false);
        this.className = Variable.derive([this.active, this.urgent], (active, urgent) => {
            const result = ["workspace"];
            if (active) {
                result.push("active");
            }
            if (urgent) {
                result.push("urgent");
            }
            return result.join(" ");
        });

        this.clients = Variable(hyprland.clients.filter((client) => client?.workspace?.id === args?.id));
        this.visible = Variable.derive(
            [this.active, this.clients],
            (active, clients) => !this.translatedId.startsWith("special:") && (active || !!clients.length),
        );

        this.widget = (
            <button
                visible={bind(this.visible)}
                className={bind(this.className)}
                onClick={() => hyprland.dispatch("workspace", this.id.toString())}
                onDestroy={() => {
                    this.isDestroyed = true;
                    this.className.drop();
                }}
            >
                <box>
                    <label className="label" label={this.translatedId.toString()} />
                    {bind(this.clients).as((clients) =>
                        clients.map((client) => {
                            const icon = apps.fuzzy_query(client.class)?.[0]?.iconName ?? client.class;
                            return <icon className="icon" icon={icon} />;
                        }),
                    )}
                </box>
            </button>
        );
    }

    setUrgent(value: boolean) {
        this.urgent.set(value);
    }

    setActive(value: boolean) {
        this.active.set(value);
    }

    reload(clients: Hyprland.Client[]) {
        this.clients.set(clients.filter((client) => client.workspace.id === this.id));
    }

    remove(addr: string) {
        console.log("remove", addr);
        this.clients.set(this.clients.get().filter((client) => client.address !== addr));
    }
}

export default function Workspaces(props: { gdkmonitor: Gdk.Monitor }) {
    const hyprland = Hyprland.get_default();
    const workspaces = Variable(fetchWorkspaces(props.gdkmonitor));
    workspaces
        .get()
        .find((ws) => ws.id === hyprland.focusedWorkspace.id)
        ?.setActive(true);

    hyprland.connect("workspace-added", (_, _workspace) => {
        workspaces.set(fetchWorkspaces(props.gdkmonitor));
    });

    hyprland.connect("workspace-removed", (_, _id) => {
        workspaces.set(fetchWorkspaces(props.gdkmonitor));
    });

    hyprland.connect("urgent", (_, client) => {
        if (HyprToGdkMonitor(client?.monitor) !== props.gdkmonitor) {
            return;
        }
        const workspace = workspaces.get().find((ws) => ws.id === client.workspace.id);
        workspace?.setUrgent(true);
    });

    hyprland.connect("event", async (_, eventName, data) => {
        if (eventName === "activewindowv2") {
            const address = data;
            const client = hyprland.clients.find((client) => address === client.address);
            const workspace = workspaces.get().find((ws) => ws.id === client?.workspace.id);
            workspace?.setUrgent(false);

            for (const ws of workspaces.get()) {
                ws.setActive(ws.id === workspace?.id);
            }
        }

        if (eventName === "focusedmon" || eventName === "workspacev2") {
            const wsName = data.split(",")[1];
            for (const ws of workspaces.get()) {
                ws.setActive(ws.name === wsName);
            }
        }

        if (eventName === "openwindow") {
            // const [address, _wsId, _wsName] = data.split(",");
            //
            // const client = hyprland.clients.find((client) => address === client.address);
            // const workspace = workspaces.get().find((ws) => ws.id === client?.workspace.id);
            // const clients: Hyprland.Client[] = JSON.parse(hyprland.message("j/clients"));
            // workspace?.reload(clients);
            workspaces.set(fetchWorkspaces(props.gdkmonitor));
        }
        if (eventName === "movewindowv2" || eventName === "closewindow") {
            // const clients: Hyprland.Client[] = JSON.parse(hyprland.message("j/clients"));
            // for (const ws of workspaces.get()) {
            //     ws.reload(clients);
            // }
            workspaces.set(fetchWorkspaces(props.gdkmonitor));
        }
    });

    return (
        <box className="workspaces">
            {bind(workspaces).as((workspaces) => {
                return workspaces.map((ws) => ws.widget);
            })}
        </box>
    );
}

function fetchWorkspaces(monitor: Gdk.Monitor): Workspace[] {
    const hyprland = Hyprland.get_default();
    return hyprland.workspaces
        .filter((ws) => HyprToGdkMonitor(ws.monitor) === monitor)
        .sort((a, b) => a.id - b.id)
        .map((ws) => new Workspace({ id: ws.id, translatedId: workspaceRename[ws.id], name: ws.name }));
}
