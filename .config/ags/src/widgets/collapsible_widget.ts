import Gtk from "gi://Gtk?version=3.0";
import { Variable as TVar } from "types/variable";

type Args = {
    initialMode: "full" | "collapsed";
    disableHover?: boolean;
    child(hovered: TVar<boolean>): Gtk.Widget;
};

export function CollapsibleWidget(args: Args) {
    const collapsed = Variable(args.initialMode !== "collapsed");

    let leaveConnId: number | undefined = undefined;
    let enterConnId: number | undefined = undefined;

    const widget = Widget.Button({
        classNames: ["widget"],
        child: args.child(collapsed),
    });
    if (!args.disableHover) {
        widget.on_middle_click = function () {
            if (leaveConnId && enterConnId) {
                disconnectCollapsible();
            } else {
                connectCollapsible();
            }
        };
    }

    if (!args.disableHover) {
        connectCollapsible();
    }

    return widget;

    function connectCollapsible() {
        // https://github.com/Aylur/ags/issues/372
        leaveConnId = widget.connect("leave-notify-event", (_, _event) => {
            collapsed.value = false;
        });
        enterConnId = widget.connect("enter-notify-event", (_, _event) => {
            collapsed.value = true;
        });
    }

    function disconnectCollapsible() {
        if (leaveConnId) {
            widget.disconnect(leaveConnId);
            leaveConnId = undefined;
        }
        if (enterConnId) {
            widget.disconnect(enterConnId);
            enterConnId = undefined;
        }
        collapsed.value = true;
    }
}
