import QtQuick
import "../../"
import "../bar"
import "../shared"

BarButton {
    id: root
    active: popup.visible
    onClicked: popup.visible ? popup.close() : popup.open()

    icon: AudioService.icon

    WheelHandler {
        onWheel: function (w) {
            var audio = AudioService.sink?.audio;
            if (!audio)
                return;
            audio.volume = Math.max(0, Math.min(1.5, audio.volume + w.angleDelta.y / 1200.0));
        }
    }

    AnimatedPopup {
        id: popup
        anchorItem: root
        implicitWidth: 300
        implicitHeight: 320
        content: Component {
            Sound {}
        }
    }
}
