import { bind, Variable } from "astal";
import Tray from "gi://AstalTray";

export default function SysTray() {
    const tray = Tray.get_default();
    return (
        <button className="widget tray">
            <box>
                {bind(tray, "items").as((items) =>
                    items.map((item) => {
                        return (
                            <menubutton
                                //@ts-ignore
                                tooltipMarkup={bind(item, "tooltipMarkup")}
                                //@ts-ignore
                                actionGroup={bind(item, "action-group").as((ag) => ["dbusmenu", ag])}
                                //@ts-ignore
                                menuModel={bind(item, "menu-model")}
                                usePopover={false}
                            >
                                <icon gIcon={bind(item, "gicon")} />
                            </menubutton>
                        );
                    }),
                )}
            </box>
        </button>
    );
}
