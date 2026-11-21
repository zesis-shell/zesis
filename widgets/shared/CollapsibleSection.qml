pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../"

// SettingsSection with a collapsible body. Clicking the header toggles
// `expanded`, the body clips and animates its height. `headerActions` sits
// to the left of the chevron and does not toggle the section.
Rectangle {
    id: root

    property string glyph: ""
    property string title: ""
    property string description: ""
    property Component headerActions: null
    property bool expanded: true
    property real contentSpacing: UIScale.spacingSm

    default property alias content: inner.data

    Layout.fillWidth: true
    radius: UIScale.radiusMd
    color: Colors.withAlpha(Colors.text, 0.03)
    border.color: Colors.withAlpha(Colors.text, 0.06)
    border.width: 1
    implicitHeight: outer.implicitHeight + UIScale.spacingMd * 2
    clip: true

    ColumnLayout {
        id: outer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: UIScale.spacingMd
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            spacing: UIScale.spacingSm

            // Whole header toggles, except children that grab the press
            // themselves (the headerActions button).
            TapHandler {
                onTapped: root.expanded = !root.expanded
            }
            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }

            IconChip {
                visible: root.glyph.length > 0
                glyph: root.glyph
                Layout.alignment: Qt.AlignTop
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Math.round(2 * UIScale.value)

                Text {
                    Layout.fillWidth: true
                    text: root.title
                    color: Colors.text
                    font.pixelSize: UIScale.fontSubhead
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    visible: root.description.length > 0
                    text: root.description
                    color: Colors.muted
                    font.pixelSize: UIScale.fontSmall
                    wrapMode: Text.WordWrap
                }
            }

            Loader {
                Layout.alignment: Qt.AlignVCenter
                sourceComponent: root.headerActions
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: "expand_more"
                font.family: "Material Symbols Rounded"
                font.pixelSize: Math.round(20 * UIScale.value)
                color: Colors.textDim
                rotation: root.expanded ? 0 : -90
                Behavior on rotation {
                    NumberAnimation {
                        duration: Anim.medium
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Anim.standard
                    }
                }
            }
        }

        // Divider + content collapse together as one clipped block, so the
        // collapsed card is exactly the header plus the card's own padding.
        Item {
            id: bodyClip
            Layout.fillWidth: true
            clip: true
            Layout.preferredHeight: root.expanded ? inner.implicitHeight : 0
            opacity: root.expanded ? 1 : 0
            Behavior on Layout.preferredHeight {
                NumberAnimation {
                    duration: Anim.medium
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Anim.standard
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: Anim.fast
                }
            }

            ColumnLayout {
                id: inner
                width: bodyClip.width
                y: 0
                spacing: root.contentSpacing

                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: UIScale.spacingMd
                    Layout.bottomMargin: Math.max(0, UIScale.spacingMd - root.contentSpacing)
                    implicitHeight: 1
                    color: Colors.withAlpha(Colors.text, 0.06)
                }
            }
        }
    }
}
