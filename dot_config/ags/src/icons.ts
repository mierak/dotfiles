import GLib from "gi://GLib";
import Gio from "gi://Gio?version=2.0";
import Apps from "gi://AstalApps";

export function windowIcon(name: string): string {
    return `${HOME}/.config/ags/assets/window-icons/${name}.png`;
}

function enumerateDir(path: string): string[] {
    const enumerator = Gio.File.new_for_path(path).enumerate_children(
        "standard::name,standard::type",
        Gio.FileQueryInfoFlags.NONE,
        null,
    );
    const pixmapFiles: string[] = [];
    while (true) {
        const info = enumerator.next_file(null);
        if (!info) {
            break;
        }
        pixmapFiles.push(`${path}/${info.get_name()}`);
    }

    return pixmapFiles;
}

const HOME = GLib.getenv("HOME");
const MISSING_ICON = `${HOME}/.config/ags/assets/app-icons/missing.png`;
const apps = new Apps.Apps({
    nameMultiplier: 2,
    entryMultiplier: 1,
    executableMultiplier: 2,
    showHidden: true,
});
const pixmapFiles = enumerateDir("/usr/share/pixmaps");
const hicolorScalable = enumerateDir("/usr/share/icons/hicolor/scalable/apps");
const customIcons = enumerateDir(`${HOME}/.config/ags/assets/app-icons`);

const iconCache: Record<string, string | "NO-ICON"> = {};

// This is not the best but it should find icons for most of the apps that I use
// and the missing oddball can be added to the custom icons dir
export function getAppIcon(name: string | undefined): string {
    // no name, cant search for icon
    if (!name) {
        return MISSING_ICON;
    }

    // icon already in cache
    if (iconCache[name] && iconCache[name] != "NO-ICON") {
        return iconCache[name];
    }

    // icon was already searched for and not found
    if (iconCache[name] && iconCache[name] == "NO-ICON") {
        return MISSING_ICON;
    }

    // check custom icons in ags/assets/app-icons dir
    const custom = customIcons.filter((it) => it.includes(name));
    if (custom.length) {
        iconCache[name] = custom.at(-1)!!;
        return iconCache[name];
    }

    // check steam game icons
    if (name.startsWith("steam_app")) {
        try {
            // seems like every steam game has an icon in format like 'f6da1420a173324d49bcd470fa3eee781ad0fa5e.jpg'
            // all these icons are jpg and no other images with similar name are present in any game from what I can tell.
            const gameFiles = enumerateDir(`${HOME}/.local/share/Steam/appcache/librarycache/${name.substring(10)}`);
            const sha256Pattern = /[0-9a-f]{40}\.jpg$/;
            const icon = gameFiles.find((f) => sha256Pattern.test(f));
            if (icon) {
                iconCache[name] = icon;
                return iconCache[name];
            }
        } catch (err) {
            console.error("Found steam app but no cache dir", name);
        }

        // If above fails, check for logo.png in the same dir
        const steamIconPath = `${HOME}/.local/share/Steam/appcache/librarycache/${name.substring(10)}/logo.png`;
        if (GLib.file_test(steamIconPath, GLib.FileTest.EXISTS)) {
            iconCache[name] = steamIconPath;
            return iconCache[name];
        }
    }

    // Try the apps library here..
    const iconName = apps.fuzzy_query(name)?.[0]?.iconName;
    if (iconName) {
        iconCache[name] = iconName;
        return iconName;
    }

    // try /usr/share/pixmaps
    const pixmaps = pixmapFiles.filter((it) => it.includes(name));
    if (pixmaps.length) {
        iconCache[name] = pixmaps.at(-1)!!;
        return iconCache[name];
    }

    // try /usr/share/icons/hicolor/scalable/apps
    const scalable = hicolorScalable.filter((it) => it.includes(name));
    if (scalable.length) {
        iconCache[name] = scalable.at(-1)!!;
        return iconCache[name];
    }

    // every attempt failed, cache a missing icon
    iconCache["NO-ICON"] = MISSING_ICON;
    return MISSING_ICON;
}
