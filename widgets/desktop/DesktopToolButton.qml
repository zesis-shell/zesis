pragma ComponentBehavior: Bound
import QtQuick
import "../../"

// Pill button for the desktop overlay's toolbar. Three looks: a plain tool (undo, redo),
// a toggled tool (snap, while it is on), and the primary action (Done). Disabled dims and
// ignores input. Icon is a Material Symbols Rounded ligature name.
Item {
    id: root
    signal activated

    property string icon: ""
    property string label: ""
    property bool toggled: false
    property bool primary: false
    // Icon-only chevrons: tighter padding.
    property bool compact: false

    readonly property real _h: Math.round(36 * UIScale.value)
    readonly property color _fg: root.primary ? Colors.bg : (root.toggled ? Colors.accent : Colors.text)

    implicitWidth: content.implicitWidth + Math.round((root.compact ? UIScale.spacingXs : UIScale.spacingMd) * 2)
    implicitHeight: root._h
    opacity: root.enabled ? 1.0 : 0.4
    Behavior on opacity {
        NumberAnimation {
            duration: Anim.fast
        }
    }

    Rectangle {
        id: face
        anchors.fill: parent
        radius: height / 2
        color: root.primary
            ? (tap.pressed ? Colors.withAlpha(Colors.accent, 0.7) : (hover.hovered ? Colors.withAlpha(Colors.accent, 0.85) : Colors.accent))
            : root.toggled
                ? Colors.withAlpha(Colors.accent, tap.pressed ? 0.3 : (hover.hovered ? 0.22 : 0.16))
                : Colors.withAlpha(Colors.text, tap.pressed ? 0.14 : (hover.hovered ? 0.08 : 0))

        Behavior on color {
            ColorAnimation {
                duration: Anim.fast
            }
        }

        Row {
            id: content
            anchors.centerIn: parent
            spacing: Math.round(UIScale.spacingXs)

            Text {
                id: iconText
                anchors.verticalCenter: parent.verticalCenter
                visible: root.icon !== ""
                text: root.icon
                font.family: "Material Symbols Rounded"
                font.pixelSize: Math.round(18 * UIScale.value)
                color: root._fg
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: root.label !== ""
                text: root.label
                color: root._fg
                font.pixelSize: UIScale.fontSmall
                font.weight: root.primary ? Font.Medium : Font.Normal
            }
        }
    }

    HoverHandler {
        id: hover
        enabled: root.enabled
    }
    TapHandler {
        id: tap
        enabled: root.enabled
        onTapped: root.activated()
    }
}
