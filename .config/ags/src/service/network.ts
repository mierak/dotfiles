const interval = 5_000;
class NetworkSpeed extends Service {
    static {
        Service.register(
            this,
            {},
            {
                speed: ["int", "r"],
            },
        );
    }

    private prev = { rx: 0, tx: 0 };
    speed = { upBytes: 0, downBytes: 0 };

    constructor() {
        super();
        Utils.interval(interval, async () => {
            try {
                const stdout = await Utils.execAsync(["sh", "-c", "cat /sys/class/net/[ew]*/statistics/*_bytes"]);
                let tx = 0;
                let rx = 0;
                let idx = 0;
                for (const line of stdout.split("\n")) {
                    if (idx % 2 === 0) {
                        rx += Number(line);
                    } else {
                        tx += Number(line);
                    }
                    idx++;
                }
                this.speed.upBytes = ((tx - this.prev.tx) / interval) * 1000;
                this.speed.downBytes = ((rx - this.prev.rx) / interval) * 1000;

                this.changed("speed");
                this.prev.rx = rx;
                this.prev.tx = tx;
            } catch (error) {
                console.error(error);
            }
        });
    }
}

export default new NetworkSpeed();
