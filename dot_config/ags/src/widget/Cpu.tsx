import { bind, Variable } from "astal";

const cpu = Variable({ active: 0, total: 0, usage: 0 }).poll(5000, ["head", "-n1", "/proc/stat"], (out, prev) => {
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
const temp = Variable(0).poll(5000, ["sh", "-c", "sensors -j | jq '.\"k10temp-pci-00c3\".Tctl.temp1_input'"], (out) => {
    return Math.round(Number(out.trim()));
});

export default function FileSystem() {
    const cpuAndTemp = Variable.derive([cpu, temp], (cpu, temp) => {
        return `  ${cpu.usage}% ${temp}°C`;
    });

    return (
        <button
            onClick={() => {
                cpu.stopPoll();
                cpu.startPoll();
                temp.stopPoll();
                temp.startPoll();
            }}
            className="widget cpu"
        >
            {bind(cpuAndTemp).as((str) => {
                return str;
            })}
        </button>
    );
}
