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

Item {
    id: onThisDay
    clip: true

    property int viewportHeight
    property var events: []
    property var births: []
    property var deaths: []
    property int idxEventType: -1

    ApiCall {
        id: onThisDayApi
        property int month: 0
        property int day: 0
        property string eventType: ""
        url: "https://byabbe.se"; path: ["on-this-day", month, day, eventType + ".json" ]
        onResponse: {
            if ("events" in response) {
                events = shuffle(response.events);

                eventType = "births";
                sendRequest();

            } else if ("births" in response) {
                births = shuffle(response.births);
                for (var i in births)
                    births[i].year = "*" + births[i].year;

                eventType = "deaths";
                sendRequest();

            } else if ("deaths" in response) {
                deaths = shuffle(response.deaths);
                for (var i in deaths)
                    deaths[i].year = "<sup>†</sup>" + deaths[i].year;

                next();
            }
        }
    }

    function init() {
        events = [];
        births = [];
        deaths = [];
        idxEventType = -1;

        var today = new Date;
        onThisDayApi.month = today.getMonth() + 1;
        onThisDayApi.day = today.getDate();

        onThisDayApi.eventType = "events";
        onThisDayApi.sendRequest();
    }

    function next() {
        if (events.length + births.length + deaths.length == 0)
            return;

        var today = new Date;
        if (onThisDayApi.month != today.getMonth() + 1 || onThisDayApi.day != today.getDate())
            return init();

        onThisDayText.color = "white";
        idxEventType = (idxEventType + 1) % 3;
        var event;
        switch (idxEventType) {
            case 0:
                if (events.length == 0)
                    return next();
                event = events.shift();
                events = shuffle(events);
                events.push(event);
                break;
            case 1:
                if (births.length == 0)
                    return next();
                event = births.shift();
                births = shuffle(births);
                births.push(event);
                break;
            case 2:
                if (deaths.length == 0)
                    return next();
                event = deaths.shift();
                deaths = shuffle(deaths);
                deaths.push(event);
                break;
        }
        onThisDayText.text = event.year + " – " + event.description;
        showText.start();
    }

    Component.onCompleted: {
        init();
    }

    Timer {
        id: timerRetry
        interval: 10000; running: true; repeat: true
        onTriggered: {
            if (events.length + births.length + deaths.length == 0)
                init();
        }
    }

    SequentialAnimation {
        id: showText
        PropertyAction { target: onThisDayText; property: "y"; value: 25 }
        NumberAnimation { target: onThisDayText; property: "opacity"; to: 1.0; duration: 500 }
        PauseAnimation { duration: 3000 }
        NumberAnimation {
            target: onThisDayText
            property: "y"
            to: Math.min(-(25 + onThisDayText.contentHeight) + viewportHeight, 25)
            duration: Math.max(0, (Math.abs(to - from) * 1000) / 25)
        }
        PauseAnimation { duration: 3000 }
        NumberAnimation { target: onThisDayText; property: "opacity"; to: 0.0; duration: 1000 }
        onFinished: {
            onThisDay.next();
        }
    }

    Text {
        renderType: Text.NativeRendering
        id: onThisDayText
        wrapMode: Text.WordWrap
        font.family: FontFamily_Normal
        font.styleName: FontStyle_Normal
        font.pointSize: 40
        textFormat: Text.RichText
        color: "white"

        y: 25
        anchors.left: parent.left
        width: parent.width
        height: contentHeight
        opacity: 0
    }

    Rectangle {
        id: top
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        height: 10
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "black" }
            GradientStop { position: 0.5; color: "transparent" }
        }
    }

    Rectangle {
        id: bottomFade
        anchors.top: parent.top
        anchors.topMargin: viewportHeight
        anchors.left: parent.left
        width: parent.width
        height: 0.1 * viewportHeight
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.5; color: "black" }
        }
    }
    Rectangle {
        anchors.top: bottomFade.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: parent.width
        color: "black"
    }
}
