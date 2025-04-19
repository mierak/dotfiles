import { bind, Variable } from "astal";

const disk = Variable({ active: 0, total: 0, usage: 0 }).poll(5000, ["head", "-n1", "/proc/stat"], (out, prev) => {
    let idle = 0;
    let total = 0;
    let index = 0;
    for (const token of out.trim().split(/\s+/)) {
        if (index > 0) {
            total += Number(token);
        }
        // 5 is idle time and 6 is io wait time
        if (index === 4 || index === 5) {
            idle += Number(token);
        }

        index++;
    }
    const active = total - idle;

    const deltaActiveTime = active - prev.active;
    const deltaTotalTime = total - prev.total;
    const usage = Math.ceil((deltaActiveTime / deltaTotalTime) * 100);

    return {
        active,
        total,
        usage,
    };
});

export default function FileSystem() {
    return (
        <button
            onClick={() => {
                disk.stopPoll();
                disk.startPoll();
            }}
            className="widget cpu"
        >
            {bind(disk).as(({ usage }) => {
                return `  ${usage}%`;
            })}
        </button>
    );
}
