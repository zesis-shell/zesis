pragma ComponentBehavior: Bound
import QtQuick
import "../../"

// Rounded-square Material-icon tile used as the leading glyph on section
// headers, setting rows and slider cards. `glyph` is a Material Symbols Rounded
// ligature name (e.g. "wifi", "palette") - not a codepoint.
Item {
    id: root

    property string glyph: ""
    property real size: Math.round(34 * UIScale.value)
    property bool accent: false
    property real glyphSize: Math.round(root.size * 0.52)

    implicitWidth: root.size
    implicitHeight: root.size

    Rectangle {
        anchors.fill: parent
        radius: UIScale.radiusSm
        color: root.accent ? Colors.withAlpha(Colors.accent, 0.14) : Colors.withAlpha(Colors.text, 0.05)
        border.width: 1
        border.color: root.accent ? Colors.withAlpha(Colors.accent, 0.24) : Colors.withAlpha(Colors.text, 0.06)

        Text {
            anchors.centerIn: parent
            text: root.glyph
            font.family: "Material Symbols Rounded"
            font.pixelSize: root.glyphSize
            color: root.accent ? Colors.accent : Colors.textDim
        }
    }
}
