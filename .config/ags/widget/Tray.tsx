import { bind, Variable } from "astal";
import { Gdk } from "astal/gtk3";
import Tray from "gi://AstalTray";
import Astal from "gi://Astal?version=3.0";

const tray = Tray.get_default();

export default function CollapsibleWidget() {
    return (
        <button className="widget tray">
            <box>
                {bind(tray, "items").as((items) =>
                    items.map((item) => {
                        const menu = item.create_menu();
                        return (
                            <button
                                tooltipMarkup={bind(item, "tooltipMarkup")}
                                onClick={(self, ev) => {
                                    if (ev.button === Astal.MouseButton.PRIMARY) {
                                        item.activate(ev.x, ev.y);
                                    } else if (ev.button === Astal.MouseButton.SECONDARY) {
                                        menu?.popup_at_widget(self, Gdk.Gravity.SOUTH, Gdk.Gravity.NORTH_EAST, null);
                                    }
                                }}
                                onDestroy={() => {
                                    menu?.destroy();
                                }}
                            >
                                <icon icon={item.iconName} />
                            </button>
                        );
                    }),
                )}
            </box>
        </button>
    );
}
