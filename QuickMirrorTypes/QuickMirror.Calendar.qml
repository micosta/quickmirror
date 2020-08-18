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

import QtQuick 2.12
import QtQuick.Controls 2.5

Text {
    renderType: Text.NativeRendering
    id: calendar
    color: "white"
    font.family: FontFamily_Bold
    font.styleName: FontStyle_Bold
    font.pointSize: 72
    property var locales: ["en_US", "de_DE", "pt_PT"]
    property var localeIdx: 0

    function capitalize(s) {
        return s.replace(/(^|-)./g, function(c) { return c.toUpperCase(); });
    }
    
    function setNextLocale() {
        localeIdx = (localeIdx + 1) % locales.length;
    }

    function getCurrentText() {
        var date = new Date;
        var locale = Qt.locale(locales[localeIdx]);
        var calendarText = capitalize(date.toLocaleDateString(locale, "dddd, dd "));
        var monthShort = date.toLocaleDateString(locale, "MMM");
        var monthLong = date.toLocaleDateString(locale, "MMMM");
        if (monthLong.length <= 5) {
            calendarText += capitalize(monthLong);
        } else {
            calendarText += capitalize(monthShort);
            if (!monthShort.endsWith("."))
                calendarText += ".";
        }
        calendarText += date.toLocaleDateString(locale, " yyyy");
        return calendarText;
    }

    Component.onCompleted: {
        text = getCurrentText();
    }

    Timer {
        interval: 15000; running: true; repeat: true
        onTriggered: {
            setNextLocale();
            text = getCurrentText();
        }
    }

    Behavior on text {
        SequentialAnimation {
            NumberAnimation { target: calendar; property: "opacity"; to: 0.0; duration: 1000 }
            PropertyAction { target: calendar; property: "text" }
            NumberAnimation { target: calendar; property: "opacity"; to: 1.0; duration: 500 }
        }
    }
}
