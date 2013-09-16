TEMPLATE = app
CONFIG += console
CONFIG -= app_bundle
CONFIG -= qt

SOURCES += main.cpp \
    Worker.cpp \
    debug_logger.cpp \
    worker_v2.cpp \
    masks_gen.cpp

HEADERS += \
    Worker.h \
    debug_logger.h \
    headers.h \
    worker_v2.h

