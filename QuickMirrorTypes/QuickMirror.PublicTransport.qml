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
import QtQuick.Layouts 1.12

ColumnLayout {
    id: publicTransport
    visible: tripsView.model.length > 0

    property var trips: []
    property var showTrips: 10

    ApiCall {
        id: bvgApi
        property var stopId: 900000110002
        property var filterDuration: 60
        url: "https://v5.bvg.transport.rest"; path: [ "stops", stopId, "departures" ]
        query: [
            "duration=" + filterDuration,
            "bus=false",
        ]
        onResponse: {
            if (typeof response.length === "undefined" || response.length === null || response.length === 0)
                return;
            for (var i in response) {
                var trip = response[i];
                if (typeof trip == "undefined" || trip === null)
                    continue;
                if (trip.cancelled === true)
                    continue;
                if (typeof trip.when == "undefined" || trip.when === null)
                    continue;
                if (!(trip.when.length > 0))
                    continue;
                if (typeof trip.line == "undefined" || trip.line === null)
                    continue;

                var departure = new Date(trip.when).getTime();
                if (!tripReachable(departure))
                    continue;
                trips.push(
                {
                    line: trip.line.name,
                    dest: trip.direction
                        .replace("⟳", "(»)")
                        .replace("⟲", "(«)"),
                    when: departure
                });

            }
            if (trips.length === 0)
                return;

            tripsView.model = trips.slice(0, showTrips);
        }
        onError: {
        }
    }

    function minsToDeparture(departure) {
        var now = Date.now();
        return Math.round((departure - now) / 1000 / 60);
    }

    function tripReachable(departure) {
        return minsToDeparture(departure) >= 5;
    }

    function tripHurry(departure) {
        return minsToDeparture(departure) < 7;
    }

    function refresh() {
        trips = [];
        bvgApi.sendRequest();
     }

    Component.onCompleted: {
        refresh();
    }

    Timer {
        id: timerRefresh
        interval: 10000; running: true; repeat: true
        onTriggered: {
            refresh();
            if (trips.length === 0 && tripsView.model.length > 0) {
                // fail-safe
                while (tripsView.model.length > 0 && !tripReachable(tripsView.model[0].when))
                    tripsView.model.shift();
            }
        }
    }

    RowLayout {
        Image {
            source: "/png/s-bahn.png"
            Layout.leftMargin: 10
        }
        Image {
            source: "/png/tram.png"
            Layout.leftMargin: 10
        }
        Text {
            renderType: Text.NativeRendering
            text: "S Prenzlauer Allee"
            font.family: FontFamily_Bold
            font.styleName: FontStyle_Bold
            font.pointSize: 32
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            Layout.minimumWidth: 256
            Layout.maximumWidth: 256
            Layout.minimumHeight: 32
            Layout.maximumHeight: 32
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: -5
        }
    }
    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: "white"
        Layout.topMargin: 10
        Layout.bottomMargin: 5
    }
    Repeater {
        id: tripsView
        model: []
        RowLayout {
            spacing: 0
            Layout.minimumHeight: 35
            Layout.maximumHeight: 35
            Text {
                text: modelData.line
                font.family: FontFamily_TransportLine
                font.styleName: FontStyle_TransportLine
                font.pointSize: 24
                renderType: Text.NativeRendering
                color: "yellow"
                horizontalAlignment: Text.AlignLeft
                Layout.minimumWidth: 55
                Layout.maximumWidth: 55
                Layout.alignment: Qt.AlignLeft
                Layout.topMargin: -8
            }
            Text {
                clip: true
                text: modelData.dest
                font.family: FontFamily_Transport
                font.styleName: FontStyle_Transport
                font.pointSize: 24
                renderType: Text.NativeRendering
                color: "yellow"
                Layout.minimumWidth: 230
                Layout.maximumWidth: 230
                Layout.alignment: Qt.AlignLeft
                Layout.topMargin: -8
                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.90; color: "transparent" }
                        GradientStop { position: 0.99; color: "black" }
                    }
                }
            }
            Text {
                id: tripTime
                text: minsToDeparture(modelData.when).toFixed() + " min"
                font.family: FontFamily_Transport
                font.styleName: FontStyle_Transport
                font.pointSize: 24
                renderType: Text.NativeRendering
                color: "yellow"
                Layout.minimumWidth: 75
                Layout.maximumWidth: 75
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: -8
                SequentialAnimation {
                    loops: Animation.Infinite
                    running:tripHurry(modelData.when)
                    PauseAnimation { duration: 500 }
                    NumberAnimation { target: tripTime; property: "opacity"; to: 0.0; duration: 1000 }
                    NumberAnimation { target: tripTime; property: "opacity"; to: 1.0; duration: 1000 }
                }
            }
        }
    }
}
