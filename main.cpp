/****************************************************************************
**
** Copyright (C) 2020 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the Qt VS Tools.
**
** $QT_BEGIN_LICENSE:GPL-EXCEPT$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 as published by the Free Software
** Foundation with exceptions as appearing in the file LICENSE.GPL3-EXCEPT
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlEngine>

#include "Process.h"

struct Font { const char* id, * family, * style; };
Font fonts[] = { FONTS, { NULL } };

int main(int argc, char* argv[])
{
    qmlRegisterType<Process>("Process", 1, 0, "Process");

#if defined(Q_OS_WIN)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

#if defined(Q_OS_WIN)
    engine.rootContext()->setContextProperty("Q_OS_WIN", true);
#else
    engine.rootContext()->setContextProperty("Q_OS_WIN", false);
#endif
    engine.rootContext()->setContextProperty("API_KEY_NEWS", API_KEY_NEWS);
    engine.rootContext()->setContextProperty("API_KEY_WEATHER", API_KEY_WEATHER);

    QString FONT_FAMILY = QStringLiteral("FontFamily_");
    QString FONT_STYLE = QStringLiteral("FontStyle_");
    for (Font* f = fonts; f->id; ++f) {
        engine.rootContext()->setContextProperty(FONT_FAMILY + f->id, f->family);
        engine.rootContext()->setContextProperty(FONT_STYLE + f->id, f->style);
    }

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
