#pragma once
#include <QObject>
#include <QSerialPort>

class SerialHandler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectionChanged)
public:
    explicit SerialHandler(QObject *parent = nullptr);
    ~SerialHandler();

    Q_INVOKABLE void connectSerial(const QString &portName, int baudRate);
    Q_INVOKABLE void disconnectSerial();
    Q_INVOKABLE bool isConnected() const { return serial.isOpen(); }
    Q_INVOKABLE void sendCanMessage(const QString &canId, const QString &data);

signals:
    void lineReceived(const QString &line);
    void errorOccurred(const QString &error);
    void connectionChanged();  // emitted when connection state changes

private slots:
    void handleReadyRead();

private:
    QSerialPort serial;
};
