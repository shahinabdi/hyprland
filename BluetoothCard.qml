
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    width: 300
    height: 92

    property bool enabled: false
    property string status: "Checking Bluetooth..."

    Process {
        id: statusProcess
        command: ["bluetoothctl", "show"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.enabled = this.text.includes("Powered: yes")
                root.status = root.enabled ? "Bluetooth enabled" : "Bluetooth disabled"
            }
        }
    }

    Process {
        id: toggleProcess
        onExited: statusProcess.running = true
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: statusProcess.running = true
    }

    Rectangle {
        anchors.fill: parent
        radius: 15
        color: "#24283b"
        border.width: 1
        border.color: "#414868"

        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            Row {
                width: parent.width
                spacing: 10

                Text {
                    text: "Bluetooth"
                    color: "#c0caf5"
                    font.pixelSize: 16
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item { width: 1; height: 1 }

                Rectangle {
                    width: 58
                    height: 28
                    radius: 14
                    color: root.enabled ? "#7aa2f7" : "#414868"

                    Text {
                        anchors.centerIn: parent
                        text: root.enabled ? "ON" : "OFF"
                        color: "#1a1b26"
                        font.bold: true
                        font.pixelSize: 11
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            toggleProcess.command = [
                                "bluetoothctl",
                                "power",
                                root.enabled ? "off" : "on"
                            ]
                            toggleProcess.running = true
                        }
                    }
                }
            }

            Text {
                text: root.status
                color: "#a9b1d6"
                font.pixelSize: 11
            }
        }
    }
}
