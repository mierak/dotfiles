import QtQuick
import QtQuick.Layouts

import qs
import Quickshell.Widgets

Rectangle {
    id: root
    radius: Constants.wsButtonRadius
    implicitHeight: Constants.barHeight
    implicitWidth: wrapper.width
    color: {
        if (hovered) {
            return Colors.hovered;
        } else {
            return Colors.background;
        }
    }

    required property string symbol
    required property string content
    required property color textColor

    signal wheelUp(event: WheelEvent)
    signal wheelDown(event: WheelEvent)
    signal click(event: MouseEvent)
    signal rightClick(event: MouseEvent)

    property bool hovered
    property bool collapsed: false

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onEntered: {
            root.hovered = true;
        }
        onExited: {
            root.hovered = false;
        }
        onClicked: ev => {
            switch (ev.button) {
            case Qt.LeftButton:
                root.click(ev);
                break;
            case Qt.RightButton:
                root.rightClick(ev);
                break;
            case Qt.MiddleButton:
                root.collapsed = !root.collapsed;
                break;
            }
        }
        onWheel: ev => {
            const isUp = ev.angleDelta.y > 0;
            if (isUp && root.wheelUp) {
                root.wheelUp(ev);
            } else if (!isUp && root.wheelDown) {
                root.wheelDown(ev);
            }
        }
    }

    WrapperItem {
        id: wrapper
        leftMargin: Constants.paddingH
        rightMargin: Constants.paddingH
        anchors.verticalCenter: parent.verticalCenter

        RowLayout {
            Text {
                id: symbol
                color: root.textColor
                text: root.symbol
                font.family: Constants.fontFamilySymbols
                font.pixelSize: Constants.barFontSize
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
            }
            Text {
                id: content
                visible: !root.collapsed || root.hovered
                color: root.textColor
                text: root.content
                font.family: Constants.fontFamily
                font.pixelSize: Constants.barFontSize
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
