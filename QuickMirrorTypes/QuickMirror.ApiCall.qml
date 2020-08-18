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
import Process 1.0

Item {
    id: apiCall
    property var url: ""
    property var path: []
    property var query: []

    signal response(var response)
    signal error(var error)

    Process {
        id: curl
        property var path: Q_OS_WIN ? "C:\\Windows\\System32\\curl.exe" : "/usr/bin/curl"
        property var request: ""
        command: path + " -s \"" + request + "\""
    }

    function sendRequest() {
        curl.request = url;
        if (path.length > 0)
            curl.request += "/" + path.join("/");
        if (query.length > 0)
            curl.request += "?" + query.join("&");
        curl.start();
    }

    Connections {
        target: curl
        onExit /*(int exitCode, QByteArray processOutput)*/ : {
            if (exitCode != 0) {
                console.log("ApiCall: exit " + exitCode);
                console.log("==== ApiCall: request: " + curl.request);
                return error("exit " + exitCode);
            }
            try {
                return response(JSON.parse(processOutput));
            } catch (err) {
                console.log("ApiCall: error: " + err.toString());
                console.log("==== ApiCall: request: " + curl.request);
                console.log("==== ApiCall: response: " + processOutput);
                return error(err);
            }
        }
    }
}
