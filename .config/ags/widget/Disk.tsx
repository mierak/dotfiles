import { bind, Variable } from "astal";

const disk = Variable({ used: "", avail: "", size: "", target: "" }).poll(
    30 * 60 * 1000,
    ["sh", "-c", "df -B 1M -h --output=used,avail,size,target /home | tail -n 1"],
    (out, _prev) => {
        const [used, avail, size, target] = out.trim().split(/\s+/);
        return { used, avail, size, target };
    },
);

export default function FileSystem() {
    return (
        <button
            onClick={() => {
                disk.stopPoll();
                disk.startPoll();
            }}
            className="widget disk"
        >
            {bind(disk).as(({ used, size }) => {
                return `󰋊  ${used}/${size}`;
            })}
        </button>
    );
}
