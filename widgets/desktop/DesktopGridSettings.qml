pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Alignment grid for the desktop overlay: how it looks and how dense it is. Density is a count of
// cells across the screen, not a pixel size, so the grid always divides the screen evenly. A bigger
// screen gets bigger cells and fewer crossings. Positions are screen fractions too, so widgets
// line up with the grid on any resolution. Kept in its own cache file, apart from the layout and profiles.
Singleton {
    id: root

    readonly property string _configDir: (Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")) + "/zesis"
    readonly property string _configPath: _configDir + "/desktopgrid.json"

    // Columns for each preset. Rows follow the screen's aspect ratio, so cells stay near square.
    readonly property var presetColumns: ({
            fine: 48,
            medium: 24,
            coarse: 12
        })
    readonly property int minColumns: 4
    readonly property int maxColumns: 96
    readonly property int minRows: 3
    readonly property int maxRows: 54

    // "none" | "dots" | "lines" | "both". "none" hides the grid; snapping still uses it.
    property string style: settingsData.style
    // 0..1, applies to the whole grid
    property real gridOpacity: settingsData.gridOpacity
    // "fine" | "medium" | "coarse" | "manual"
    property string preset: settingsData.preset
    // Used by "manual" only.
    property int columns: settingsData.columns
    property int rows: settingsData.rows
    // Snap on/off. Kept here with the grid so it survives a shell restart.
    property bool snapEnabled: settingsData.snapEnabled

    // Columns and rows for a screen of w by h pixels. Presets take the column count from the table and
    // the row count from the aspect ratio. Manual uses the saved counts.
    function countsFor(w, h) {
        if (root.preset === "manual")
            return {
                cols: root.columns,
                rows: root.rows
            };
        var cols = root.presetColumns[root.preset] ?? root.presetColumns.medium;
        var rowCount = Math.max(2, Math.round(cols * h / Math.max(1, w)));
        return {
            cols: cols,
            rows: rowCount
        };
    }

    function setSnapEnabled(v) {
        settingsData.snapEnabled = v;
        settingsFile.writeAdapter();
    }

    function setStyle(s) {
        settingsData.style = s;
        settingsFile.writeAdapter();
    }

    function setGridOpacity(v) {
        settingsData.gridOpacity = v;
        settingsFile.writeAdapter();
    }

    // Going manual keeps the counts the screen is showing, when given, so nothing jumps.
    function setPreset(p, cols, rows) {
        settingsData.preset = p;
        if (p === "manual" && cols !== undefined) {
            settingsData.columns = cols;
            settingsData.rows = rows;
        }
        settingsFile.writeAdapter();
    }

    function setColumns(v) {
        settingsData.preset = "manual";
        settingsData.columns = v;
        settingsFile.writeAdapter();
    }

    function setRows(v) {
        settingsData.preset = "manual";
        settingsData.rows = v;
        settingsFile.writeAdapter();
    }

    JsonAdapter {
        id: settingsData
        property string style: "lines"
        property real gridOpacity: 0.35
        property string preset: "medium"
        property int columns: 24
        property int rows: 14
        property bool snapEnabled: true
        // Spacing in reference pixels, read only to convert into counts on load. 0 means absent.
        property real spacingX: 0
        property real spacingY: 0
    }

    // Spacing counts reference pixels on the fixed 3840x2160 canvas, so the same grid is
    // 3840 / spacingX columns and 2160 / spacingY rows. Converted once, then cleared.
    function _migrateLegacySpacing() {
        if (settingsData.spacingX <= 0 && settingsData.spacingY <= 0)
            return;
        if (settingsData.spacingX > 0)
            settingsData.columns = Math.max(root.minColumns, Math.min(root.maxColumns, Math.round(3840 / settingsData.spacingX)));
        if (settingsData.spacingY > 0)
            settingsData.rows = Math.max(root.minRows, Math.min(root.maxRows, Math.round(2160 / settingsData.spacingY)));
        settingsData.spacingX = 0;
        settingsData.spacingY = 0;
        settingsFile.writeAdapter();
    }

    // No watchChanges: the slider writes on every drag step, and a reload per write would
    // push the adapter back under the handle while it is moving.
    FileView {
        id: settingsFile
        path: root._configPath
        adapter: settingsData
        onLoaded: root._migrateLegacySpacing()
    }
}
