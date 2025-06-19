import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 700
    height: 600
    title: qsTr("CAN Visualizer")
    color: "#1e1e1e"

    ListModel {
        id: logModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Connection controls
        Rectangle {
            Layout.fillWidth: true
            height: 50
            color: "#2d2d2d"
            radius: 4
            border.color: "#404040"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 10

                Label { text: "Port:"; color: "#ffffff" }
                ComboBox {
                    id: portCombo
                    model: ["COM1","COM2","COM3","COM4","COM5","COM6","COM7","COM8"]
                    editable: true
                    currentIndex: 2  // default COM3
                    Layout.preferredWidth: 100
                }

                Label { text: "Baud:"; color: "#ffffff" }
                ComboBox {
                    id: baudCombo
                    model: ["9600","19200","38400","57600","115200","250000","500000"]
                    currentIndex: 4  // default 115200
                    Layout.preferredWidth: 100
                }

                Button {
                    id: connectBtn
                    text: serialHandler.isConnected() ? "Connected" : "Connect"
                    enabled: !serialHandler.isConnected()
                    Layout.preferredWidth: 80
                    onClicked: {
                        var portName = portCombo.editText || portCombo.currentText
                        serialHandler.connectSerial(portName, parseInt(baudCombo.currentText))
                    }
                }

                Button {
                    text: "Disconnect"
                    enabled: serialHandler.isConnected()
                    Layout.preferredWidth: 80
                    onClicked: serialHandler.disconnectSerial()
                }

                Item { Layout.fillWidth: true }
                Button { text: "Clear"; onClicked: logModel.clear() }
            }
        }

        // Log display
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#121212"
            radius: 4
            border.color: "#2e2e2e"

            ListView {
                id: logView
                anchors.fill: parent
                anchors.margins: 5
                model: logModel
                clip: true

                delegate: Rectangle {
                    width: logView.width
                    height: entryText.implicitHeight + 10
                    color: index % 2 === 0 ? "transparent" : "#191919"
                    radius: 4

                    Text {
                        id: entryText
                        anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 8
                        textFormat: Text.RichText
                        text: {
                            var dirColor = (model.direction === "TX") ? "#ff6b6b" :
                                           (model.direction === "RX") ? "#4ecdc4" : "#ffd93d"
                            return `<font color="#888888">${model.timestamp}</font> | ` +
                                   `<font color="${dirColor}"><b>${model.direction}</b></font> | ` +
                                   `<font color="#61dafb">ID: ${model.canId}</font> | ` +
                                   `${model.message}`;
                        }
                        color: "#d4d4d4"
                        font.family: "Consolas, Monaco, monospace"
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                    }
                }
            }
        }

        // Send message controls
        Rectangle {
            Layout.fillWidth: true
            height: 80
            color: "#2d2d2d"
            radius: 4
            border.color: "#404040"

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 8; spacing: 5
                RowLayout {
                    spacing: 10
                    Label { text: "CAN ID:"; color: "#ffffff" }
                    TextField { id: canIdField; placeholderText: "0x123"; Layout.preferredWidth: 100; selectByMouse: true }
                    Label { text: "Data:"; color: "#ffffff" }
                    TextField { id: dataField; placeholderText: "01 02 03 04"; Layout.fillWidth: true; selectByMouse: true }
                    Button { text: "Send"; Layout.preferredWidth: 60;
                        onClicked: {
                            if (canIdField.text && dataField.text) {
                                serialHandler.sendCanMessage(canIdField.text, dataField.text)
                            }
                        }
                    }
                }
                Label { text: "Status: Ready"; color: "#888888"; font.pixelSize: 10 }
            }
        }
    }

    Connections {
        target: serialHandler
        function onLineReceived(line) {
            var timestamp = new Date().toLocaleTimeString()
            var parts = line.split("|")
            var direction = parts[0] ? parts[0].trim() : "INFO"
            var canId = parts[1] ? parts[1].trim() : ""
            var message = parts[2] ? parts[2].trim() : line
            logModel.append({ timestamp: timestamp, direction: direction, canId: canId, message: message })
            logView.positionViewAtEnd()
            if (logModel.count > 500) logModel.remove(0,1)
        }
        function onConnectionChanged(connected) {
            connectBtn.text = connected ? "Connected" : "Connect"
            connectBtn.enabled = !connected
        }
    }
}
