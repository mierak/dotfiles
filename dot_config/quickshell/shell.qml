//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts

import Quickshell.Widgets
import qs
import qs.services
import qs.widgets


ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root
            property var modelData
            screen: modelData
            color: "transparent"

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: Constants.barHeight + Constants.screenGapTop

            WrapperItem {
                id: bar
                leftMargin: Constants.screenGap
                rightMargin: Constants.screenGap
                topMargin: Constants.screenGapTop
                anchors.fill: parent

                RowLayout {
                    id: grid

                    Workspaces {
                        id: workspaces
                        screen: root.screen
                    }

                    ClippingRectangle {
                        Layout.fillWidth: true
                        radius: Constants.wsButtonRadius
                        implicitHeight: Constants.barHeight
                        color: "transparent"

                        Rectangle {
                            anchors.right: parent.right
                            width: Math.min(windowName.width, parent.width)

                            WindowName {
                                id: windowName
                                anchors.left: parent.left
                                visible: !Constants.windowNameFocusedOnly || !!HyprData.monitorsByName[root.screen?.name]?.focused
                                screen: root.screen
                            }
                        }
                    }

                    RowLayout {
                        id: modules
                        spacing: Constants.paddingH / 2

                        BarWidget {
                            id: sunset
                            textColor: Colors.peach
                            symbol: ""
                            content: `${Hyprsunset.temperature}°K`
                            onWheelUp: Hyprsunset.inc()
                            onWheelDown: Hyprsunset.dec()
                            collapsed: true
                        }

                        BarWidget {
                            id: mem
                            textColor: Colors.mauve
                            symbol: ""
                            content: `${Math.round((SystemResources.mem.used / SystemResources.mem.total) * 100)}%`
                            collapsed: true
                        }

                        BarWidget {
                            id: disk
                            textColor: Colors.yellow
                            symbol: "󰋊"
                            content: `${SystemResources.disk.used}/${SystemResources.disk.size}`
                            collapsed: true
                        }

                        BarWidget {
                            id: netDown
                            textColor: Colors.green
                            symbol: "󰜮"
                            content: `${(SystemResources.net.down / 131072).toFixed(2).padStart(5, "0")}Mb/s`
                            collapsed: true
                        }

                        BarWidget {
                            id: netUp
                            textColor: Colors.green
                            symbol: "󰜷"
                            content: `${(SystemResources.net.up / 131072).toFixed(2).padStart(5, "0")}Mb/s`
                            collapsed: true
                        }

                        BarWidget {
                            id: cpu
                            textColor: Colors.red
                            symbol: ""
                            content: `${SystemResources.cpu.usage}% ${SystemResources.cpu.temp}°C`
                            onClick: Quickshell.execDetached("missioncenter")
                        }

                        BarWidget {
                            id: vol
                            textColor: Colors.blue
                            symbol: Audio.muted ? "󰖁" : ""
                            content: `${Audio.volumePerc}%`
                            onWheelUp: Audio.setVolume(Audio.volume + 0.01)
                            onWheelDown: Audio.setVolume(Audio.volume - 0.01)
                            onRightClick: Audio.toggleMute()
                            onClick: Quickshell.execDetached("pavucontrol")
                        }

                        BarWidget {
                            id: micVol
                            textColor: Colors.blue
                            symbol: Audio.micMuted ? "" : ""
                            content: `${Audio.micVolumePerc}%`
                            onWheelUp: Audio.setMicVolume(Audio.micVolume + 0.01)
                            onWheelDown: Audio.setMicVolume(Audio.micVolume - 0.01)
                            onRightClick: Audio.toggleMicMute()
                            onClick: Quickshell.execDetached("pavucontrol")
                        }

                        Tray {}

                        BarWidget {
                            id: time
                            textColor: Colors.text
                            symbol: ""
                            collapsed: false
                            content: Time.time
                            // onClick: Time.cycleFormat()
                        }
                    }
                }
            }
        }
    }
}
