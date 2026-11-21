pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../../"
import "../bar"
import "../shared"
import "../shared/inputs"

Item {
    id: root

    readonly property bool _twoCol: width > Math.round(760 * UIScale.value)
    readonly property var _leftCats: BarItemsService.categories.filter((c, i) => i % 2 === 0)
    readonly property var _rightCats: BarItemsService.categories.filter((c, i) => i % 2 === 1)

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        PanelHeader {
            Layout.fillWidth: true
            breadcrumb: I18n.t("bar.breadcrumb")
            title: I18n.t("bar.title")
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: content.implicitHeight + UIScale.spacingLg * 2
            clip: true
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            ColumnLayout {
                id: content
                x: UIScale.panelPad
                y: UIScale.spacingLg
                width: root.width - UIScale.panelPad * 2
                spacing: UIScale.spacingMd

                // Bar position
                SettingsSection {
                    glyph: "dock"
                    title: I18n.t("bar.side")
                    description: I18n.t("bar.sideDescription")

                    OptionRow {
                        Layout.fillWidth: true
                        model: [I18n.t("bar.top"), I18n.t("bar.bottom"), I18n.t("bar.left"), I18n.t("bar.right")]
                        currentIndex: ["top", "bottom", "left", "right"].indexOf(BarConfig.side)
                        onActivated: index => BarConfig.patch({
                                side: ["top", "bottom", "left", "right"][index]
                            })
                    }
                }

                // Bar layout
                SettingsSection {
                    glyph: "view_quilt"
                    title: I18n.t("bar.layout")
                    description: I18n.t("bar.layoutDescription")
                    contentSpacing: UIScale.spacingMd

                    SettingRow {
                        glyph: "view_stream"
                        title: I18n.t("bar.showStrip")
                        description: I18n.t("bar.showStripDescription")
                        ToggleSwitch {
                            checked: BarConfig.showStrip
                            onToggled: BarConfig.patch({
                                showStrip: !BarConfig.showStrip
                            })
                        }
                    }
                    SettingRow {
                        glyph: "view_module"
                        title: I18n.t("bar.showIslands")
                        description: I18n.t("bar.showIslandsDescription")
                        ToggleSwitch {
                            checked: BarConfig.showIslands
                            onToggled: BarConfig.patch({
                                showIslands: !BarConfig.showIslands
                            })
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columnSpacing: UIScale.spacingMd
                        rowSpacing: UIScale.spacingMd
                        columns: root.width > Math.round(880 * UIScale.value) ? 3 : (root.width > Math.round(560 * UIScale.value) ? 2 : 1)

                        SettingSliderRow {
                            Layout.fillWidth: true
                            card: true
                            visible: BarConfig.showStrip
                            glyph: "border_outer"
                            label: I18n.t("bar.stripMargin")
                            description: I18n.t("bar.stripMarginDescription")
                            valueText: BarConfig.stripMargin + "px"
                            from: 0
                            to: 20
                            step: 1
                            value: BarConfig.stripMargin
                            onMoved: v => BarConfig.patch({
                                    stripMargin: Math.round(v)
                                })
                        }
                        SettingSliderRow {
                            Layout.fillWidth: true
                            card: true
                            visible: BarConfig.showIslands
                            glyph: "rounded_corner"
                            label: I18n.t("bar.islandRoundness")
                            description: I18n.t("bar.islandRoundnessDescription")
                            valueText: I18n.t("appearance.multiplier", [BarConfig.islandRoundness.toFixed(2)])
                            from: 0
                            to: 1.0
                            step: 0.05
                            value: BarConfig.islandRoundness
                            onMoved: v => BarConfig.patch({
                                    islandRoundness: v
                                })
                        }
                        SettingSliderRow {
                            Layout.fillWidth: true
                            card: true
                            glyph: "format_indent_increase"
                            label: I18n.t("bar.edgeGap")
                            description: I18n.t("bar.edgeGapDescription")
                            valueText: BarConfig.edgeGap + "px"
                            from: 0
                            to: 40
                            step: 1
                            value: BarConfig.edgeGap
                            onMoved: v => BarConfig.patch({
                                    edgeGap: Math.round(v)
                                })
                        }
                        SettingSliderRow {
                            Layout.fillWidth: true
                            card: true
                            glyph: "format_indent_decrease"
                            label: I18n.t("bar.endGap")
                            description: I18n.t("bar.endGapDescription")
                            valueText: BarConfig.endGap + "px"
                            from: 0
                            to: 60
                            step: 1
                            value: BarConfig.endGap
                            onMoved: v => BarConfig.patch({
                                    endGap: Math.round(v)
                                })
                        }
                    }
                }

                // Bar monitor
                SettingsSection {
                    visible: Quickshell.screens.length > 1
                    glyph: "desktop_windows"
                    title: I18n.t("bar.monitor")
                    description: I18n.t("bar.monitorDescription")

                    Repeater {
                        model: Quickshell.screens
                        delegate: SettingRow {
                            id: monitorRow
                            required property var modelData
                            readonly property string _name: monitorRow.modelData.name
                            glyph: "desktop_windows"
                            title: monitorRow._name
                            description: monitorRow.modelData.width + "×" + monitorRow.modelData.height

                            ToggleSwitch {
                                checked: BarConfig.monitors.length === 0 || BarConfig.monitors.includes(monitorRow._name)
                                onToggled: {
                                    var current = BarConfig.monitors.length === 0 ? Quickshell.screens.map(s => s.name) : BarConfig.monitors.slice();
                                    var idx = current.indexOf(monitorRow._name);
                                    if (idx >= 0) {
                                        if (current.length <= 1)
                                            return;
                                        current.splice(idx, 1);
                                    } else {
                                        current.push(monitorRow._name);
                                    }
                                    if (current.length === Quickshell.screens.length)
                                        current = [];
                                    BarConfig.patch({
                                        monitors: current
                                    });
                                }
                            }
                        }
                    }
                }

                // Bar items header
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: UIScale.spacingXs
                    spacing: UIScale.spacingSm

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Math.round(2 * UIScale.value)
                        Text {
                            text: I18n.t("bar.items")
                            color: Colors.text
                            font.pixelSize: UIScale.fontSubhead
                            font.weight: Font.DemiBold
                        }
                        Text {
                            Layout.fillWidth: true
                            text: I18n.t("bar.itemsDescription")
                            color: Colors.muted
                            font.pixelSize: UIScale.fontSmall
                            wrapMode: Text.WordWrap
                        }
                    }

                    ActionButton {
                        ghost: true
                        label: I18n.t("bar.resetToDefault")
                        onActivated: BarItemsService.resetToDefault()
                    }
                }

                // Category cards - two masonry columns when wide, one otherwise
                RowLayout {
                    Layout.fillWidth: true
                    visible: root._twoCol
                    spacing: UIScale.spacingMd

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: UIScale.spacingMd
                        Repeater {
                            model: root._twoCol ? root._leftCats : []
                            delegate: CategoryCard {
                                required property var modelData
                                cat: modelData
                            }
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: UIScale.spacingMd
                        Repeater {
                            model: root._twoCol ? root._rightCats : []
                            delegate: CategoryCard {
                                required property var modelData
                                cat: modelData
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    visible: !root._twoCol
                    spacing: UIScale.spacingMd
                    Repeater {
                        model: root._twoCol ? [] : BarItemsService.categories
                        delegate: CategoryCard {
                            required property var modelData
                            cat: modelData
                        }
                    }
                }
            }
        }
    }

    component CategoryCard: CollapsibleSection {
        id: catCard
        required property var cat

        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        glyph: catCard.cat.icon
        title: catCard.cat.label
        description: catCard.cat.desc

        Repeater {
            model: BarItemsService.itemsByCategory[catCard.cat.id]
            delegate: SettingRow {
                id: itemRow
                required property var modelData
                glyph: itemRow.modelData.icon
                title: itemRow.modelData.label
                description: itemRow.modelData.desc
                menuActions: [
                    {
                        label: BarItemsService.isPinned(itemRow.modelData.id) ? I18n.t("bar.unpinFromCenter") : I18n.t("bar.pinToCenter"),
                        action: function () {
                            BarItemsService.togglePin(itemRow.modelData.id);
                        }
                    }
                ]

                ToggleSwitch {
                    checked: BarItemsService.isEnabled(itemRow.modelData.id)
                    onToggled: BarItemsService.toggle(itemRow.modelData.id)
                }
            }
        }
    }
}
