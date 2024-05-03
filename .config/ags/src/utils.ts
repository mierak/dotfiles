import { Applications } from "resource:///com/github/Aylur/ags/service/applications.js";
import GLib from "gi://GLib?version=2.0";
import Gdk from "gi://Gdk";
import type { Client } from "types/service/hyprland";
import type { Monitor } from "types/service/hyprland";

const hyprland = await Service.import("hyprland");

const app_icons = new Applications().list.reduce(
    (acc, app) => {
        if (app.icon_name) {
            acc.classOrNames[app.wm_class ?? app.name] = app.icon_name;
            acc.executables[app.executable] = app.icon_name;
        }
        return acc;
    },
    { classOrNames: {}, executables: {} },
);

export function getIconName(client: Client | undefined): string {
    if (!client) {
        return "missing";
    }

    let icon = app_icons.classOrNames[client.class];

    if (!icon) {
        // TODO cache?
        const filePath = `${App.configDir}/assets/${client.class}.png`;
        if (fileExists(filePath)) {
            icon = filePath;
            app_icons.classOrNames[client.class] = icon;
        }
    }

    if (!icon) {
        // TODO cache?
        const filePath = `${App.configDir}/assets/${client.class}.svg`;
        if (fileExists(filePath)) {
            icon = filePath;
            app_icons.classOrNames[client.class] = icon;
        }
    }

    if (!icon) {
        const binaryName = Utils.exec(`ps -p ${client.pid} -o comm=`);
        icon = app_icons.executables[binaryName];
        if (!icon) {
            let key = Object.keys(app_icons.executables).find((key) => key.startsWith(binaryName));
            if (key) {
                icon = app_icons.executables[key];
            }
        }
        if (icon) {
            app_icons[client.class] = icon;
        }
    }

    if (!icon) {
        const icon_key = Object.keys(app_icons.classOrNames).find(
            (key) =>
                key.includes(client.title) ||
                key.includes(client.initialTitle) ||
                key.includes(client.initialClass) ||
                key.includes(client.class),
        );
        if (icon_key) {
            icon = app_icons.classOrNames[icon_key];
            app_icons.classOrNames[client.class] = icon;
        }
    }

    if (!icon) {
        app_icons.classOrNames[client.class] = "missing";
    }

    return icon;
}

export function HyprToGdkMonitor(monitor: Monitor): Gdk.Monitor {
    const mon = Gdk.Display.get_default()?.get_monitor_at_point(monitor.x, monitor.y);
    return mon!!;
}

export function fileExists(path: string): boolean {
    return GLib.file_test(path, GLib.FileTest.EXISTS);
}

export async function queryHyprClients(): Promise<Client[]> {
    return JSON.parse(await hyprland.messageAsync("j/clients"));
}
