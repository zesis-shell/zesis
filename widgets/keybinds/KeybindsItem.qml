import "../bar"

BarButton {
    icon: KeybindService.icon
    active: KeybindService.popupOpen
    onClicked: KeybindService.popupOpen = !KeybindService.popupOpen
}
