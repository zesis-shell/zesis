pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../"

// One setting: leading icon, title + description, a right-aligned control
// slot (default children) and an optional overflow menu.
//
//   SettingRow {
//       glyph: "wifi"; title: "..."; description: "..."
//       menuActions: [{ label: "Pin", action: () => ... }]
//       ToggleSwitch { ... }
//   }
Item {
    id: root

    property string glyph: ""
    property string title: ""
    property string description: ""
    // [{ label: string, danger?: bool, action: function }]
    property var menuActions: []

    default property alias control: controlSlot.data

    Layout.fillWidth: true
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: Math.max(Math.round(40 * UIScale.value), rowLayout.implicitHeight)

    RowLayout {
        id: rowLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: UIScale.spacingSm

        IconChip {
            visible: root.glyph.length > 0
            glyph: root.glyph
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Math.round(1 * UIScale.value)

            Text {
                Layout.fillWidth: true
                text: root.title
                color: Colors.text
                font.pixelSize: UIScale.fontBody
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                visible: root.description.length > 0
                text: root.description
                color: Colors.muted
                font.pixelSize: UIScale.fontTiny
                wrapMode: Text.WordWrap
            }
        }

        Item {
            id: controlSlot
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
        }

        // Overflow menu
        Item {
            visible: root.menuActions.length > 0
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: Math.round(26 * UIScale.value)
            implicitHeight: Math.round(26 * UIScale.value)

            Rectangle {
                anchors.fill: parent
                radius: UIScale.radiusSm
                color: menuHover.hovered || menu.opened ? Colors.withAlpha(Colors.text, 0.1) : "transparent"
                Behavior on color {
                    ColorAnimation {
                        duration: Anim.fast
                    }
                }
                Text {
                    anchors.centerIn: parent
                    text: "more_vert"
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: Math.round(16 * UIScale.value)
                    color: Colors.textDim
                }
            }

            HoverHandler {
                id: menuHover
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: menu.opened ? menu.close() : menu.open()
            }

            Popup {
                id: menu
                y: parent.height + UIScale.spacingXs
                x: parent.width - width
                padding: Math.round(4 * UIScale.value)
                modal: false
                focus: true
                // CloseOnPressOutsideParent (not CloseOnPressOutside) so that a press
                // on this button - the popup's parent - never counts as "outside" and
                // re-triggers a close+reopen on the same click that's meant to close it.
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

                background: Rectangle {
                    radius: UIScale.radiusMd
                    color: Colors.bg
                    border.color: Colors.outline
                    border.width: 1
                }

                contentItem: ColumnLayout {
                    spacing: 0

                    Repeater {
                        model: root.menuActions

                        delegate: Item {
                            id: mi
                            required property var modelData
                            Layout.fillWidth: true
                            implicitWidth: Math.max(Math.round(150 * UIScale.value), miLabel.implicitWidth + UIScale.spacingMd * 2)
                            implicitHeight: Math.round(32 * UIScale.value)

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: Math.round(1 * UIScale.value)
                                radius: UIScale.radiusSm
                                color: miHover.hovered ? Colors.withAlpha(Colors.text, 0.08) : "transparent"
                            }
                            Text {
                                id: miLabel
                                anchors.left: parent.left
                                anchors.leftMargin: UIScale.spacingSm
                                anchors.verticalCenter: parent.verticalCenter
                                text: mi.modelData.label
                                color: mi.modelData.danger ? Colors.error : Colors.text
                                font.pixelSize: UIScale.fontSmall
                            }
                            HoverHandler {
                                id: miHover
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    menu.close();
                                    if (mi.modelData.action)
                                        mi.modelData.action();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
