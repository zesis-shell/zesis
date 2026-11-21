import "../shared"

VolumeStyleOsd {
    vol: AudioService.vol
    muted: AudioService.muted
    audioTarget: AudioService.sink?.audio
    mutedTextKey: "sound.muted"
    iconFor: function (v, m) {
        return m || v === 0 ? "volume_off" : v < 0.67 ? "volume_down" : "volume_up";
    }
}
