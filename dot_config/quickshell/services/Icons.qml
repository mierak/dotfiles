pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var fallbackIcons: ({})
    property var steamAppids: ({})

    function getIcon(cls) {
        const fallback = root.fallbackIcons[cls];
        if (fallback) {
            return fallback;
        }

        // check steam game icons
        if (cls?.startsWith("steam_app")) {
            const appid = cls.substring(10);
            const appIcons = root.steamAppids[appid];
            if (appIcons?.path) {
                return `file://${appIcons.path}`;
            }
            if (appIcons?.logo) {
                return `file://${appIcons.logo}`;
            }
        }

        const icon = DesktopEntries.heuristicLookup(cls)?.icon;
        return Quickshell.iconPath(icon, "/home/mrk/.config/ags/assets/app-icons/missing.png");
    }

    // seems like every steam game has an icon in format like 'f6da1420a173324d49bcd470fa3eee781ad0fa5e.jpg'
    // all these icons are jpg and no other images with similar name are present in any game from what I can tell.
    // // If above fails, check for logo.png in the same dir
    Process {
        id: getSteamAppIds
        command: ["find", "/home/mrk/.local/share/Steam/appcache/librarycache", "-maxdepth", "2", "-mindepth", "2", "-regextype", "posix-extended", "-regex", ".*([0-9a-f]{40}|logo)\.(png|jpg)"]
        running: true
        stdout: StdioCollector {
            id: steamAppIdsStdout
            onStreamFinished: {
                const icons = steamAppIdsStdout.text.split("\n").map(l => l.trim()).filter(l => !!l.length);

                for (const iconPath of icons) {
                    const split = iconPath.replace("/home/mrk/.local/share/Steam/appcache/librarycache/", "").split("/");
                    const appid = split[0];
                    const filename = split[1];

                    let result = root.steamAppids[appid] ?? {};
                    root.steamAppids[appid] = result;
                    if (filename.startsWith("logo")) {
                        result.logo = iconPath;
                    } else {
                        result.path = iconPath;
                    }
                }

                console.log("Found steam apps:", Object.keys(root.steamAppids).length);
            }
        }
    }

    Process {
        id: getFallbackIcons
        command: ["find", "/home/mrk/.config/ags/assets/app-icons", "-type", "f"]
        running: true
        stdout: StdioCollector {
            id: fbStdout
            onStreamFinished: {
                const text = fbStdout.text.trim();
                for (const line of text.split("\n")) {
                    if (line.length > 0) {
                        const parts = line.trim().split("/");
                        const filename = parts.pop();
                        const fileStem = filename.split(".")[0];
                        root.fallbackIcons[fileStem] = `file://${line}`;
                    }
                }
            }
        }
    }
}
