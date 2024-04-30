import cpu from "../service/cpu";

export function Cpu() {
    return Widget.Button({
        classNames: ["widget", "cpu"],
        child: Widget.Label({
            hpack: "end",
            label: cpu.bind("usage").as((usage) => `  ${usage}%`),
        }),
    });
}
