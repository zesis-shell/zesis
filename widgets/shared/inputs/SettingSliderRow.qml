pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../../"
import "../"

ColumnLayout {
    id: root

    property string label: ""
    property string valueText: ""
    property string glyph: ""
    property string description: ""
    property bool card: false
    property real from: 0
    property real to: 100
    property real step: 1
    property real value: 0
    signal moved(real value)

    Layout.fillWidth: true
    spacing: 0

    Loader {
        Layout.fillWidth: true
        active: !root.card
        visible: active
        sourceComponent: ColumnLayout {
            spacing: UIScale.spacingSm

            RowLayout {
                Layout.fillWidth: true
                spacing: UIScale.spacingSm

                Text {
                    text: root.label
                    color: Colors.text
                    font.pixelSize: UIScale.fontBody
                    font.bold: true
                    Layout.fillWidth: true
                }
                Rectangle {
                    visible: root.valueText.length > 0
                    implicitWidth: plainVal.implicitWidth + UIScale.spacingSm * 2
                    implicitHeight: plainVal.implicitHeight + UIScale.spacingXs
                    radius: UIScale.radiusSm
                    color: Colors.withAlpha(Colors.accent, 0.12)
                    Text {
                        id: plainVal
                        anchors.centerIn: parent
                        text: root.valueText
                        color: Colors.accent
                        font.pixelSize: UIScale.fontSmall
                        font.weight: Font.Bold
                        font.family: "monospace"
                    }
                }
            }

            SettingSlider {
                Layout.fillWidth: true
                from: root.from
                to: root.to
                step: root.step
                value: root.value
                onMoved: v => root.moved(v)
            }
        }
    }

    Loader {
        Layout.fillWidth: true
        active: root.card
        visible: active
        sourceComponent: Rectangle {
            Layout.fillWidth: true
            radius: UIScale.radiusMd
            color: Colors.withAlpha(Colors.text, 0.03)
            border.color: Colors.withAlpha(Colors.text, 0.06)
            border.width: 1
            implicitHeight: cardCol.implicitHeight + UIScale.spacingMd * 2

            ColumnLayout {
                id: cardCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: UIScale.spacingMd
                spacing: UIScale.spacingSm

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
                            text: root.label
                            color: Colors.text
                            font.pixelSize: UIScale.fontBody
                            font.weight: Font.DemiBold
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

                    Rectangle {
                        visible: root.valueText.length > 0
                        Layout.alignment: Qt.AlignTop
                        implicitWidth: cardVal.implicitWidth + UIScale.spacingSm * 2
                        implicitHeight: cardVal.implicitHeight + UIScale.spacingXs
                        radius: UIScale.radiusSm
                        color: Colors.withAlpha(Colors.accent, 0.12)
                        Text {
                            id: cardVal
                            anchors.centerIn: parent
                            text: root.valueText
                            color: Colors.accent
                            font.pixelSize: UIScale.fontSmall
                            font.weight: Font.Bold
                            font.family: "monospace"
                        }
                    }
                }

                SettingSlider {
                    Layout.fillWidth: true
                    from: root.from
                    to: root.to
                    step: root.step
                    value: root.value
                    onMoved: v => root.moved(v)
                }
            }
        }
    }
}
