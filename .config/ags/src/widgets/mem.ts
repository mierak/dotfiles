import memory from "../service/mem";
import { CollapsibleWidget } from "./collapsible_widget";
import { Variable as TVar } from "types/variable";

function MemoryLabel(hovered: TVar<boolean>) {
    return Widget.Label({
        hpack: "end",
        className: "memory",
        label: Utils.merge([memory.bind("value"), hovered.bind()], (value, h) =>
            h ? `  ${Math.round((value.used / value.total) * 100)}%` : "",
        ),
    });
}

export function Memory(args: Pick<Parameters<typeof CollapsibleWidget>[0], "initialMode" | "disableHover">) {
    return CollapsibleWidget({
        ...args,
        child: MemoryLabel,
    });
}
