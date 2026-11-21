import QtQuick
import "../bar"

// Bar atom
BarButton {
    icon: LockService.icon
    onClicked: LockService.triggerLock()
}
