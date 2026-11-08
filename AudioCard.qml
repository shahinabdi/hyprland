
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    width: 300
    height: 105

    property real volume: 0
    property bool muted: false

    Process {
        id: volumeRead
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                let output = this.text.trim()
                let match = output.match(/Volume:\s*([0-9.]+)/)
                if (match)
                    root.volume = Math.min(1, Number(match[1]))

                root.muted = output.includes("[MUTED]")
            }
        }
    }

    Process {
        id: volumeWrite
        onExited: volumeRead.running = true
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: volumeRead.running = true
    }

    Rectangle {
        anchors.fill: parent
        radius: 15
        color: "#24283b"

        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            Row {
                width: parent.width

                Text {
                    text: root.muted ? "Volume (Muted)" : "Volume"
                    color: "#c0caf5"
                    font.pixelSize: 14
                    font.bold: true
                }

                Item { width: 1; height: 1 }

                Text {
                    text: Math.round(root.volume * 100) + "%"
                    color: "#7aa2f7"
                    font.pixelSize: 12
                }
            }

            Slider {
                id: volumeSlider
                width: parent.width
                from: 0
                to: 100
                value: root.volume * 100

                onMoved: {
                    volumeWrite.command = [
                        "wpctl", "set-volume",
                        "@DEFAULT_AUDIO_SINK@",
                        (value / 100).toString()
                    ]
                    volumeWrite.running = true
                }
            }

            Text {
                text: "Click volume label to toggle mute"
                color: "#565f89"
                font.pixelSize: 9
            }
        }

        MouseArea {
            anchors.right: parent.right
            anchors.top: parent.top
            width: 65
            height: 35
            onClicked: {
                volumeWrite.command = [
                    "wpctl", "set-mute",
                    "@DEFAULT_AUDIO_SINK@", "toggle"
                ]
                volumeWrite.running = true
            }
        }
    }
}
