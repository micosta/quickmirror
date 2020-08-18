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
    id: weather

    property var current
    property var hourly: []

    ApiCall {
        id: weatherApi
        url: "https://api.openweathermap.org"; path: [ "data", "2.5", "onecall" ]
        query: [
            "appid=" + API_KEY_WEATHER,
            "lat=52.544799",
            "lon=13.427421",
            "units=metric",
            "exclude=minutely,daily"
        ]
        onResponse: {
            if ("current" in response) {
                current = response.current
                currentTemp.text = current.temp.toFixed(1) + "°C";
                currentFeelsLike.text = current.feels_like.toFixed(1) + "°C";
                currentIcon.source = "/png/256/256-" + getIcon(current.weather[0]) + ".png";
            }

            if ("hourly" in response) {
                hourly = [
                    response.hourly[1],
                    response.hourly[2],
                    response.hourly[3],
                    response.hourly[5],
                    response.hourly[8],
                    response.hourly[13],
                    response.hourly[21],
                ];
                forecast.model = hourly;
            }
        }
        onError: {
        }
    }

    function getIcon(w) {
        var isNight = w.icon.endsWith("n");
        var iconSet = weatherIcons[w.id];
        return isNight ? iconSet.night : iconSet.day;
    }

    Component.onCompleted: {
        weatherApi.sendRequest();
    }

    Timer {
        id: timerRetry
        interval: 10000; running: true; repeat: true
        onTriggered: {
            if (hourly.length == 0)
                weatherApi.sendRequest();
        }
    }

    Timer {
        id: timerRefresh
        interval: 300000; running: true; repeat: true
        onTriggered: {
            weatherApi.sendRequest();
        }
    }

    Image {
        id: currentIcon
        width: sourceSize.width
        height: sourceSize.height
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: -20
    }
    Text {
        renderType: Text.NativeRendering
        id: currentTemp
        font.family: FontFamily_Bold
        font.styleName: FontStyle_Bold
        font.pointSize: 72
        color: "white"
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: -30
    }
    Text {
        renderType: Text.NativeRendering
        id: currentFeelsLike
        font.family: FontFamily_Normal
        font.styleName: FontStyle_Normal
        font.pointSize: 66
        color: "lightsteelblue"
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: -25
    }
    Repeater {
        id: forecast
        model: []
        RowLayout {
            Layout.topMargin: -25
            Layout.alignment: Qt.AlignHCenter
            ColumnLayout {
                Layout.leftMargin: 20
                Layout.minimumWidth: 128
                Layout.maximumWidth: 128
                Image {
                    id: forecastIcon
                    source: "/png/128/128-" + getIcon(modelData.weather[0]) + ".png"
                    width: 128; height: 128
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    renderType: Text.NativeRendering
                    id: forecastTime
                    text: (new Date(modelData.dt * 1000)).toLocaleTimeString(Qt.locale("de_DE"), "hh:mm")
                    font.family: FontFamily_WeatherTime
                    font.styleName: FontStyle_WeatherTime
                    font.pointSize: 20
                    color: "white"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: -20
                }
            }
            ColumnLayout {
                Rectangle {
                    Layout.fillWidth: true
                    height: 0
                    color: "blue"
                }
                Text {
                    renderType: Text.NativeRendering
                    id: forecastTemp
                    text: modelData.temp.toFixed(1) + "°C"
                    font.family: FontFamily_Bold
                    font.styleName: FontStyle_Bold
                    font.pointSize: 32
                    color: "white"
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    renderType: Text.NativeRendering
                    id: forecastFeelsLike
                    text: modelData.feels_like.toFixed(1) + "°C"
                    font.family: FontFamily_Normal
                    font.styleName: FontStyle_Normal
                    font.pointSize: 28
                    color: "lightsteelblue"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: -10
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "white"
                }
            }
        }
    }

    property var weatherIcons:
    {
        200: { id: 200, description: 'thunderstorm with light rain', day: '41', night: '42' },
        201: { id: 201, description: 'thunderstorm with rain', day: '40', night: '40' },
        202: { id: 202, description: 'thunderstorm with heavy rain', day: '45', night: '45' },
        210: { id: 210, description: 'light thunderstorm', day: '06', night: '07' },
        211: { id: 211, description: 'thunderstorm', day: '09', night: '09' },
        212: { id: 212, description: 'heavy thunderstorm', day: '10', night: '10' },
        221: { id: 221, description: 'ragged thunderstorm', day: '47', night: '47' },
        230: { id: 230, description: 'thunderstorm with light drizzle', day: '31', night: '32' },
        231: { id: 231, description: 'thunderstorm with drizzle', day: '30', night: '30' },
        232: { id: 232, description: 'thunderstorm with heavy drizzle', day: '35', night: '35' },
        300: { id: 300, description: 'light intensity drizzle', day: '28', night: '29' },
        301: { id: 301, description: 'drizzle', day: '26', night: '26' },
        302: { id: 302, description: 'heavy intensity drizzle', day: '27', night: '27' },
        310: { id: 310, description: 'light intensity drizzle rain', day: '28', night: '29' },
        311: { id: 311, description: 'drizzle rain', day: '26', night: '26' },
        312: { id: 312, description: 'heavy intensity drizzle rain', day: '27', night: '27' },
        313: { id: 313, description: 'shower rain and drizzle', day: '26', night: '26' },
        314: { id: 314, description: 'heavy shower rain and drizzle', day: '27', night: '27' },
        321: { id: 321, description: 'shower drizzle', day: '26', night: '26' },
        500: { id: 500, description: 'light rain', day: '38', night: '39' },
        501: { id: 501, description: 'moderate rain', day: '36', night: '36' },
        502: { id: 502, description: 'heavy intensity rain', day: '37', night: '37' },
        503: { id: 503, description: 'very heavy rain', day: '37', night: '37' },
        504: { id: 504, description: 'extreme rain', day: '37', night: '37' },
        511: { id: 511, description: 'freezing rain', day: '25', night: '25' },
        520: { id: 520, description: 'light intensity shower rain', day: '38', night: '39' },
        521: { id: 521, description: 'shower rain', day: '36', night: '36' },
        522: { id: 522, description: 'heavy intensity shower rain', day: '37', night: '37' },
        531: { id: 531, description: 'ragged shower rain', day: '37', night: '37' },
        600: { id: 600, description: 'light snow', day: '25', night: '25' },
        601: { id: 601, description: 'Snow', day: '25', night: '25' },
        602: { id: 602, description: 'Heavy snow', day: '25', night: '25' },
        611: { id: 611, description: 'Sleet', day: '25', night: '25' },
        612: { id: 612, description: 'Light shower sleet', day: '25', night: '25' },
        613: { id: 613, description: 'Shower sleet', day: '25', night: '25' },
        615: { id: 615, description: 'Light rain and snow', day: '25', night: '25' },
        616: { id: 616, description: 'Rain and snow', day: '25', night: '25' },
        620: { id: 620, description: 'Light shower snow', day: '25', night: '25' },
        621: { id: 621, description: 'Shower snow', day: '25', night: '25' },
        622: { id: 622, description: 'Heavy shower snow', day: '25', night: '25' },
        701: { id: 701, description: 'mist', day: '01', night: '01' },
        711: { id: 711, description: 'Smoke', day: '01', night: '01' },
        721: { id: 721, description: 'Haze', day: '01', night: '01' },
        731: { id: 731, description: 'sand/ dust whirls', day: '01', night: '01' },
        741: { id: 741, description: 'fog', day: '01', night: '01' },
        751: { id: 751, description: 'sand', day: '01', night: '01' },
        761: { id: 761, description: 'dust', day: '01', night: '01' },
        762: { id: 762, description: 'volcanic ash', day: '01', night: '01' },
        771: { id: 771, description: 'squalls', day: '24', night: '24' },
        781: { id: 781, description: 'tornado', day: '22', night: '22' },
        800: { id: 800, description: 'clear sky', day: '18', night: '19' },
        801: { id: 801, description: 'few clouds: 11-25%', day: '03', night: '08' },
        802: { id: 802, description: 'scattered clouds: 25-50%', day: '05', night: '04' },
        803: { id: 803, description: 'broken clouds: 51-84%', day: '01', night: '01' },
        804: { id: 804, description: 'overcast clouds: 85-100%', day: '02', night: '02' },
    }
}
