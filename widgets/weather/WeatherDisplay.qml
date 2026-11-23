import QtQuick
import "../../"

// Current conditions: icon, temperature, condition, humidity and wind. Always laid out in full.
// It does not reflow to its box, so the desktop scales it as a whole, like the other widgets, and
// nothing drops out at small sizes.
Item {
    id: root

    readonly property real _colSpacing: Math.round(2 * UIScale.value)

    implicitWidth: contentRow.implicitWidth
    implicitHeight: contentRow.implicitHeight

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: UIScale.spacingMd

        Text {
            id: iconText
            anchors.verticalCenter: parent.verticalCenter
            text: WeatherService.weatherIcon(WeatherService.weatherCode, WeatherService.isDay)
            font.family: "Material Symbols Rounded"
            font.pixelSize: Math.round(44 * UIScale.value)
            color: Colors.text
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: root._colSpacing

            Text {
                id: tempText
                text: WeatherService.temperature + "°C"
                font.pixelSize: Math.round(28 * UIScale.value)
                font.weight: Font.Light
                color: Colors.text
            }

            Text {
                id: conditionText
                text: WeatherService.conditionText(WeatherService.weatherCode)
                font.pixelSize: UIScale.fontCaption
                color: Colors.textDim
            }

            Row {
                id: humidityRow
                spacing: Math.round(10 * UIScale.value)

                Row {
                    spacing: Math.round(4 * UIScale.value)

                    Text {
                        text: "opacity"
                        font.family: "Material Symbols Rounded"
                        font.pixelSize: UIScale.fontCaption
                        color: Colors.textDim
                    }

                    Text {
                        text: WeatherService.humidity + "%"
                        font.pixelSize: UIScale.fontCaption
                        color: Colors.textDim
                    }
                }

                Row {
                    spacing: Math.round(4 * UIScale.value)

                    Text {
                        text: "flag"
                        font.family: "Material Symbols Rounded"
                        font.pixelSize: UIScale.fontCaption
                        color: Colors.textDim
                    }

                    Text {
                        text: WeatherService.windspeed + " km/h"
                        font.pixelSize: UIScale.fontCaption
                        color: Colors.textDim
                    }
                }
            }
        }
    }
}
