pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Hyprland

import qs

Singleton {
    id: root

    signal changed

    property var clients: []
    property var clientsByWorkspace: []
    property var clientsByAddress: ({})

    property var workspaceIds: []
    property var workspaces: []
    property var workspacesById: ({})
    property list<int> urgentWorkspaceIds: []

    property var monitors: []
    property var monitorsByName: ({})

    function update() {
        // order is important here
        getMonitors.running = true;
        getWorkspaces.running = true;
        getClients.running = true;
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            // TODO
            if (event.name == "urgent") {
                const wsId = root.clientsByAddress["0x" + event.data]?.workspace?.id;
                if (!root.urgentWorkspaceIds.includes(wsId) && !root.workspacesById[wsId].focused) {
                    root.urgentWorkspaceIds.push(wsId);
                }
            } else if (event.name == "workspacev2") {
                const wsId = event.data.split(",")[0];
                root.urgentWorkspaceIds = root.urgentWorkspaceIds.filter(id => id != wsId);
            } else if (event.name == "focusedmonv2") {
                const wsId = event.data.split(",")[1];
                root.urgentWorkspaceIds = root.urgentWorkspaceIds.filter(id => id != wsId);
            } else {
                root.update(event);
            }
        }
    }

    Process {
        id: getClients
        running: true
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            id: stdout
            onStreamFinished: {
                const clients = JSON.parse(stdout.text);

                const wsClients = {};
                const clientsByAddress = {};

                for (const client of clients) {
                    if (!getClients.shouldDisplayClient(client)) {
                        continue;
                    }

                    wsClients[client.workspace.id] = [...(wsClients[client.workspace.id] ?? []), client];
                    clientsByAddress[client.address] = client;
                }

                root.clients = clients;
                root.clientsByWorkspace = wsClients;
                root.clientsByAddress = clientsByAddress;
                root.changed();
            }
        }

        function shouldDisplayClient(client) {
            if (client.class && Constants.ignoredClients.some(ic => {
                let titleEq = true;
                // undefined check is important, title can be empty string
                if (ic.title !== undefined) {
                    titleEq = ic.title == client.title;
                }

                return titleEq && ic.class == client.class;
            })) {
                return false;
            }
            return true;
        }
    }

    Process {
        id: getMonitors
        running: true
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            id: monStdout
            onStreamFinished: {
                root.monitors = JSON.parse(monStdout.text);
                const newMons = {};
                for (const mon of root.monitors) {
                    newMons[mon.name] = mon;
                }
                root.monitorsByName = newMons;
            }
        }
    }

    Process {
        id: getWorkspaces
        running: true
        command: ["hyprctl", "workspaces", "-j"]
        stdout: StdioCollector {
            id: wsStdout
            onStreamFinished: {
                const activeWs = root.monitors?.map(mon => mon.activeWorkspace?.id).filter(ws => !!ws) ?? [];
                const workspaces = JSON.parse(wsStdout.text);
                workspaces.sort((a, b) => a.id - b.id);

                const newWsById = {};
                for (const ws of root.workspaces) {
                    if (activeWs.includes(ws.id)) {
                        ws.focused = true;
                    } else {
                        ws.focused = false;
                    }
                    newWsById[ws.id] = ws;
                }

                root.workspaceIds = workspaces.map(ws => ws.id);
                root.workspaces = workspaces;
                root.workspacesById = newWsById;
            }
        }
    }
}
