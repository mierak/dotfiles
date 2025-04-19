import { App } from "astal/gtk3";
import style from "./src/style/index.scss";
import Bar from "./src/widget/Bar";

App.start({
    css: style,
    main() {
        App.get_monitors().map(Bar);
    },
});
