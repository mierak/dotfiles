import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import qs

MouseArea {
    id: root

    property var bar: root.QsWindow.window
    required property SystemTrayItem item
    property bool targetMenuOpen: false

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    Layout.fillHeight: true
    implicitWidth: trayIcon.width
    property var event

    onClicked: event => {
        event = event;
        switch (event.button) {
        case Qt.LeftButton:
            item.activate();
            break;
        case Qt.RightButton:
            if (item.hasMenu)
                menu.open();
            break;
        }
        event.accepted = true;
        menu.anchor.rect.x = trayIcon.mapToGlobal(event.x - bar.screen.x, event.y).x;
    }

    QsMenuAnchor {
        id: menu

        menu: root.item.menu
        anchor.window: bar
        anchor.rect.y: root.y
        anchor.rect.height: root.height
        anchor.edges: Edges.Bottom
    }

    IconImage {
        id: trayIcon
        source: root.item.icon
        anchors.centerIn: parent
        implicitSize: Constants.iconSize
    }
}
