pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

import qs

Singleton {
    id: root
    property string time
    property real currentFormatIndex: Constants.initialTimeFormatIdx

    function cycleFormat(): void {
        currentFormatIndex = (currentFormatIndex + 1) % Constants.timeFormats.length;
    }

    Process {
        id: dateProc
        command: ["date", Constants.timeFormats[root.currentFormatIndex]]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root.time = this.text
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dateProc.running = true
    }
}
