pragma Singleton

import Quickshell

Singleton {
    id: root
    property double barHeight: 24
    property double screenGap: 10
    property double screenGapTop: 4
    property double paddingH: 10
    property double barFontSize: 13

    property string fontFamily: "JetBrainsMono Nerd Font Mono"
    property string fontFamilySymbols: "Symbols Nerd Font"

    // workspaces
    property list<var> ignoredClients: [
        {
            class: "xwaylandvideobridge"
        },
        {
            class: "steam",
            title: ""
        }
    ]
    property list<string> ignoredWsPrefix: ["special:"]
    property double iconSpacing: 5
    property double iconSize: barHeight - 10
    property double wsSpacing: 5
    property double wsButtonRadius: 5

    // config
    property bool windowNameFocusedOnly: true

    property real cpuUpdateInterval: 5000
    property real netUpdateInterval: 5000
    property real diskUpdateInterval: 1000 * 60 * 60
    property real memUpdateInterval: 1000
    property real hyprsunsetInterval: 60_000

    // arguments for date command
    property list<string> timeFormats: ["+%a, %d/%m/%Y, %H:%M:%S", "+%d/%m/%Y, %H:%M:%S", "+%H:%M:%S"]
    property real initialTimeFormatIdx: 1
}
