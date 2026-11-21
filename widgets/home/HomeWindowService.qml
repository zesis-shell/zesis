pragma Singleton
pragma ComponentBehavior: Bound
import "../shared/panels"

RequestableWindowState {
    configName: "homewindow"
    icon: "home"
    readonly property string identityIcon: "home"
}
