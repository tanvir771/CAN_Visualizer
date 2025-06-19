#include "SerialHandler.h"
#include <QDebug>

SerialHandler::SerialHandler(QObject *parent) : QObject(parent)
{
    connect(&serial, &QSerialPort::readyRead, this, &SerialHandler::handleReadyRead);
}

SerialHandler::~SerialHandler()
{
    disconnectSerial();
}

void SerialHandler::connectSerial(const QString &portName, int baudRate)
{
    if (serial.isOpen()) {
        serial.close();
    }
    serial.setPortName(portName);
    serial.setBaudRate(baudRate);
    if (serial.open(QIODevice::ReadWrite)) {
        qDebug() << "Serial port opened successfully:" << portName << baudRate;
        emit connectionChanged();
    } else {
        qDebug() << "Failed to open serial port:" << serial.errorString();
        emit errorOccurred(serial.errorString());
    }
}

void SerialHandler::disconnectSerial()
{
    if (serial.isOpen()) {
        serial.close();
        emit connectionChanged();
    }
}

void SerialHandler::sendCanMessage(const QString &canId, const QString &data)
{
    if (!serial.isOpen()) {
        qDebug() << "Cannot send, serial port not open";
        return;
    }
    QString msg = QString("SEND:%1:%2\n").arg(canId).arg(data);
    qint64 written = serial.write(msg.toUtf8());
    if (written == -1) {
        qDebug() << "Failed to write to serial port:" << serial.errorString();
        emit errorOccurred(serial.errorString());
    } else {
        qDebug() << "Sent CAN message:" << msg.trimmed();
    }
}

void SerialHandler::handleReadyRead()
{
    while (serial.canReadLine()) {
        QByteArray raw = serial.readLine().trimmed();
        QString line = QString::fromUtf8(raw);
        qDebug() << "[SerialHandler] Received:" << line;
        emit lineReceived(line);
    }
}
