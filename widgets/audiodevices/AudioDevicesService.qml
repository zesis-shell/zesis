pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import "airpods"

// Unified view over the connected earbud backend. AirPods is the only one for now.
Singleton {
    id: root

    // "airpods" | ""
    readonly property string source: AirPodsService.connected ? "airpods" : ""
    readonly property bool connected: source !== ""

    readonly property string deviceName: source === "airpods" ? (AirPodsService.deviceName || "AirPods") : ""

    readonly property int leftLevel: source === "airpods" ? AirPodsService.leftLevel : 0
    readonly property int rightLevel: source === "airpods" ? AirPodsService.rightLevel : 0
    readonly property int caseLevel: source === "airpods" ? AirPodsService.caseLevel : 0
    readonly property bool hasCase: caseLevel > 0

    readonly property bool leftCharging: source === "airpods" && AirPodsService.leftCharging
    readonly property bool rightCharging: source === "airpods" && AirPodsService.rightCharging
    readonly property bool caseCharging: source === "airpods" && AirPodsService.caseCharging

    readonly property bool leftEar: source === "airpods" && AirPodsService.leftEar
    readonly property bool rightEar: source === "airpods" && AirPodsService.rightEar

    // Header glyph: in-ear state while connected, the backend's identity icon otherwise.
    readonly property string icon: source === "airpods" ? AirPodsService.stateIcon : AirPodsService.identityIcon
}
