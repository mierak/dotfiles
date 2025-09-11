pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

import qs

Singleton {
    id: root

    property var cpu: ({
            active: 0,
            total: 0,
            usage: 0,
            temp: 0
        })

    property var mem: ({
            used: 0,
            total: 0,
            free: 0
        })

    property var disk: ({
            used: "",
            avail: "",
            size: "",
            target: ""
        })

    property var net: ({
            up: 0,
            down: 0,
            tx: 0,
            rx: 0
        })

    Process {
        id: getCpu
        command: ["head", "-n1", "/proc/stat"]
        stdout: StdioCollector {
            id: cpuStdout
            onStreamFinished: {
                let idle = 0;
                let total = 0;
                let index = 0;
                for (const token of cpuStdout.text.trim().split(/\s+/)) {
                    if (index > 0) {
                        total += Number(token);
                    }
                    // 5 is idle time and 6 is io wait time
                    if (index === 4 || index === 5) {
                        idle += Number(token);
                    }

                    index++;
                }
                const active = total - idle;

                const deltaActiveTime = active - root.cpu.active;
                const deltaTotalTime = total - root.cpu.total;
                const usage = Math.ceil((deltaActiveTime / deltaTotalTime) * 100);

                root.cpu = {
                    active: active,
                    total: total,
                    usage: usage,
                    temp: root.cpu.temp
                };
            }
        }
    }

    Process {
        id: getTemp
        command: ["sh", "-c", "sensors -j | jq '.\"k10temp-pci-00c3\".Tctl.temp1_input'"]
        stdout: StdioCollector {
            id: tempStdout
            onStreamFinished: {
                root.cpu = {
                    temp: Math.round(Number(tempStdout.text.trim())),
                    active: root.cpu.active,
                    total: root.cpu.total,
                    usage: root.cpu.usage
                };
            }
        }
    }

    Process {
        id: getMem
        command: ["free", "--mebi"]
        running: true
        stdout: StdioCollector {
            id: memStdout
            onStreamFinished: {
                const mem = memStdout.text.split("\n")[1];
                const [_, total, used, free, ..._rest] = mem.split(/\s+/);
                root.mem = {
                    used: Number(used),
                    total: Number(total),
                    free: Number(free)
                };
            }
        }
    }

    Process {
        id: getDisk
        command: ["sh", "-c", "df -B 1M -h --output=used,avail,size,target /home | tail -n 1"]
        running: true
        stdout: StdioCollector {
            id: diskStdout
            onStreamFinished: {
                const [used, avail, size, target] = diskStdout.text.trim().split(/\s+/);
                root.disk = {
                    used,
                    avail,
                    size,
                    target
                };
            }
        }
    }

    Process {
        id: getNet
        command: ["sh", "-c", "cat /sys/class/net/[ew]*/statistics/*_bytes"]
        running: true
        stdout: StdioCollector {
            id: netStdout
            onStreamFinished: {
                let rx = 0;
                let tx = 0;

                let idx = 0;
                for (const line of netStdout.text.trim().split("\n")) {
                    if (idx % 2 === 0) {
                        rx += Number(line);
                    } else {
                        tx += Number(line);
                    }

                    idx++;
                }

                root.net = {
                    up: (tx - root.net.tx) / (Constants.netUpdateInterval / 1000),
                    down: (rx - root.net.rx) / (Constants.netUpdateInterval / 1000),
                    tx,
                    rx
                };
            }
        }
    }

    Timer {
        interval: Constants.cpuUpdateInterval
        running: true
        repeat: true
        onTriggered: {
            getCpu.running = true;
            getTemp.running = true;
        }
    }

    Timer {
        interval: Constants.memUpdateInterval
        running: true
        repeat: true
        onTriggered: {
            getMem.running = true;
        }
    }

    Timer {
        interval: Constants.netUpdateInterval
        running: true
        repeat: true
        onTriggered: {
            getNet.running = true;
        }
    }

    Timer {
        interval: Constants.diskUpdateInterval
        running: true
        repeat: true
        onTriggered: {
            getDisk.running = true;
        }
    }
}
