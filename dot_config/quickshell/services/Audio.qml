pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property real volumePerc: Math.round((sink?.audio?.volume ?? 0) * 100)

    readonly property bool micMuted: source?.audio?.muted ?? false
    readonly property real micVolume: source?.audio?.volume ?? 0
    readonly property real micVolumePerc: Math.round((source?.audio?.volume ?? 0) * 100)

    function setVolume(volume: real): void {
        if (sink?.ready && sink?.audio) {
            sink.audio.muted = false;
            sink.audio.volume = volume;
        }
    }

    function toggleMute(): void {
        if (sink?.ready && sink?.audio) {
            sink.audio.muted = !sink.audio.muted;
        }
    }

    function setMicVolume(volume: real): void {
        if (source?.ready && source?.audio) {
            source.audio.muted = false;
            source.audio.volume = volume;
        }
    }

    function toggleMicMute(): void {
        if (source?.ready && source?.audio) {
            source.audio.muted = !source.audio.muted;
        }
    }
}
