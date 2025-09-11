pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import Quickshell.Hyprland
import Quickshell.Widgets
import qs
import qs.services

RowLayout {
    id: workspaceRoot
    spacing: Constants.wsSpacing
    required property var screen

    Repeater {
        model: {
            HyprData.workspaces.filter(ws => {
                return !!screen?.name && ws.monitor == screen?.name && !Constants.ignoredWsPrefix.some(prefix => ws.name.startsWith(prefix)) && (HyprData.clientsByWorkspace[ws.id]?.length > 0 || HyprData.workspacesById[ws.id]?.focused);
            });
        }

        Rectangle {
            id: wsRect

            required property var modelData
            property var clients: HyprData.clientsByWorkspace[modelData.id]
            property var workspace: HyprData.workspacesById[modelData.id]
            property bool urgent: HyprData.urgentWorkspaceIds.includes(modelData.id)
            property bool hovered: false
            property color wsColor: {
                if (urgent) {
                    return Colors.red;
                }
                if (workspace?.focused || hovered) {
                    return Colors.focused;
                } else {
                    return Colors.background;
                }
            }

            color: wsColor
            radius: Constants.wsButtonRadius

            implicitWidth: wsWrapper.width
            implicitHeight: Constants.barHeight

            border.color: hovered ? Colors.text : "transparent"
            border.width: hovered ? 1 : 0

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    wsRect.hovered = true;
                }
                onExited: {
                    wsRect.hovered = false;
                }
                onClicked: {
                    Hyprland.dispatch(`split-workspace ${Number(wsRect.modelData.id) % 10}`);
                }
            }

            WrapperItem {
                id: wsWrapper
                leftMargin: Constants.paddingH
                rightMargin: Constants.paddingH
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                RowLayout {
                    id: wsRow
                    spacing: Constants.paddingH
                    implicitWidth: wsName.width + wsIcons.width + Constants.paddingH

                    Text {
                        id: wsName
                        color: {
                            if (wsRect.urgent) {
                                return Colors.background;
                            }

                            return Colors.text;
                        }
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.barFontSize
                        text: rename(wsRect.modelData)
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignRight

                        function rename(data) {
                            const num = Number(data.name) % 10;

                            if (num.toString() == "NaN") {
                                return data.name;
                            }

                            return num;
                        }
                    }

                    RowLayout {
                        id: wsIcons
                        visible: !!(wsRect.clients && wsRect.clients?.length > 0)
                        spacing: Constants.iconSpacing

                        Repeater {
                            model: wsRect.clients

                            IconImage {
                                required property var modelData

                                implicitSize: Constants.iconSize
                                implicitWidth: Constants.iconSize
                                source: Icons.getIcon(modelData?.class)
                            }
                        }
                    }
                }
            }
        }
    }
}
