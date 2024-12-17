import { Gtk, Gdk } from "astal/gtk3";
import { bind, Variable } from "astal";
import Hyprland from "gi://AstalHyprland";
import { HyprToGdkMonitor } from "../utils";

const workspaceRename = Array.from({ length: 30 }, (_, i) => i % 10);

class Workspace {
    readonly id: number;
    readonly name: string;
    readonly translatedId: number;
    readonly widget: Gtk.Widget;
    readonly urgent: ReturnType<typeof Variable<boolean>>;
    readonly active: ReturnType<typeof Variable<boolean>>;
    readonly className: ReturnType<typeof Variable<string>>;

    constructor(args: { id: number; name: string; translatedId: number }) {
        const hyprland = Hyprland.get_default();
        this.id = args.id;
        this.name = args.name;
        this.translatedId = args.translatedId;
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

        const swallowed = hyprland.clients.filter((c) => c.swallowing !== "0x0");
        const clients = bind(hyprland, "clients").as((clients) =>
            clients
                .filter((client) => client.workspace.id === args.id)
                .filter((client) => !swallowed.some((c) => c.swallowing === client.address))
                .map((client) => {
                    return <icon className="icon" icon={client.class} />;
                }),
        );

        this.widget = (
            <button
                className={bind(this.className)}
                onClick={() => hyprland.dispatch("workspace", this.id.toString())}
                onDestroy={() => {
                    this.className.drop();
                }}
            >
                <box>
                    <label className="label" label={this.translatedId.toString()} />
                    {clients}
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
}

export default function Workspaces(props: { gdkmonitor: Gdk.Monitor }) {
    const hyprland = Hyprland.get_default();
    const workspaces = Variable(fetchWorkspaces(props.gdkmonitor));
    workspaces
        .get()
        .find((ws) => ws.id === hyprland.focusedWorkspace.id)
        ?.setActive(true);

    hyprland.connect("workspace-added", (_, workspace) => {
        if (HyprToGdkMonitor(workspace.monitor) === props.gdkmonitor) {
            const current = workspaces.get();
            current.push(
                new Workspace({ id: workspace.id, translatedId: workspaceRename[workspace.id], name: workspace.name }),
            );
            current.sort((a, b) => a.id - b.id);
            workspaces.set([...current]);
        }
    });

    hyprland.connect("workspace-removed", (_, id) => {
        workspaces.set(workspaces.get().filter((ws) => ws.id !== id));
    });

    hyprland.connect("urgent", (_, client) => {
        if (HyprToGdkMonitor(client.monitor) !== props.gdkmonitor) {
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
