const interval = 5_000;
class Cpu extends Service {
    static {
        Service.register(
            this,
            {},
            {
                usage: ["int", "r"],
            },
        );
    }

    private prevActiveTime = 0;
    private prevTotalTime = 0;
    usage = 0;

    constructor() {
        super();
        Utils.interval(interval, () => {
            Utils.execAsync("head -n1 /proc/stat")
                .then((stdout) => this.onUpdate(stdout))
                .catch(console.error);
        });
    }

    private onUpdate(stdout: string) {
        let idleTime = 0;
        let totalTime = 0;
        let idx = 1;

        const tokens = stdout.split(" ");
        tokens.splice(0, 1); // remove "cpu" from output
        for (const token of tokens) {
            totalTime += Number(token);

            if (idx === 5 || idx === 6) {
                idleTime += Number(token);
            }
            idx += 1;
        }

        const activeTime = totalTime - idleTime;
        const deltaActiveTime = activeTime - this.prevActiveTime;
        const deltaTotalTime = totalTime - this.prevTotalTime;

        this.usage = Math.ceil((deltaActiveTime / deltaTotalTime) * 100);
        this.changed("usage");

        this.prevActiveTime = activeTime;
        this.prevTotalTime = totalTime;
    }
}

export default new Cpu();
