import QtQuick
import "../../"

Item {
    // Unconditional, never gate on visible here. See docs/qml-patterns.md #1
    implicitWidth: Math.round(30 * UIScale.value)
    implicitHeight: Math.round(30 * UIScale.value)

    property string icon: ""
    property bool active: false
    property real iconOpacity: 1.0
    signal clicked

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: parent.clicked()
    }

    readonly property bool lit: mouseArea.containsMouse || active

    Text {
        anchors.centerIn: parent
        text: parent.icon
        renderType: Text.NativeRendering
        font.family: "Material Symbols Rounded"
        font.hintingPreference: Font.PreferNoHinting
        font.pixelSize: Math.round(15 * UIScale.value)
        font.variableAxes: ({
                "FILL": parent.lit ? 1 : 0,
                "opsz": Math.round(15 * UIScale.value)
            })
        opacity: parent.iconOpacity
        color: parent.lit ? Colors.accent : Colors.text
        Behavior on color {
            ColorAnimation {
                duration: Anim.fast
            }
        }
    }
}
