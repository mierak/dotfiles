import cpu from "../service/cpu";
import { CollapsibleWidget } from "./collapsible_widget";
import { Variable as TVar } from "types/variable";

function CpuLabel(hovered: TVar<boolean>) {
    return Widget.Label({
        hpack: "end",
        className: "cpu",
        label: Utils.merge([cpu.bind("usage"), hovered.bind()], (usage, hovered) => {
            if (hovered) {
                return `  ${usage}%`;
            } else {
                return "";
            }
        }),
    });
}

export function Cpu(args: Pick<Parameters<typeof CollapsibleWidget>[0], "initialMode" | "disableHover">) {
    return CollapsibleWidget({
        ...args,
        child: CpuLabel,
    });
}
