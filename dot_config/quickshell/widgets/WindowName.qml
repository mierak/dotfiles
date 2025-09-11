pragma ComponentBehavior: Bound
import QtQuick

import Quickshell.Widgets
import qs
import qs.services

Rectangle {
    id: root
    required property var screen
    property var activeClient: {
        const wsId = HyprData.monitorsByName[screen?.name]?.activeWorkspace?.id;
        if (!wsId) {
            return null;
        }

        const ws = HyprData.workspacesById[wsId];
        if (!ws) {
            return null;
        }

        return HyprData.clientsByAddress[ws?.lastwindow];
    }

    color: Colors.background
    radius: Constants.wsButtonRadius
    implicitHeight: Constants.barHeight
    implicitWidth: text.width + icon.width

    WrapperItem {
        id: icon
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        leftMargin: Constants.paddingH

        IconImage {
            implicitSize: Constants.iconSize
            source: Icons.getIcon(root.activeClient?.class)
        }
    }

    WrapperItem {
        id: text
        anchors.left: icon.right
        anchors.verticalCenter: parent.verticalCenter
        rightMargin: Constants.paddingH
        leftMargin: Constants.paddingH

        Text {
            color: Colors.text
            font.family: Constants.fontFamily
            font.pixelSize: Constants.barFontSize
            text: root.activeClient?.title ?? "No active client"
        }
    }
}
