pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "./"
import "../globe2d"
import "../../"

// Small WlrLayer.Bottom surface positioned anywhere on screen. Click-through
// by default, a widget that needs pointer input (currently only the Globe in
// manual-rotate mode, see _wantsInput below) gets a full-size input region
// instead. In config mode this surface hides, DesktopConfigOverlay renders a
// draggable proxy instead, then writes the new position back to
// DesktopWidgetStore on drag end.
PanelWindow {
    id: root

    property string storeKey: ""
    property Component content: null

    // Reactive bg config, re-evaluates whenever _positions changes.
    property var _bgConfig: {
        var _ = DesktopWidgetStore._positions;
        return DesktopWidgetStore.getBgConfig(root.storeKey);
    }
    property bool _hasBg: _bgConfig.enabled
    readonly property real _bgPad: _hasBg ? Math.round(10 * UIScale.value) : 0

    // User-set fixed size in ref px, independent per axis. 0 = auto (content's own implicit size).
    // Forcing a size here is what lets a fillsBox component (cava) reflow to the box
    // instead of sitting at its natural size inside a bigger one.
    property var _size: {
        var _ = DesktopWidgetStore._positions;
        return DesktopWidgetStore.getSize(root.storeKey);
    }
    readonly property bool _overrideW: _size.w > 0
    readonly property bool _overrideH: _size.h > 0

    // Natural footprint in ref px (content + bg padding). The reference footprint is the
    // fixed size when one is set, otherwise the natural size. fractionFor resolves stored
    // positions against it.
    readonly property real _natW: (contentLoader.item?.implicitWidth ?? 0) + root._bgPad * 2
    readonly property real _natH: (contentLoader.item?.implicitHeight ?? 0) + root._bgPad * 2
    readonly property real _refW: (root._overrideW ? root._size.w : (contentLoader.item?.implicitWidth ?? 0)) + root._bgPad * 2
    readonly property real _refH: (root._overrideH ? root._size.h : (contentLoader.item?.implicitHeight ?? 0)) + root._bgPad * 2

    // Screen box and content scale, see DesktopWidgetStore.boxFor. Not affected by the
    // 1x1 minimal-size trick below, so the position doesn't jump when the widget wakes up.
    // fillsBox content (cava) reflows to the box, everything else scales to fit it.
    readonly property bool _fillsBox: contentLoader.item?.fillsBox ?? false
    readonly property var _box: DesktopWidgetStore.boxFor(root._natW, root._natH, root._overrideW ? root._size.w : 0, root._overrideH ? root._size.h : 0, root._bgPad, screen.width, screen.height, root._fillsBox)

    // Top-left as a screen fraction, clamped so the widget stays on screen.
    readonly property var _frac: {
        var _ = DesktopWidgetStore._positions;
        return DesktopWidgetStore.fractionFor(root.storeKey, root._refW, root._refH);
    }
    readonly property real _marginLeft: Math.max(0, Math.min(root._frac.x * screen.width, screen.width - root._box.w))
    readonly property real _marginTop: Math.max(0, Math.min(root._frac.y * screen.height, screen.height - root._box.h))

    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "zesis:desktop:" + storeKey

    anchors {
        top: true
        left: true
    }
    margins {
        top: Math.round(root._marginTop)
        left: Math.round(root._marginLeft)
    }

    // This is used for the 1x1 trick to save on VRAM (cava)
    readonly property bool _wantsMinimalSize: contentLoader.item?.wantsMinimalSize ?? false

    implicitWidth: root._wantsMinimalSize ? 1 : root._box.w
    implicitHeight: root._wantsMinimalSize ? 1 : root._box.h

    exclusiveZone: -1
    color: "transparent"

    // Widget-specific opt-in for pointer input, gated on storeKey like the
    // per-widget settings rows in DesktopConfigOverlay. The Globe in
    // manual-rotate mode and the Vending Machine (keypad, glass taps, flap,
    // item press) both need real clicks.
    readonly property bool _wantsInput: (root.storeKey === "globe2d" && Globe2DSettings.rotateMode === "manual") || root.storeKey === "vending"

    Region {
        id: clickThrough
    }
    Region {
        id: fullInput
        x: 0
        y: 0
        width: root.width
        height: root.height
    }
    mask: root._wantsInput ? fullInput : clickThrough

    visible: !DesktopWidgetStore.configMode

    readonly property bool _skewEnabled: {
        var _ = DesktopWidgetStore._positions;
        return DesktopWidgetStore.getSkew(root.storeKey).enabled;
    }

    Item {
        id: skewHost
        anchors.fill: parent

        transform: Matrix4x4 {
            matrix: root._skewEnabled ? DesktopWidgetStore.cornerMatrix(root.storeKey, skewHost.width, skewHost.height) : Qt.matrix4x4()
        }

        DesktopWidgetBg {
            anchors.fill: parent
            bgConfig: root._bgConfig
        }

        // Fit mode: drawn at natural size, scaled to fit the box (see _box). Fill mode:
        // laid out at the box's real size, no scale. Either way it is centred in the box,
        // offset by the bg padding. width/height stay bound always, see
        // docs/qml-patterns.md #2 for why
        Loader {
            id: contentLoader
            x: root._box.dx + root._box.pad
            y: root._box.dy + root._box.pad
            transformOrigin: Item.TopLeft
            scale: root._box.s
            sourceComponent: root.content
            width: root._box.fill ? root._box.cw : (item?.implicitWidth ?? 0)
            height: root._box.fill ? root._box.ch : (item?.implicitHeight ?? 0)
        }
    }

    // Position is reactive to the store, so when config mode exits and the overlay
    // has moved us, the margins already reflect it.
}
