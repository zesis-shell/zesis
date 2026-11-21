pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../"

// Bordered card with a header (leading icon, title, one-line description and
// an optional right-aligned actions slot) sitting above a content column.
// The standard grouping container for settings panels.
Rectangle {
    id: root

    property string glyph: ""
    property string title: ""
    property string description: ""
    property Component headerActions: null
    property real contentSpacing: UIScale.spacingSm

    default property alias content: inner.data

    Layout.fillWidth: true
    radius: UIScale.radiusMd
    color: Colors.withAlpha(Colors.text, 0.03)
    border.color: Colors.withAlpha(Colors.text, 0.06)
    border.width: 1
    implicitHeight: outer.implicitHeight + UIScale.spacingMd * 2

    ColumnLayout {
        id: outer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: UIScale.spacingMd
        spacing: UIScale.spacingMd

        RowLayout {
            Layout.fillWidth: true
            spacing: UIScale.spacingSm

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
                Layout.alignment: Qt.AlignTop
                sourceComponent: root.headerActions
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Colors.withAlpha(Colors.text, 0.06)
        }

        ColumnLayout {
            id: inner
            Layout.fillWidth: true
            spacing: root.contentSpacing
        }
    }
}
