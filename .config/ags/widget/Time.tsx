import { bind, Variable } from "astal";

const time = Variable("").poll(1000, ["date", "+%a, %d/%m/%Y, %H:%M:%S"]);

export default function CollapsibleWidget() {
    return (
        <button className="widget time">
            {bind(time).as((value) => {
                return value;
            })}
        </button>
    );
}
