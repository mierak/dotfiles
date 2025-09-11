pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

import qs

Singleton {
    id: root

    property real temperature: 0

    function set(temp: real): void {
        root.temperature = Math.min(6500, Math.max(1000, temp));
        Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature", root.temperature]);
    }

    function inc(): void {
        const newTemp = root.temperature + 100;
        root.set(newTemp);
    }

    function dec(): void {
        const newTemp = root.temperature - 100;
        root.set(newTemp);
    }

    Process {
        id: getStatus
        command: ["hyprctl", "hyprsunset", "temperature"]
        running: true
        stdout: StdioCollector {
            id: tempStdout
            onStreamFinished: {
                root.temperature = Number(tempStdout.text.trim());
            }
        }
    }

    Timer {
        interval: Constants.hyprsunsetInterval
        running: true
        repeat: true
        onTriggered: {
            getStatus.running = true;
        }
    }
}
