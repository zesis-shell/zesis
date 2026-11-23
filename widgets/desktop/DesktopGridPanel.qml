pragma ComponentBehavior: Bound
import QtQuick
import "../../"
import "../shared/inputs"

// Snap submenu for the desktop overlay: grid style, opacity, and density (a preset, or manual columns
// and rows). It is the popup surface itself, opened from the Snap chevron, so it draws its own
// background, like the widget menu does.
Rectangle {
    id: root
    property bool open: false
    // The screen the grid is shown on. Going manual copies the counts this screen is using.
    property real screenW: 1
    property real screenH: 1

    readonly property real _pad: Math.round(UIScale.spacingMd)
    readonly property real _gap: Math.round(UIScale.spacingSm)

    width: Math.round(300 * UIScale.value)
    height: column.implicitHeight + root._pad * 2
    radius: UIScale.radiusMd
    color: Colors.surface
    border.width: 1
    border.color: Colors.withAlpha(Colors.text, 0.08)

    opacity: root.open ? 1 : 0
    visible: opacity > 0
    Behavior on opacity {
        NumberAnimation {
            duration: Anim.fast
        }
    }

    function _setManual() {
        var c = DesktopGridSettings.countsFor(root.screenW, root.screenH);
        DesktopGridSettings.setPreset("manual", c.cols, c.rows);
    }

    // A small caption above a control, with an optional readout on the right.
    component Caption: Item {
        property string text: ""
        property string readout: ""
        width: column.width
        height: captionText.implicitHeight

        Text {
            id: captionText
            anchors.left: parent.left
            text: parent.text
            color: Colors.textDim
            font.pixelSize: UIScale.fontCaption
        }
        Text {
            anchors.right: parent.right
            text: parent.readout
            color: Colors.textDim
            font.pixelSize: UIScale.fontCaption
        }
    }

    Column {
        id: column
        x: root._pad
        y: root._pad
        width: root.width - root._pad * 2
        spacing: root._gap

        Caption {
            text: I18n.t("desktop.gridStyle")
        }
        Flow {
            width: column.width
            spacing: Math.round(UIScale.spacingXs)

            DesktopToolButton {
                label: I18n.t("desktop.gridStyleNone")
                toggled: DesktopGridSettings.style === "none"
                onActivated: DesktopGridSettings.setStyle("none")
            }
            DesktopToolButton {
                label: I18n.t("desktop.gridStyleDots")
                toggled: DesktopGridSettings.style === "dots"
                onActivated: DesktopGridSettings.setStyle("dots")
            }
            DesktopToolButton {
                label: I18n.t("desktop.gridStyleLines")
                toggled: DesktopGridSettings.style === "lines"
                onActivated: DesktopGridSettings.setStyle("lines")
            }
            DesktopToolButton {
                label: I18n.t("desktop.gridStyleBoth")
                toggled: DesktopGridSettings.style === "both"
                onActivated: DesktopGridSettings.setStyle("both")
            }
        }

        Caption {
            text: I18n.t("desktop.gridOpacity")
            readout: Math.round(DesktopGridSettings.gridOpacity * 100) + "%"
        }
        SettingSlider {
            width: column.width
            from: 0
            to: 1
            step: 0.05
            value: DesktopGridSettings.gridOpacity
            onMoved: val => DesktopGridSettings.setGridOpacity(val)
        }

        Caption {
            text: I18n.t("desktop.gridSpacing")
        }
        Flow {
            width: column.width
            spacing: Math.round(UIScale.spacingXs)

            DesktopToolButton {
                label: I18n.t("desktop.gridPresetFine")
                toggled: DesktopGridSettings.preset === "fine"
                onActivated: DesktopGridSettings.setPreset("fine")
            }
            DesktopToolButton {
                label: I18n.t("desktop.gridPresetMedium")
                toggled: DesktopGridSettings.preset === "medium"
                onActivated: DesktopGridSettings.setPreset("medium")
            }
            DesktopToolButton {
                label: I18n.t("desktop.gridPresetCoarse")
                toggled: DesktopGridSettings.preset === "coarse"
                onActivated: DesktopGridSettings.setPreset("coarse")
            }
            DesktopToolButton {
                label: I18n.t("desktop.gridPresetManual")
                toggled: DesktopGridSettings.preset === "manual"
                onActivated: root._setManual()
            }
        }

        // Manual only: columns and rows are set separately.
        Column {
            width: column.width
            spacing: root._gap
            visible: DesktopGridSettings.preset === "manual"

            Caption {
                text: I18n.t("desktop.gridColumns")
                readout: DesktopGridSettings.columns.toString()
            }
            SettingSlider {
                width: column.width
                from: DesktopGridSettings.minColumns
                to: DesktopGridSettings.maxColumns
                step: 1
                value: DesktopGridSettings.columns
                onMoved: val => DesktopGridSettings.setColumns(Math.round(val))
            }

            Caption {
                text: I18n.t("desktop.gridRows")
                readout: DesktopGridSettings.rows.toString()
            }
            SettingSlider {
                width: column.width
                from: DesktopGridSettings.minRows
                to: DesktopGridSettings.maxRows
                step: 1
                value: DesktopGridSettings.rows
                onMoved: val => DesktopGridSettings.setRows(Math.round(val))
            }
        }
    }
}
