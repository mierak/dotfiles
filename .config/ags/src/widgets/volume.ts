const audio = await Service.import("audio");

const volumeStep = 0.01;

export function Volume() {
    const speaker = audio["speaker"];
    const microphone = audio["microphone"];

    return Widget.Box({
        classNames: ["widget", "volume"],
        children: [
            Widget.Button({
                classNames: ["speaker"],
                label: Utils.merge(
                    [speaker.bind("volume"), speaker.bind("is_muted")],
                    (volume, muted) => `${muted ? "󰖁" : ""}  ${Math.round(volume * 100)}%`,
                ),
                onScrollUp() {
                    speaker.volume += volumeStep;
                },
                onScrollDown() {
                    speaker.volume -= volumeStep;
                },
                onMiddleClick() {
                    speaker.is_muted = !speaker.is_muted;
                },
                onPrimaryClick() {
                    Utils.execAsync("pavucontrol");
                },
            }),
            Widget.Button({
                classNames: ["mic"],
                label: Utils.merge(
                    [microphone.bind("volume"), microphone.bind("is_muted")],
                    (volume, muted) => `${muted ? "" : ""}  ${Math.round(volume * 100)}%`,
                ),
                onScrollUp() {
                    microphone.volume += volumeStep;
                },
                onScrollDown() {
                    microphone.volume -= volumeStep;
                },
                onMiddleClick() {
                    microphone.is_muted = !microphone.is_muted;
                },
                onPrimaryClick() {
                    Utils.execAsync("pavucontrol");
                },
            }),
        ],
    });
}
