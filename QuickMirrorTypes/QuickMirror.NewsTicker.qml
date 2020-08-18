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
    id: newsTicker
    opacity: 0.0

    property var articles
    property var idxArticle: 0
    property var article

    ApiCall {
        id: newsApi
        property string fromDateTime
        url: "https://newsapi.org"; path: [ "v2", "everything" ]
        query: [
            "domains=" + ([ "washingtonpost.com",
                            "msnbc.com",
                            "berliner-zeitung.de",
                            "spiegel.de",
                            "publico.pt", ]).join(","),
            "from=" + fromDateTime,
            "pageSize=100",
            "apiKey=" + API_KEY_NEWS
        ]
        onResponse: {
            articles = [];
            for (var i in response.articles) {
                var a = response.articles[i];
                if (filterArticle(a))
                    articles.push(a);
            }
            articles = shuffle(articles);
            newsTicker.next();
        }
        onError: {
            articles = [];
        }
    }

    function filterArticle(a) {
        if (a.source.name.length == 0 || a.source.name.search(/[\x00-\x1F]/) >= 0)
            return false;
        if (a.title.length == 0 || a.title.search(/[\x00-\x1F]/) >= 0)
            return false;
        if (a.description.length == 0 || a.description.search(/[\x00-\x1F]/) >= 0)
            return false;
        return true;
    }

    function init() {
        idxArticle = -1;
        newsApi.fromDateTime = (new Date(Date.now() - (24 * 60 * 60 * 1000))).toISOString();
        newsApi.sendRequest();
    }

    function next() {
        if (articles.length > 0) {
            if (idxArticle >= articles.length) {
                idxArticle = -1;
                articles = shuffle(articles);
            }
            do {
                idxArticle++;
            } while (idxArticle < articles.length && articles[idxArticle].description.length == 0);
            if (idxArticle < articles.length) {
                article = articles[idxArticle];
                fadeOut.start();
            }
        }
    }

    Component.onCompleted: init();

    Timer {
        id: timerRetry
        interval: 10000; running: true; repeat: true
        onTriggered: {
            if (articles.length == 0)
                init();
        }
    }

    Timer {
        id: timerInit
        interval: 600000; running: true; repeat: true
        onTriggered: {
            init();
        }
    }

    NumberAnimation {
        id: fadeOut;
        target: newsTicker; property: "opacity"; to: 0.0; duration: 1000
        onFinished: {
            packet.text = article.description;
            newsSource.text = article.source.name;
            newsTitle.text = article.title;
            news.text = packet.text;
            news.x = 20;
            fadeIn.start();
        }
    }

    NumberAnimation {
        id: fadeIn
        target: newsTicker; property: "opacity"; to: 1.0; duration: 1000
        onFinished: {
            scrollText.start();
        }
    }

    SequentialAnimation {
        id: scrollText
        PropertyAction { target: news; property: "x"; value: 20 }
        NumberAnimation { target: news; property: "opacity"; to: 1.0; duration: 500 }
        PauseAnimation { duration: 3500 }
        NumberAnimation {
            target: news
            property: "x"; from: 20; to: Math.min(-packet.width + newsTicker.width - 20, 20)
            duration: Math.max(0, (Math.abs(to - from) * 1000) / 45)
        }
        PauseAnimation { duration: 3000 }
        NumberAnimation {
            target: news;
            property: "opacity"; to: ((packet.width > newsTicker.width) ? 0.0 : 1.0);
            duration: 50
        }
        onFinished: {
            newsTicker.next();
        }
    }

    Text {
        renderType: Text.NativeRendering
        id: newsSource
        x: 20
        anchors.bottom: newsTitle.top
        anchors.bottomMargin: 6
        font.family: FontFamily_Bold
        font.styleName: FontStyle_Bold
        font.pointSize: 22
        color: "white"
    }

    Rectangle {
        x: 0; width: newsSource.width + 40
        anchors.top: newsSource.bottom
        height: 1
        color: "white"
    }

    Text {
        renderType: Text.NativeRendering
        id: newsTitle
        x: 20
        anchors.bottom: news.top
        anchors.bottomMargin: 6
        font.family: FontFamily_Bold
        font.styleName: FontStyle_Bold
        font.pointSize: 26
        color: "white"
    }

    TextMetrics {
        id: packet
        font.family: FontFamily_Normal
        font.styleName: FontStyle_Normal
        font.pointSize: 26
    }

    Text {
        renderType: Text.NativeRendering
        id: news
        x: 20
        anchors.bottom: parent.bottom
        font: packet.font
        color: "white"
        width: packet.width
        height: packet.height
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: news.height + newsTitle.height
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "black" }
            GradientStop { position: 0.015; color: "transparent" }
            GradientStop { position: 0.985; color: "transparent" }
            GradientStop { position: 1; color: "black" }
        }
    }
}
