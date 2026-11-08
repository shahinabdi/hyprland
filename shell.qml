
import QtQuick
import Quickshell

PanelWindow {
    id: sidebar

    anchors {
        right: true
        top: true
        bottom: true
    }

    margins {
        right: 16
        top: 16
        bottom: 16
    }

    width: 340
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: "#1a1b26"
        border.width: 1
        border.color: "#414868"

        Column {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 22

            // Header
            Column {
                spacing: 5

                Text {
                    text: "Quick Settings"
                    color: "#c0caf5"
                    font.pixelSize: 23
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

            // Network section
            Column {
                spacing: 10

                Text {
                    text: "CONNECTIVITY"
                    color: "#565f89"
                    font.pixelSize: 11
                    font.bold: true
                }

                Rectangle {
                    width: parent.width
                    height: 76
                    radius: 14
                    color: "#24283b"

                    Column {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "◉  Wi-Fi"
                            color: "#7aa2f7"
                            font.pixelSize: 16
                            font.bold: true
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Network controls coming next"
                            color: "#a9b1d6"
                            font.pixelSize: 11
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 76
                    radius: 14
                    color: "#24283b"

                    Column {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "ᛒ  Bluetooth"
                            color: "#7aa2f7"
                            font.pixelSize: 16
                            font.bold: true
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Device controls coming next"
                            color: "#a9b1d6"
                            font.pixelSize: 11
                        }
                    }
                }
            }

            // Audio section
            Column {
                width: parent.width
                spacing: 10

                Text {
                    text: "AUDIO & DISPLAY"
                    color: "#565f89"
                    font.pixelSize: 11
                    font.bold: true
                }

                Rectangle {
                    width: parent.width
                    height: 65
                    radius: 14
                    color: "#24283b"

                    Text {
                        anchors.centerIn: parent
                        text: "♫   Volume controls"
                        color: "#c0caf5"
                        font.pixelSize: 14
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 65
                    radius: 14
                    color: "#24283b"

                    Text {
                        anchors.centerIn: parent
                        text: "☼   Brightness controls"
                        color: "#c0caf5"
                        font.pixelSize: 14
                    }
                }
            }

            Item {
                width: 1
                height: 1
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#414868"
            }

            Text {
                text: "ARCH LINUX  •  HYPRLAND"
                color: "#565f89"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
