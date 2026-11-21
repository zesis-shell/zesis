pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string identityIcon: "lock"

    signal lockRequested
    function triggerLock() {
        root.lockRequested();
    }

    readonly property string icon: "lock"
}
