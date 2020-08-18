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

import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import "QuickMirrorTypes"

Window {
    visible: true
    title: qsTr("Quick Mirror")

    Flickable {
        anchors.fill: parent
        contentWidth: mirror.width
        contentHeight: mirror.height

        Rectangle {
            id: mirror
            width: 1080
            height: 1920
            color: "black"

            Clock {
                id: clock
                anchors.top: mirror.top
                anchors.left: mirror.left
            }

            Calendar {
                id: calendar
                anchors.top: clock.bottom
                anchors.topMargin: -20
                anchors.left: mirror.left
            }

            Rectangle {
                anchors.top: calendar.bottom
                anchors.topMargin: -5
                anchors.left: mirror.left
                width: 800
                height: 2
                color: "white"
            }

            OnThisDay {
                id: onThisDay
                anchors.top: calendar.bottom
                anchors.left: mirror.left
                anchors.leftMargin: 10
                anchors.bottom: mirror.bottom
                width: 780
                viewportHeight: 260
            }

            Weather {
                id: weather
                anchors.top: mirror.top
                anchors.right: mirror.right
                width: mirror.width - 800
            }

            PublicTransport {
                id: publicTransport
                anchors.bottom: mirror.bottom
                anchors.bottomMargin: 110
                anchors.right: mirror.right
                width: 360
            }

            NewsTicker {
                id: newsTicker
                anchors.left: mirror.left
                anchors.bottom: mirror.bottom
                anchors.right: mirror.right
            }
        }
    }

    function shuffle(array) {
        var idx = array.length, aux, randomIdx;
        while (idx !== 0) {
            randomIdx = Math.floor(Math.random() * idx);
            --idx;
            aux = array[idx];
            array[idx] = array[randomIdx];
            array[randomIdx] = aux;
        }
        return array;
    }
}
