const today = new Date();

const calendar = Widget.Calendar({
    showDayNames: true,
    showDetails: false,
    showHeading: true,
    showWeekNumbers: true,
    day: today.getDate(),
    month: today.getMonth(),
    year: today.getFullYear(),
});

const calendarPopup = Widget.Window({
    child: calendar,
    visible: false,
    anchor: ["top", "right"],
});

const formatter = new Intl.DateTimeFormat("en-GB", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour12: false,
    weekday: "short",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
});

const time = Variable("", {
    poll: [
        1000,
        function () {
            return formatter.format(new Date());
        },
    ],
});

export function Time() {
    const timeWidget = Widget.Button({
        hpack: "end",
        hexpand: false,
        classNames: ["widget", "time"],
        child: Widget.Label({
            hpack: "end",
            label: time.bind(),
        }),
        onHover() {
            calendarPopup.visible = true;
        },
        onHoverLost() {
            calendarPopup.visible = false;
        },
    });

    timeWidget.connect("leave-notify-event", (_, _event) => {
        calendarPopup.visible = false;
    });

    return timeWidget;
}
