import network from "../service/network";

export function Network() {
    return Widget.Button({
        classNames: ["widget", "network"],
        child: Widget.Label({
            hpack: "end",
            label: network
                .bind("speed")
                .as(
                    (speed) =>
                        `󰜮 ${(speed.downBytes / 131072).toFixed(2).padStart(5, "0")}Mb/s  󰜷 ${(speed.upBytes / 131072).toFixed(2).padStart(5, "0")}Mb/s`,
                ),
        }),
    });
}
