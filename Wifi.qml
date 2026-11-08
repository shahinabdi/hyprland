
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    width: 296
    height: 112

    property bool wifiEnabled: false
    property string connectionName: "Checking connection..."
    property string statusText: "Checking Wi-Fi..."

    Process {
        id: wifiStatus
        command: ["nmcli", "radio", "wifi"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled = this.text.trim() === "enabled"
                root.statusText = root.wifiEnabled
                    ? "Wi-Fi is enabled"
                    : "Wi-Fi is disabled"
            }
        }
    }

    Process {
        id: connectionStatus
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show", "--active"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                let found = "Not connected"

                for (let line of this.text.trim().split("\n")) {
                    let fields = line.split(":")
                    if (fields.length >= 2 &&
                        fields[1].includes("802-11-wireless")) {
                        found = fields[0].replace(/\\:/g, ":")
                        break
                    }
                }

                root.connectionName = found
            }
        }
    }

    Process {
        id: wifiToggle

        onExited: {
            wifiStatus.running = true
            connectionStatus.running = true
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true

        onTriggered: {
            wifiStatus.running = true
            connectionStatus.running = true
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 16
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
                    text: "Wi-Fi"
                    color: "#c0caf5"
                    font.pixelSize: 16
                    font.bold: true

                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    width: 1
                    height: 1
                }

                Rectangle {
                    width: 58
                    height: 28
                    radius: 14
                    color: root.wifiEnabled ? "#7aa2f7" : "#414868"

                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: root.wifiEnabled ? "ON" : "OFF"
                        color: "#1a1b26"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            wifiToggle.exec([
                                "nmcli",
                                "radio",
                                "wifi",
                                root.wifiEnabled ? "off" : "on"
                            ])
                        }
                    }
                }
            }

            Text {
                width: parent.width
                text: root.wifiEnabled
                    ? root.connectionName
                    : "Wireless network is disabled"
                color: "#a9b1d6"
                font.pixelSize: 12
                elide: Text.ElideRight
            }

            Text {
                text: root.statusText
                color: "#7aa2f7"
                font.pixelSize: 10
            }
        }
    }
}
