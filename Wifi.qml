
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    width: 296
    height: expanded ? 390 : 112

    property bool wifiEnabled: false
    property bool expanded: false
    property string connectionName: "Not connected"
    property string statusText: "Checking Wi-Fi..."
    property string selectedSSID: ""
    property string password: ""
    property var networks: []

    function refreshStatus() {
        wifiStatus.running = true
        connectionStatus.running = true
    }

    function scanNetworks() {
        root.statusText = "Scanning networks..."
        scanProcess.running = true
    }

    function connectToNetwork(ssid, security) {
        if (security !== "" && security !== "--" &&
            root.password.length === 0) {
            root.statusText = "Enter the Wi-Fi password"
            return
        }

        root.statusText = "Connecting to " + ssid + "..."

        if (security === "" || security === "--") {
            connectProcess.command = [
                "nmcli", "device", "wifi", "connect", ssid
            ]
        } else {
            connectProcess.command = [
                "nmcli", "device", "wifi", "connect",
                ssid, "password", root.password
            ]
        }

        connectProcess.running = true
    }

    Process {
        id: wifiStatus

        command: ["nmcli", "radio", "wifi"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled = this.text.trim() === "enabled"
            }
        }
    }

    Process {
        id: connectionStatus

        command: [
            "nmcli", "-t", "-f", "NAME,TYPE",
            "connection", "show", "--active"
        ]

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
        id: scanProcess

        command: [
            "nmcli",
            "--terse",
            "--escape", "no",
            "--fields", "SSID,SECURITY,SIGNAL",
            "device", "wifi", "list",
            "--rescan", "yes"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                let result = []
                let lines = this.text.trim().split("\n")

                for (let line of lines) {
                    let fields = line.split(":")

                    if (fields.length < 3)
                        continue

                    let ssid = fields[0].trim()

                    if (ssid.length === 0)
                        continue

                    let exists = result.some(
                        network => network.ssid === ssid
                    )

                    if (!exists) {
                        result.push({
                            ssid: ssid,
                            security: fields[1],
                            signal: Number(fields[2]) || 0
                        })
                    }
                }

                result.sort((a, b) => b.signal - a.signal)

                root.networks = result
                root.statusText = result.length > 0
                    ? result.length + " networks found"
                    : "No networks found"
            }
        }

        onExited: {
            if (exitCode !== 0)
                root.statusText = "Network scan failed"
        }
    }

    Process {
        id: wifiToggle

        onExited: {
            root.refreshStatus()
            root.statusText = exitCode === 0
                ? "Wi-Fi status updated"
                : "Could not change Wi-Fi"
        }
    }

    Process {
        id: connectProcess

        onExited: {
            if (exitCode === 0) {
                root.statusText = "Connected successfully"
                root.password = ""
                root.selectedSSID = ""
                root.refreshStatus()
            } else {
                root.statusText = "Connection failed. Check password."
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refreshStatus()
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
                            wifiToggle.command = [
                                "nmcli", "radio", "wifi",
                                root.wifiEnabled ? "off" : "on"
                            ]
                            wifiToggle.running = true
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

            Rectangle {
                width: parent.width
                height: 1
                color: "#414868"
            }

            Row {
                width: parent.width
                spacing: 8

                Rectangle {
                    width: 190
                    height: 32
                    radius: 8
                    color: "#414868"

                    Text {
                        anchors.centerIn: parent
                        text: root.expanded ? "Hide networks" : "Available networks"
                        color: "#c0caf5"
                        font.pixelSize: 11
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.expanded = !root.expanded

                            if (root.expanded && root.wifiEnabled)
                                root.scanNetworks()
                        }
                    }
                }

                Rectangle {
                    width: 48
                    height: 32
                    radius: 8
                    color: "#414868"

                    Text {
                        anchors.centerIn: parent
                        text: "↻"
                        color: "#7aa2f7"
                        font.pixelSize: 19
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (root.wifiEnabled)
                                root.scanNetworks()
                        }
                    }
                }
            }

            Text {
                visible: root.expanded
                text: root.statusText
                color: "#7aa2f7"
                font.pixelSize: 10
                width: parent.width
                elide: Text.ElideRight
            }

            ListView {
                visible: root.expanded && root.wifiEnabled
                width: parent.width
                height: 130
                clip: true
                spacing: 5
                model: root.networks

                delegate: Rectangle {
                    required property var modelData

                    width: ListView.view.width
                    height: 36
                    radius: 8
                    color: root.selectedSSID === modelData.ssid
                        ? "#414868" : "#1a1b26"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 9
                        anchors.rightMargin: 9
                        spacing: 7

                        Text {
                            width: 155
                            text: modelData.ssid
                            color: "#c0caf5"
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: modelData.security === "" ||
                                  modelData.security === "--"
                                ? "OPEN"
                                : "LOCK"
                            color: "#7aa2f7"
                            font.pixelSize: 9
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: modelData.signal + "%"
                            color: "#9ece6a"
                            font.pixelSize: 10
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.selectedSSID = modelData.ssid
                            root.password = ""

                            if (modelData.security === "" ||
                                modelData.security === "--") {
                                root.connectToNetwork(
                                    modelData.ssid,
                                    modelData.security
                                )
                            }
                        }
                    }
                }
            }

            Column {
                visible: root.expanded &&
                         root.selectedSSID.length > 0 &&
                         root.wifiEnabled
                width: parent.width
                spacing: 7

                Text {
                    text: "Connect to: " + root.selectedSSID
                    color: "#c0caf5"
                    font.pixelSize: 11
                }

                Rectangle {
                    width: parent.width
                    height: 36
                    radius: 8
                    color: "#1a1b26"
                    border.width: 1
                    border.color: "#414868"

                    TextInput {
                        id: passwordInput
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        verticalAlignment: TextInput.AlignVCenter
                        color: "#c0caf5"
                        font.pixelSize: 12
                        echoMode: TextInput.Password
                        clip: true
                        focus: true
                        onTextChanged: root.password = text

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            visible: passwordInput.text.length === 0
                            text: "Wi-Fi password"
                            color: "#565f89"
                            font.pixelSize: 11
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 34
                    radius: 8
                    color: "#7aa2f7"

                    Text {
                        anchors.centerIn: parent
                        text: "Connect"
                        color: "#1a1b26"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            let selected = root.networks.find(
                                network => network.ssid === root.selectedSSID
                            )

                            if (selected)
                                root.connectToNetwork(
                                    selected.ssid,
                                    selected.security
                                )
                        }
                    }
                }
            }
        }
    }
}
