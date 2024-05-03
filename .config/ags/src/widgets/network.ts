import network from "../service/network";
import { CollapsibleWidget } from "./collapsible_widget";
import { Variable as TVar } from "types/variable";

function NetworkLabel(hovered: TVar<boolean>) {
    return Widget.Label({
        hpack: "end",
        className: "network",
        label: Utils.merge([network.bind("speed"), hovered.bind()], (speed, h) =>
            h
                ? `󰜮 ${(speed.downBytes / 131072).toFixed(2).padStart(5, "0")}Mb/s  󰜷 ${(speed.upBytes / 131072).toFixed(2).padStart(5, "0")}Mb/s`
                : "󰜮 󰜷",
        ),
    });
}

export function Network(args: Pick<Parameters<typeof CollapsibleWidget>[0], "initialMode" | "disableHover">) {
    return CollapsibleWidget({
        ...args,
        child: NetworkLabel,
    });
}
