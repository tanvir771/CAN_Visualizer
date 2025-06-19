#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSerialPort>
#include <QDebug>
#include "serialhandler.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    SerialHandler serialHandler;

    // Don't auto-connect anymore - let QML control the connection
    // serialHandler.startSerial("COM3", QSerialPort::Baud9600);

    engine.rootContext()->setContextProperty("serialHandler", &serialHandler);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("CAN_Visualizer", "Main");

    return app.exec();
}
