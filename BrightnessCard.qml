
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    width: 300
    height: 90

    property real brightness: 50

    Process {
        id: brightnessRead
        command: ["brightnessctl", "get"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                let current = Number(this.text.trim())
                if (!isNaN(current))
                    root.brightness = current
            }
        }
    }

    Process {
        id: maxRead
        command: ["brightnessctl", "max"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                let max = Number(this.text.trim())
                if (max > 0)
                    root.brightness = root.brightness / max * 100
            }
        }
    }

    Process {
        id: brightnessWrite
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
                    text: "Brightness"
                    color: "#c0caf5"
                    font.pixelSize: 14
                    font.bold: true
                }

                Item { width: 1; height: 1 }

                Text {
                    text: Math.round(root.brightness) + "%"
                    color: "#7aa2f7"
                    font.pixelSize: 12
                }
            }

            Slider {
                width: parent.width
                from: 1
                to: 100
                value: root.brightness

                onMoved: {
                    brightnessWrite.command = [
                        "brightnessctl", "set",
                        Math.round(value) + "%"
                    ]
                    brightnessWrite.running = true
                    root.brightness = value
                }
            }
        }
    }
}
