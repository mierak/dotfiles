import { bind, execAsync, Variable } from "astal";
import Astal from "gi://Astal?version=3.0";
import Wp from "gi://AstalWp";

//@ts-ignore
const audio = Wp.get_default().audio;
const volumeStep = 0.01;

export default function Volume() {
    const speakerVolume = bind(audio.defaultSpeaker, "volume");
    const speakerMuted = bind(audio.defaultSpeaker, "mute");
    const speaker = Variable.derive(
        [speakerVolume, speakerMuted],
        (volume, muted) => `${muted ? "󰖁" : ""}  ${Math.round(volume * 100)}%`,
    );

    const micVolume = bind(audio.defaultMicrophone, "volume");
    const micMuted = bind(audio.defaultMicrophone, "mute");
    const mic = Variable.derive(
        [micVolume, micMuted],
        (volume, muted) => `${muted ? "" : ""}  ${Math.round(volume * 100)}%`,
    );

    return (
        <box
            className="widget volume"
            onDestroy={() => {
                speaker.drop();
                mic.drop();
            }}
        >
            <button
                className="speaker"
                onClick={(_, ev) => {
                    if (ev.button === Astal.MouseButton.PRIMARY) {
                        execAsync("pavucontrol");
                    } else if (ev.button === Astal.MouseButton.MIDDLE) {
                        audio.defaultSpeaker.set_mute(!audio.defaultSpeaker.get_mute());
                    }
                }}
                onScroll={(_, ev) => {
                    if (ev.delta_y < 0) {
                        audio.defaultSpeaker.set_volume(audio.defaultSpeaker.volume + volumeStep);
                    } else if (ev.delta_y > 0) {
                        audio.defaultSpeaker.set_volume(audio.defaultSpeaker.volume - volumeStep);
                    }
                }}
            >
                {bind(speaker)}
            </button>
            <button
                className="mic"
                onClick={(_, ev) => {
                    if (ev.button === Astal.MouseButton.PRIMARY) {
                        execAsync("pavucontrol");
                    } else if (ev.button === Astal.MouseButton.MIDDLE) {
                        audio.defaultMicrophone.set_mute(!audio.defaultMicrophone.get_mute());
                    }
                }}
                onScroll={(_, ev) => {
                    if (ev.delta_y < 0) {
                        audio.defaultMicrophone.set_volume(audio.defaultMicrophone.volume + volumeStep);
                    } else if (ev.delta_y > 0) {
                        audio.defaultMicrophone.set_volume(audio.defaultMicrophone.volume - volumeStep);
                    }
                }}
            >
                {bind(mic)}
            </button>
        </box>
    );
}
