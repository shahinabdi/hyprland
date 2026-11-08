import QtQuick
import Quickshell
import "modules"

PanelWindow {
    id: sidebar

    anchors {
        right: true
        top: true
        bottom: true
    }

    margins {
        right: 12
        top: 12
        bottom: 12
    }

    implicitWidth: 360
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: "#1a1b26"
        border.width: 1
        border.color: "#414868"

        Flickable {
            anchors.fill: parent
            anchors.margins: 20

            contentWidth: width
            contentHeight: contentColumn.implicitHeight

            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: contentColumn

                width: parent.width
                spacing: 18

                // HEADER
                Column {
                    spacing: 5

                    Text {
                        text: "Quick Settings"
                        color: "#c0caf5"
                        font.pixelSize: 24
                        font.bold: true
                    }

                    Text {
                        text: "TOKYO NIGHT  •  ARCH LINUX"
                        color: "#7aa2f7"
                        font.pixelSize: 10
                        font.letterSpacing: 1.5
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#414868"
                }

                // CONNECTIVITY
                Text {
                    text: "CONNECTIVITY"
                    color: "#7aa2f7"
                    font.pixelSize: 11
                    font.bold: true
                }

                Wifi {
                    width: parent.width
                }

                BluetoothCard {
                    width: parent.width
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#414868"
                }

                // AUDIO
                Text {
                    text: "AUDIO"
                    color: "#7aa2f7"
                    font.pixelSize: 11
                    font.bold: true
                }

                AudioCard {
                    width: parent.width
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#414868"
                }

                // DISPLAY
                Text {
                    text: "DISPLAY"
                    color: "#7aa2f7"
                    font.pixelSize: 11
                    font.bold: true
                }

                BrightnessCard {
                    width: parent.width
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#414868"
                }

                // FOOTER
                Text {
                    text: "ARCH LINUX  •  HYPRLAND"
                    color: "#565f89"
                    font.pixelSize: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
