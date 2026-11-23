pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool configMode: false

    // Ordered list of active widget keys.
    property var enabledKeys: []
    onEnabledKeysChanged: root._syncEnabledModel()

    // Mirror of enabledKeys that the desktop windows (shell.qml) and the overlay proxies
    // iterate. It is updated by diffing, so only the keys that came or went are created
    // or destroyed. Handing a delegate model a new JS array rebuilds every delegate,
    // which tore down every cava instance and restarted the cava process on each change.
    readonly property ListModel enabledModel: ListModel {}

    function _syncEnabledModel() {
        var want = root.enabledKeys;
        for (var i = root.enabledModel.count - 1; i >= 0; i--) {
            if (want.indexOf(root.enabledModel.get(i).widgetKey) === -1)
                root.enabledModel.remove(i);
        }
        for (var j = 0; j < want.length; j++) {
            var found = -1;
            for (var m = j; m < root.enabledModel.count; m++) {
                if (root.enabledModel.get(m).widgetKey === want[j]) {
                    found = m;
                    break;
                }
            }
            if (found === -1)
                root.enabledModel.insert(j, {
                    widgetKey: want[j]
                });
            else if (found !== j)
                root.enabledModel.move(found, j, 1);
        }
    }

    // { "key": { x, y, size, skew, bg } }
    //   x, y: top-left as a 0..1 fraction of the screen (see fractionFor)
    //   size: { w, h } in reference pixels, 0 = auto
    // An entry may carry nx/ny (slack ratios) instead of x/y. fractionFor reads both.
    property var _positions: ({})

    // Every widget is laid out in reference pixels, then drawn at scaleFor(screen).
    // The reference is 3840x2160, so at that resolution the scale is 1. Any other resolution scales
    // the whole widget uniformly, keeping its proportions and place on screen.
    readonly property real refWidth: 3840
    readonly property real refHeight: 2160

    function scaleFor(screenW, screenH) {
        if (!(screenW > 0) || !(screenH > 0))
            return 1;
        return Math.min(screenW / refWidth, screenH / refHeight);
    }

    // The box a widget occupies on screen, and how its content is drawn inside it.
    // natW/natH: natural footprint in ref px (content + bg padding).
    // ovW/ovH: the allocated box in ref px, 0 = auto on that axis.
    // padC: bg padding in ref px. fill: the content reflows to whatever size it is given
    // (fillsBox), so it is laid out at real px and not scaled.
    // Otherwise the content is scaled uniformly to fit the box, and a bigger box means
    // bigger content. The box is centred on the footprint when the aspect ratios differ.
    // Auto on both axes keeps the plain screen scale.
    // Returns { fill, s, w, h, dx, dy, pad, cw, ch }: w/h the box in screen px, s the
    // content scale, dx/dy the footprint offset in the box, pad the bg padding in screen px,
    // cw/ch the content box in screen px (fill mode only).
    function boxFor(natW, natH, ovW, ovH, padC, screenW, screenH, fill) {
        var k = scaleFor(screenW, screenH);
        var bw = ovW > 0 ? ovW * screenW / refWidth : 0;
        var bh = ovH > 0 ? ovH * screenH / refHeight : 0;
        if (fill) {
            var pad = padC * k;
            var fw = bw > 0 ? bw : natW * k;
            var fh = bh > 0 ? bh : natH * k;
            return {
                fill: true,
                s: 1,
                w: Math.round(fw),
                h: Math.round(fh),
                dx: 0,
                dy: 0,
                pad: pad,
                cw: Math.round(fw) - 2 * pad,
                ch: Math.round(fh) - 2 * pad
            };
        }
        var sx = (bw > 0 && natW > 0) ? bw / natW : Infinity;
        var sy = (bh > 0 && natH > 0) ? bh / natH : Infinity;
        var s = Math.min(sx, sy);
        if (s === Infinity)
            s = k;
        var w = bw > 0 ? bw : natW * s;
        var h = bh > 0 ? bh : natH * s;
        return {
            fill: false,
            s: s,
            w: Math.round(w),
            h: Math.round(h),
            dx: (w - natW * s) / 2,
            dy: (h - natH * s) / 2,
            pad: padC * s,
            cw: 0,
            ch: 0
        };
    }

    readonly property string _configDir: (Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")) + "/zesis"
    readonly property string _path: _configDir + "/desktop-widgets.json"
    readonly property string _historyPath: _configDir + "/desktop-widgets-history.json"
    readonly property string _bgCacheDir: _configDir + "/bg"

    // Top-left of a widget as a 0..1 fraction of the screen. cw/ch are its
    // footprint in reference pixels (content + bg padding). Entries with nx/ny hold a
    // slack ratio of (refW - cw) and resolve against the reference canvas, so they
    // land where the same ratio puts them on the 3840x2160 layout.
    function fractionFor(key, cw, ch) {
        var p = _positions[key];
        if (p && p.x !== undefined && p.y !== undefined)
            return {
                x: p.x,
                y: p.y
            };
        var nx = p?.nx ?? 0.5;
        var ny = p?.ny ?? 0.5;
        return {
            x: nx * Math.max(0, refWidth - cw) / refWidth,
            y: ny * Math.max(0, refHeight - ch) / refHeight
        };
    }

    function setPos(key, x, y) {
        _coalesceTag = "";
        _writePos(key, x, y);
        _save();
    }

    function _writePos(key, x, y) {
        var copy = Object.assign({}, _positions);
        var entry = Object.assign({}, copy[key] || {}, {
            x: Math.max(0.0, Math.min(1.0, x)),
            y: Math.max(0.0, Math.min(1.0, y))
        });
        delete entry.nx;
        delete entry.ny;
        copy[key] = entry;
        _positions = copy;
    }

    // We fold rapid taps into one move
    property real _coalesceUntil: 0
    property string _coalesceTag: ""

    function setPosCoalesced(key, x, y, tag) {
        var now = Date.now();
        var fold = (tag !== "" && tag === _coalesceTag && now < _coalesceUntil);
        _coalesceUntil = now + 450;
        _coalesceTag = tag;
        _writePos(key, x, y);
        if (fold)
            _quietSave();
        else
            _save();
    }

    // 0 means "auto" (use the content's own implicit size) for that axis independently
    function getSize(key) {
        var s = _positions[key]?.size;
        return {
            w: s?.w ?? 0,
            h: s?.h ?? 0
        };
    }

    function setSize(key, w, h) {
        var copy = Object.assign({}, _positions);
        copy[key] = Object.assign({}, copy[key] || {}, {
            size: {
                w: Math.max(0, Math.round(w || 0)),
                h: Math.max(0, Math.round(h || 0))
            }
        });
        _positions = copy;
        _save();
    }

    // Skew (4-corner perspective warp)
    function _zeroCorner() {
        return {
            x: 0,
            y: 0
        };
    }

    function getSkew(key) {
        var s = _positions[key]?.skew;
        function c(v) {
            return {
                x: Math.max(-1, Math.min(2, v?.x ?? 0)),
                y: Math.max(-1, Math.min(2, v?.y ?? 0))
            };
        }
        return {
            enabled: s?.enabled === true,
            tl: c(s?.tl),
            tr: c(s?.tr),
            br: c(s?.br),
            bl: c(s?.bl)
        };
    }

    function _writeSkew(key, patch) {
        var cur = getSkew(key);
        var next = Object.assign({}, cur, patch);
        var copy = Object.assign({}, _positions);
        copy[key] = Object.assign({}, copy[key] || {}, {
            skew: next
        });
        _positions = copy;
        _save();
    }

    function setSkewEnabled(key, on) {
        _writeSkew(key, {
            enabled: !!on
        });
    }

    function setSkewCorner(key, name, x, y) {
        if (name !== "tl" && name !== "tr" && name !== "br" && name !== "bl")
            return;
        var patch = {};
        patch[name] = {
            x: Math.max(-1, Math.min(2, x)),
            y: Math.max(-1, Math.min(2, y))
        };
        _writeSkew(key, patch);
    }

    function resetSkew(key) {
        _writeSkew(key, {
            tl: _zeroCorner(),
            tr: _zeroCorner(),
            br: _zeroCorner(),
            bl: _zeroCorner()
        });
    }

    // Heckbert mapping of local rect, [0,w]x[0,h] onto the quad defined by the
    // 4 vorner offsets.
    function cornerMatrixFrom(w, h, tl, tr, br, bl) {
        if (!(w >= 1) || !(h >= 1))
            return Qt.matrix4x4();
        var x0 = tl.x * w, y0 = tl.y * h;
        var x1 = w + tr.x * w, y1 = tr.y * h;
        var x2 = w + br.x * w, y2 = h + br.y * h;
        var x3 = bl.x * w, y3 = h + bl.y * h;

        var dx1 = x1 - x2, dx2 = x3 - x2, dx3 = x0 - x1 + x2 - x3;
        var dy1 = y1 - y2, dy2 = y3 - y2, dy3 = y0 - y1 + y2 - y3;

        var a, b, c, d, e, f, g, hh;
        if (Math.abs(dx3) < 1e-9 && Math.abs(dy3) < 1e-9) {
            a = x1 - x0;
            b = x2 - x1;
            c = x0;
            d = y1 - y0;
            e = y2 - y1;
            f = y0;
            g = 0;
            hh = 0;
        } else {
            var den = dx1 * dy2 - dx2 * dy1;
            if (Math.abs(den) < 1e-9)
                return Qt.matrix4x4();
            g = (dx3 * dy2 - dx2 * dy3) / den;
            hh = (dx1 * dy3 - dx3 * dy1) / den;
            a = x1 - x0 + g * x1;
            b = x3 - x0 + hh * x3;
            c = x0;
            d = y1 - y0 + g * y1;
            e = y3 - y0 + hh * y3;
            f = y0;
        }
        return Qt.matrix4x4(a / w, b / h, 0, c, d / w, e / h, 0, f, 0, 0, 1, 0, g / w, hh / h, 0, 1);
    }

    function cornerMatrix(key, w, h) {
        var s = getSkew(key);
        if (!s.enabled)
            return Qt.matrix4x4();
        return cornerMatrixFrom(w, h, s.tl, s.tr, s.br, s.bl);
    }

    function _defaultBgConfig() {
        return {
            enabled: false,
            type: "color",
            color: "",
            overlayOpacity: 0.4,
            imagePath: "",
            cachedImagePath: "",
            maskPath: ""
        };
    }

    function getBgConfig(key) {
        var bg = _positions[key]?.bg;
        if (!bg || typeof bg === 'boolean')
            return Object.assign(_defaultBgConfig(), {
                enabled: bg === true
            });
        return Object.assign(_defaultBgConfig(), bg);
    }

    // targetW/H are physical pixels (logical by devicePixelRatio) of the widget
    // background area, used to produce a tight-fit cached image. Omit (or pass 0)
    // when not changing the image path.
    function setBgConfig(key, config, targetW, targetH) {
        var oldConfig = getBgConfig(key);
        var imageChanged = config.imagePath !== oldConfig.imagePath;
        // Clear the cache pointer when the source path changes so the widget
        // falls back to the original while the new cached copy is being generated.
        if (imageChanged)
            config = Object.assign({}, config, {
                cachedImagePath: ""
            });
        var copy = Object.assign({}, _positions);
        copy[key] = Object.assign({}, copy[key] || {}, {
            bg: config
        });
        _positions = copy;
        _save();
        if (imageChanged && config.imagePath)
            _processBackground(key, config.imagePath, targetW || 0, targetH || 0);
    }

    property bool _magickAvailable: false
    property string _pendingBgKey: ""

    Process {
        id: magickCheck
        command: ["sh", "-c", "which magick >/dev/null 2>&1"]
        running: true
        onExited: code => {
            root._magickAvailable = (code === 0);
        }
    }

    Process {
        id: mkdirBgCache
        command: ["mkdir", "-p", root._bgCacheDir]
        running: true
    }

    // Resizes the chosen image to a display-appropriate size and saves to the
    // bg cache dir. The "> " geometry flag means "only shrink, never enlarge".
    Process {
        id: magickProc
        onExited: code => {
            if (code === 0 && root._pendingBgKey !== "") {
                var key = root._pendingBgKey;
                var cachedPath = root._bgCacheDir + "/" + key + ".png";
                var copy = Object.assign({}, root._positions);
                if (copy[key]?.bg && typeof copy[key].bg === 'object') {
                    copy[key] = Object.assign({}, copy[key]);
                    copy[key].bg = Object.assign({}, copy[key].bg, {
                        cachedImagePath: cachedPath
                    });
                    root._positions = copy;
                    root._quietSave();
                }
            }
            root._pendingBgKey = "";
        }
    }

    function _processBackground(key, imagePath, targetW, targetH) {
        if (!root._magickAvailable || !imagePath)
            return;
        // Use the widget's physical pixel dimensions (cover-fit geometry "WxH^").
        // Falls back to 1920x1080 if no size hint was supplied.
        var w = (targetW > 0) ? Math.round(targetW) : 1920;
        var h = (targetH > 0) ? Math.round(targetH) : 1080;
        root._pendingBgKey = key;
        magickProc.command = ["magick", imagePath, "-resize", w + "x" + h + "^", root._bgCacheDir + "/" + key + ".png"];
        magickProc.running = false;
        magickProc.running = true;
    }

    function enableWidget(key) {
        if (enabledKeys.indexOf(key) !== -1)
            return;
        enabledKeys = enabledKeys.concat([key]);
        _save();
    }

    // Drop from the widget menu: place at (x, y) and enable, as one undo step.
    // Works for an already enabled widget too, which then just moves.
    function placeWidget(key, x, y) {
        _coalesceTag = "";
        _writePos(key, x, y);
        if (enabledKeys.indexOf(key) === -1)
            enabledKeys = enabledKeys.concat([key]);
        _save();
    }

    function disableWidget(key) {
        enabledKeys = enabledKeys.filter(k => k !== key);
        _save();
    }

    function isEnabled(key) {
        return enabledKeys.indexOf(key) !== -1;
    }

    // Undo / redo
    // We take a snapshot on every comitted _save() that pushes the previous
    // state.
    property var _undo: []
    property var _redo: []
    property string _baseline: ""
    property bool _restoring: false
    readonly property int _histLimit: 200
    readonly property bool canUndo: _undo.length > 0
    readonly property bool canRedo: _redo.length > 0

    // The stacks are also written to their own file, so they survive closing the overlay and a
    // shell restart. The file records the layout they were taken from, and a history whose layout
    // no longer matches the file is dropped on load.
    function _persistHistory() {
        histFile.setText(JSON.stringify({
            current: root._baseline,
            undo: root._undo,
            redo: root._redo
        }));
    }

    function _loadHistory(text) {
        try {
            var obj = JSON.parse(text) || {};
            if (obj.current === root._baseline && Array.isArray(obj.undo) && Array.isArray(obj.redo)) {
                root._undo = obj.undo;
                root._redo = obj.redo;
            }
        } catch (_) {}
    }

    signal historyRestored

    function _serialize() {
        return JSON.stringify({
            enabled: enabledKeys,
            positions: _positions
        });
    }

    function _applySnapshot(s) {
        _restoring = true;
        _coalesceTag = "";
        try {
            var obj = JSON.parse(s) || {};
            root._positions = obj.positions || {};
            root.enabledKeys = obj.enabled || [];
            _save();
            _baseline = s;
        } catch (_) {}
        _restoring = false;
        historyRestored();
    }

    function undo() {
        if (_undo.length === 0)
            return;
        _redo = _redo.concat([_serialize()]);
        var s = _undo[_undo.length - 1];
        _undo = _undo.slice(0, -1);
        _applySnapshot(s);
        root._persistHistory();
    }

    function redo() {
        if (_redo.length === 0)
            return;
        _undo = _undo.concat([_serialize()]);
        var s = _redo[_redo.length - 1];
        _redo = _redo.slice(0, -1);
        _applySnapshot(s);
        root._persistHistory();
    }

    function _save() {
        var s = _serialize();
        posFile.setText(s);
        var pushed = false;
        if (!_restoring && _baseline !== "" && s !== _baseline) {
            _undo = _undo.concat([_baseline]);
            if (_undo.length > _histLimit)
                _undo = _undo.slice(-_histLimit);
            _redo = [];
            pushed = true;
        }
        _baseline = s;
        if (pushed)
            _persistHistory();
    }

    function _quietSave() {
        var was = _restoring;
        _restoring = true;
        _save();
        _restoring = was;
    }

    function _load(text) {
        if (!text) {
            root._baseline = root._serialize();
            return;
        }
        try {
            var obj = JSON.parse(text) || {};
            var positions = obj.positions || {};
            // Boolean bg values are converted to the config object.
            Object.keys(positions).forEach(function (k) {
                var p = positions[k];
                if (p && typeof p.bg === 'boolean')
                    p.bg = Object.assign(root._defaultBgConfig(), {
                        enabled: p.bg
                    });
            });
            root._positions = positions;
            root.enabledKeys = obj.enabled || [];
        } catch (_) {}
        root._baseline = root._serialize();
    }

    // Set while reloadFromDisk() is re-reading the file, see there.
    property bool _externalReload: false

    // Something else wrote the file (a profile apply copies it over). Re-read it, drop the undo
    // history (its states describe a layout that is no longer on disk), and tell the overlay's
    // proxies to rebind to the new positions.
    function reloadFromDisk() {
        root._externalReload = true;
        posFile.reload();
    }

    FileView {
        id: posFile
        path: root._path
        blockLoading: true
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root._load(posFile.text());
            if (root._externalReload) {
                root._externalReload = false;
                root._undo = [];
                root._redo = [];
                root._persistHistory();
                root.historyRestored();
            }
        }
        // A failed re-read must not leave the flag set, or the next external edit would wipe history.
        onLoadFailed: root._externalReload = false
    }

    FileView {
        id: histFile
        path: root._historyPath
        blockLoading: true
        printErrors: false
    }

    Component.onCompleted: {
        _load(posFile.text());
        _loadHistory(histFile.text());
    }
}
