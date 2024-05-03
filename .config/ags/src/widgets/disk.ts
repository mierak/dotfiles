import disk from "../service/disk";
import { CollapsibleWidget } from "./collapsible_widget";
import { Variable as TVar } from "types/variable";

function DiskLabel(hovered: TVar<boolean>) {
    return Widget.Label({
        hpack: "end",
        className: "disk",
        label: Utils.merge([disk.bind("home"), hovered.bind()], (home, hovered) =>
            hovered ? `󰋊  ${(home.used / 1024).toFixed(2)}/${(home.total / 1024).toFixed(2)}GB` : "󰋊",
        ),
    });
}

export function Disk(args: Pick<Parameters<typeof CollapsibleWidget>[0], "initialMode" | "disableHover">) {
    return CollapsibleWidget({
        ...args,
        child: DiskLabel,
    });
}
