import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Item {
    id: root

    width: 300
    height: 100

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

    function toggleMute() {
        muteProcess.running = true
    }

    // READ CURRENT VOLUME AND MUTE STATE
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
                    root.volume = Math.min(
                        100,
                        Number(match[1]) * 100
                    )

                root.muted = output.includes("[MUTED]")
            }
        }
    }

    // CHANGE VOLUME
    Process {
        id: volumeWrite

        onExited: {
            root.readVolume()
        }
    }

    // TOGGLE MUTE
    Process {
        id: muteProcess

        command: [
            "wpctl",
            "set-mute",
            "@DEFAULT_AUDIO_SINK@",
            "toggle"
        ]

        onExited: {
            root.readVolume()
        }
    }

    // PERIODIC STATUS UPDATE
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

            spacing: 15

            // HEADER
            Item {
                width: parent.width
                height: 27

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    text: "Volume"

                    color: "#c0caf5"
                    font.pixelSize: 14
                    font.bold: true
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    spacing: 8

                    Text {
                        text: root.muted
                            ? "Muted"
                            : Math.round(root.volume) + "%"

                        color: "#7aa2f7"
                        font.pixelSize: 11

                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        width: 54
                        height: 27

                        radius: 8

                        color: root.muted
                            ? "#f7768e"
                            : "#414868"

                        border.width: 1
                        border.color: root.muted
                            ? "#f7768e"
                            : "#565f89"

                        Text {
                            anchors.centerIn: parent

                            text: root.muted
                                ? "UNMUTE"
                                : "MUTE"

                            color: root.muted
                                ? "#1a1b26"
                                : "#c0caf5"

                            font.pixelSize: 9
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape: Qt.PointingHandCursor

                            onClicked: root.toggleMute()
                        }
                    }
                }
            }

            // VOLUME SLIDER
            Rectangle {
                id: track

                width: parent.width
                height: 9

                radius: 5
                color: "#414868"

                anchors.verticalCenter: undefined

                Rectangle {
                    width: track.width * root.volume / 100
                    height: parent.height

                    radius: 5
                    color: root.muted
                        ? "#565f89"
                        : "#7aa2f7"
                }

                Rectangle {
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

                    cursorShape: Qt.PointingHandCursor

                    function updateValue(mouseX) {
                        root.setVolume(
                            mouseX / width * 100
                        )
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
