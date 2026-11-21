pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property string identityIcon: "mic"

    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property real vol: source?.audio?.volume ?? 0
    readonly property bool muted: source?.audio?.muted ?? false

    readonly property string icon: muted ? "mic_off" : "mic"

    PwObjectTracker {
        objects: [root.source]
    }
}
