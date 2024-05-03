const interval = 30 * 60_000;
class Disk extends Service {
    static {
        Service.register(
            this,
            {},
            {
                root: ["jsobject", "r"],
                home: ["jsobject", "r"],
            },
        );
    }

    #root = { total: 0, used: 0, free: 0 };
    #home = { total: 0, used: 0, free: 0 };

    constructor() {
        super();
        Utils.interval(interval, async () => {
            await this.refresh();
        });
    }

    get root() {
        return this.#root;
    }

    get home() {
        return this.#home;
    }

    async refresh() {
        try {
            const stdout = await Utils.execAsync("sh -c 'df -B 1M --output=used,avail,size,target / /home | tail -n 2'");
            const lines = stdout.split("\n");

            let [used, free, blocks1M, path] = lines[0].split(/\s+/);

            this.#root = { total: Number(blocks1M), used: Number(used), free: Number(free) };

            [used, free, blocks1M, path] = lines[1].split(/\s+/);
            this.#home = { total: Number(blocks1M), used: Number(used), free: Number(free) };

            this.changed("home");
            this.changed("root");
        } catch (error) {
            console.error(error);
        }
    }
}

export default new Disk();
