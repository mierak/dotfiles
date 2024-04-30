import { type TrayItem } from "types/service/systemtray";
const systemtray = await Service.import("systemtray");

const SysTrayItem = (item: TrayItem) =>
    Widget.Button({
        child: Widget.Icon().bind("icon", item, "icon"),
        classNames: ["icon"],
        tooltipMarkup: item.bind("tooltip_markup"),
        onPrimaryClick: (_, event) => item.activate(event),
        onSecondaryClick: (_, event) => item.openMenu(event),
    });

export function Systray() {
    return Widget.Box({
        children: systemtray.bind("items").as((i) => i.map(SysTrayItem)),
        classNames: ["widget", "tray"],
    });
}
