pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../"

// Labelled battery bar for one earbud/case component (left / right / case).
ColumnLayout {
    id: root

    property string label: ""
    property int level: 0
    property bool charging: false
    property bool inEar: true
    // Material Symbols ligature shown before the label; empty hides it
    property string icon: ""

    // Fill fraction is animated, and the pixel width is derived from the live track
    // width. A resize then reflows the fill at once instead of animating toward it.
    property real _animLevel: root.level
    Behavior on _animLevel {
        NumberAnimation {
            duration: Anim.slow
            easing.type: Easing.OutCubic
        }
    }

    spacing: Math.round(3 * UIScale.value)

    RowLayout {
        Layout.fillWidth: true

        Text {
            visible: root.icon !== ""
            text: root.icon
            font.family: "Material Symbols Rounded"
            font.pixelSize: UIScale.fontSmall
            color: root.inEar ? Colors.text : Colors.textDim
            Layout.rightMargin: Math.round(4 * UIScale.value)
        }

        Text {
            text: root.label
            color: root.inEar ? Colors.text : Colors.textDim
            font.pixelSize: UIScale.fontTiny
            font.weight: Font.Medium
            Layout.fillWidth: true
            Behavior on color {
                ColorAnimation {
                    duration: Anim.fast
                }
            }
        }

        Text {
            visible: root.charging
            text: "bolt"
            font.family: "Material Symbols Rounded"
            font.pixelSize: UIScale.fontTiny
            color: Colors.accent
            Layout.rightMargin: Math.round(2 * UIScale.value)
        }

        Text {
            text: root.level + "%"
            color: root.charging ? Colors.accent : Colors.text
            font.pixelSize: UIScale.fontTiny
            font.weight: Font.DemiBold
            font.family: "monospace"
            Behavior on color {
                ColorAnimation {
                    duration: Anim.fast
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: Math.round(4 * UIScale.value)
        radius: 2
        color: Colors.surfaceHigh

        Rectangle {
            width: parent.width * (root._animLevel / 100)
            height: parent.height
            radius: parent.radius
            color: {
                if (root.charging)
                    return Colors.accent;
                if (root.level <= 15)
                    return "#e05c5c";
                if (root.level <= 30)
                    return "#e0a85c";
                return Colors.accent;
            }
            Behavior on color {
                ColorAnimation {
                    duration: Anim.fast
                }
            }
        }
    }
}
