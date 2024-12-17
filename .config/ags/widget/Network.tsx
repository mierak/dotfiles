import { bind, Variable } from "astal";

const interval = 5000;
const net = Variable({ tx: 0, rx: 0, up: 0, down: 0 }).poll(
    interval,
    ["sh", "-c", "cat /sys/class/net/[ew]*/statistics/*_bytes"],
    (out, prev) => {
        let rx = 0;
        let tx = 0;

        let idx = 0;
        for (const line of out.trim().split("\n")) {
            if (idx % 2 === 0) {
                rx += Number(line);
            } else {
                tx += Number(line);
            }

            idx++;
        }

        return { tx, rx, up: (tx - prev.tx) / 5, down: (rx - prev.rx) / 5 };
    },
);

export default function Network() {
    return (
        <button className="widget network">
            {bind(net).as(({ up, down }) => {
                return `󰜮 ${(down / 131072).toFixed(2).padStart(5, "0")}Mb/s  󰜷 ${(up / 131072).toFixed(2).padStart(5, "0")}Mb/s`;
            })}
        </button>
    );
}
