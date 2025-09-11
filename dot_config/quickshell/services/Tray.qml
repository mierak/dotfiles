import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs

Rectangle {
    id: root
    implicitWidth: wrapper.implicitWidth
    implicitHeight: Constants.barHeight
    color: Colors.background
    radius: Constants.wsButtonRadius

    WrapperItem {
        id: wrapper
        leftMargin: Constants.paddingH
        rightMargin: Constants.paddingH
        anchors.fill: parent

        RowLayout {
            id: rowLayout
            spacing: Constants.paddingH

            Repeater {
                model: SystemTray.items

                TrayItem {
                    required property SystemTrayItem modelData
                    item: modelData
                }
            }
        }
    }
}
