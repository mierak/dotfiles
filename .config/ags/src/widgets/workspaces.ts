import * as utils from "../utils";
import type { Client, Monitor } from "types/service/hyprland";

const hyprland = await Service.import("hyprland");

const workspaceRename = Array.from({ length: 30 }, (_, i) => (i % 10).toString());

function WorkspaceLabel(name: string) {
    return Widget.Label({
        className: "workspace-label",
        label: workspaceRename[name] ?? name,
    });
}

function WorkspaceIcons(id: number) {
    const clients: Client[] = JSON.parse(hyprland.message("j/clients"));
    const swallowed = clients.filter((c) => c.swallowing !== "0x0");

    return clients
        .filter((client) => client.workspace.id === id)
        .filter((client) => !swallowed.some((c) => c.swallowing === client.address))
        .map((client) => {
            return Widget.Icon({
                className: "app-icon",
                vexpand: false,
                icon: utils.getIconName(client),
                size: 16,
            });
        });
}

function WorkspaceClients(id: number, name: string) {
    return Widget.Box({
        children: [WorkspaceLabel(name), ...WorkspaceIcons(id)],
    }).hook(
        hyprland,
        (self, eventName, _data) => {
            switch (eventName) {
                case "movewindowv2": {
                    self.children = [WorkspaceLabel(name), ...WorkspaceIcons(id)];
                    break;
                }
            }
        },
        "event",
    );
}

function Workspace(id: number, name: string, monitorName: string) {
    const button = Widget.Button({
        attribute: { name, id, monitorName },
        className: "workspace",
        child: WorkspaceClients(id, name),
        onPrimaryClick() {
            hyprland.messageAsync(`dispatch workspace ${id}`);
        },
    })
        .hook(hyprland.active.workspace, (self) => {
            self.toggleClassName("active", id === hyprland.active.workspace.id);
        })
        .hook(
            hyprland,
            (self, eventName, data) => {
                if (self.class_name.includes("urgent") && eventName === "activewindowv2") {
                    const address = `0x${data}`;
                    if (hyprland.clients.filter((client) => client.workspace.id === id).some((client) => client.address === address)) {
                        self.toggleClassName("urgent", false);
                    }
                } else if (eventName === "renameworkspace") {
                    const [renameId, newName] = data.split(",");
                    if (id === Number(renameId)) {
                        self.attribute.name = newName;
                        self.child = WorkspaceClients(id, newName);
                    }
                }
            },
            "event",
        )
        .hook(
            hyprland,
            (self, address) => {
                if (address) {
                    let ws = hyprland.clients.find((c) => c.address === address)?.workspace;
                    if (ws?.id === id) {
                        self.toggleClassName("urgent", true);
                    }
                }
            },
            "urgent-window",
        )
        .hook(hyprland, (self) => (self.child = WorkspaceClients(id, name)), "client-added")
        .hook(hyprland, (self) => (self.child = WorkspaceClients(id, name)), "client-removed");

    return button;
}

export function Workspaces(monitor: Monitor) {
    const workspaces = Variable(
        hyprland.workspaces
            .filter((ws) => ws.monitorID === monitor.id)
            .sort((a, b) => Number(a.id) - Number(b.id))
            .map((ws) => Workspace(ws.id, ws.name, ws.monitor)),
    );

    return Widget.Box({
        vertical: false,
        child: Widget.Box({
            className: "workspaces",
            children: workspaces.bind(),
        })
            .hook(
                hyprland,
                (_, name) => {
                    const ws = hyprland.workspaces.find((w) => w.name === name);
                    if (ws && ws.monitorID === monitor.id) {
                        workspaces.value.push(Workspace(ws.id, ws.name, monitor.name));
                        workspaces.setValue(workspaces.value.sort((a, b) => a.attribute.id - b.attribute.id));
                    }
                },
                "workspace-added",
            )
            .hook(
                hyprland,
                (_, name) => {
                    workspaces.value = workspaces.value.filter((ws) => ws.attribute.name !== name);
                },
                "workspace-removed",
            )
            .hook(
                hyprland,
                (_, eventName, data) => {
                    if (eventName == "moveworkspacev2") {
                        let [wsId, wsName, monitorName] = data.split(",");
                        wsId = Number(wsId);

                        const ws = workspaces.value.find((ws) => ws.attribute.id === wsId);
                        if (ws && monitorName !== monitor.name) {
                            workspaces.value = workspaces.value.filter((ws) => ws.attribute.id !== wsId);
                        } else if (!ws && monitorName === monitor.name) {
                            workspaces.value.push(Workspace(wsId, wsName, monitorName));
                            workspaces.setValue(workspaces.value.sort((a, b) => a.attribute.id - b.attribute.id));
                        }
                    }
                },
                "event",
            ),
    });
}
