const interval = 5_000;
class Memory extends Service {
    static {
        Service.register(
            this,
            {},
            {
                value: ["jsobject", "r"],
            },
        );
    }

    #value = { used: 0, free: 0, total: 0 };

    constructor() {
        super();
        Utils.interval(interval, async () => {
            await this.refresh();
        });
    }

    get value() {
        return this.#value;
    }

    async refresh() {
        try {
            const stdout = await Utils.execAsync("sh -c 'free --mebi | sed -n 2p'");

            let [_label, total, used, _free, _shared, _cache, _available] = stdout.split(/\s+/);

            const usedNum = Number(used);
            const totalNum = Number(total);
            const freeNum = totalNum - usedNum;
            this.#value = { used: usedNum, free: freeNum, total: totalNum };

            this.changed("value");
        } catch (error) {
            console.error(error);
        }
    }
}

export default new Memory();
