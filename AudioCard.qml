import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Item {
    id: root

    width: 300
    height: 105

    property real volume: 50
    property bool muted: false

    function readVolume() {
        volumeRead.running = true
    }

    function setVolume(value) {
        volume = Math.max(0, Math.min(100, value))

        volumeWrite.command = [
            "wpctl",
            "set-volume",
            "@DEFAULT_AUDIO_SINK@",
            (volume / 100).toString()
        ]

        volumeWrite.running = true
    }

    Process {
        id: volumeRead

        command: [
            "wpctl",
            "get-volume",
            "@DEFAULT_AUDIO_SINK@"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                let output = this.text.trim()
                let match = output.match(/Volume:\s*([0-9.]+)/)

                if (match)
                    root.volume = Number(match[1]) * 100

                root.muted = output.includes("[MUTED]")
            }
        }
    }

    Process {
        id: volumeWrite
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: root.readVolume()
    }

    Rectangle {
        anchors.fill: parent
        radius: 15
        color: "#24283b"

        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            Row {
                width: parent.width

                Text {
                    text: "Volume"
                    color: "#c0caf5"
                    font.pixelSize: 14
                    font.bold: true
                }

                Item { width: 1; height: 1 }

                Text {
                    text: root.muted
                        ? "Muted"
                        : Math.round(root.volume) + "%"
                    color: "#7aa2f7"
                    font.pixelSize: 12
                }

                Rectangle {
                    width: 42
                    height: 24
                    radius: 8
                    color: root.muted ? "#f7768e" : "#414868"

                    Text {
                        anchors.centerIn: parent
                        text: root.muted ? "OFF" : "MUTE"
                        color: "#c0caf5"
                        font.pixelSize: 9
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            volumeWrite.command = [
                                "wpctl",
                                "set-mute",
                                "@DEFAULT_AUDIO_SINK@",
                                "toggle"
                            ]

                            volumeWrite.running = true
                            root.readVolume()
                        }
                    }
                }
            }

            Rectangle {
                id: track

                width: parent.width
                height: 9
                radius: 5
                color: "#414868"

                Rectangle {
                    width: track.width * root.volume / 100
                    height: parent.height
                    radius: 5
                    color: "#7aa2f7"
                }

                Rectangle {
                    id: knob
                    width: 17
                    height: 17
                    radius: 9
                    color: "#c0caf5"

                    x: Math.max(
                        0,
                        Math.min(
                            track.width - width,
                            track.width * root.volume / 100 - width / 2
                        )
                    )

                    anchors.verticalCenter: parent.verticalCenter
                }

                MouseArea {
                    anchors.fill: parent

                    function updateValue(mouseX) {
                        root.setVolume(mouseX / width * 100)
                    }

                    onPressed: mouse => updateValue(mouse.x)

                    onPositionChanged: mouse => {
                        if (pressed)
                            updateValue(mouse.x)
                    }
                }
            }
        }
    }

    Component.onCompleted: readVolume()
}
