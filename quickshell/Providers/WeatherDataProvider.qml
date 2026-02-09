import ".."
import QtQuick
import Quickshell.Io
pragma Singleton

QtObject {
    // map symbol_code to icon
    // Clear / clouds
    // Rain
    // Thunder
    // Snow
    // Sleet
    // Fog

    id: weatherData

    property double lat: SettingsManager.weatherCoords[0]
    property double lon: SettingsManager.weatherCoords[1]
    property Process getWeatherDataProcess
    // weather data params
    property string temp: ""
    property string icon: ""
    property string wText: ""
    property date latestUpdate
    // weather map
    property var weatherIcons: ({
        "clearsky_day": {
            "icon": "󰖙",
            "english": "Clear sky"
        },
        "clearsky_night": {
            "icon": "󰖔",
            "english": "Clear sky"
        },
        "fair_day": {
            "icon": "󰖕",
            "english": "Fair"
        },
        "fair_night": {
            "icon": "󰼱",
            "english": "Fair"
        },
        "partlycloudy_day": {
            "icon": "󰖕",
            "english": "Partly cloudy"
        },
        "partlycloudy_night": {
            "icon": "󰼱",
            "english": "Partly cloudy"
        },
        "cloudy": {
            "icon": "󰖐",
            "english": "Cloudy"
        },
        "lightrain": {
            "icon": "󰖗",
            "english": "Light rain"
        },
        "rain": {
            "icon": "󰖖",
            "english": "Rain"
        },
        "heavyrain": {
            "icon": "󰖖",
            "english": "Heavy rain"
        },
        "rainshowers": {
            "icon": "󰖖",
            "english": "Rain showers"
        },
        "lightrainshowers": {
            "icon": "󰖗",
            "english": "Light rain showers"
        },
        "heavyrainshowers": {
            "icon": "󰖖",
            "english": "Heavy rain showers"
        },
        "rainandthunder": {
            "icon": "󰖓",
            "english": "Rain and thunder"
        },
        "rainshowersandthunder": {
            "icon": "󰖓",
            "english": "Rain showers and thunder"
        },
        "snow": {
            "icon": "󰖘",
            "english": "Snow"
        },
        "lightsnow": {
            "icon": "󰖘",
            "english": "Light snow"
        },
        "heavysnow": {
            "icon": "󰖘",
            "english": "Heavy snow"
        },
        "snowshowers": {
            "icon": "󰖘",
            "english": "Snow showers"
        },
        "sleet": {
            "icon": "󰖒",
            "english": "Sleet"
        },
        "lightsleet": {
            "icon": "󰖒",
            "english": "Light sleet"
        },
        "heavysleet": {
            "icon": "󰖒",
            "english": "Heavy sleet"
        },
        "fog": {
            "icon": "󰖑",
            "english": "Fog"
        }
    })

    signal weatherDataReady(var data)

    function getWeatherData() {
        getWeatherDataProcess.running = true;
    }

    function parseWeatherData(data) {
        let now = new Date();
        // use weather data
        // find the dataPoint closest to current time
        let dataPoints = data.properties.timeseries;
        let currentPoint = null;
        // within 31 minutes
        let smallestDiff = 31 * 60 * 1000;
        for (let i = 0; i < dataPoints.length; i++) {
            let pointTime = new Date(dataPoints[i].time);
            let diff = Math.abs(now - pointTime);
            if (diff < smallestDiff) {
                currentPoint = dataPoints[i];
                break;
            }
        }
        if (currentPoint) {
            if (currentPoint.data.instant.details.air_temperature)
                temp = currentPoint.data.instant.details.air_temperature;

            if (currentPoint.data.next_1_hours.summary.symbol_code) {
                icon = weatherIcons[currentPoint.data.next_1_hours.summary.symbol_code].icon;
                wText = weatherIcons[currentPoint.data.next_1_hours.summary.symbol_code].english;
            }
            if (currentPoint.time)
                latestUpdate = new Date(currentPoint.time);

        } else {
            temp = "NULL";
            icon = "󰼯";
            wText = "No data";
        }
        weatherData.weatherDataReady({
            "temp": temp,
            "icon": icon,
            "wText": wText,
            "latestUpdate": latestUpdate
        });
    }

    getWeatherDataProcess: Process {
        running: false
        command: ["curl", "-H", "User-Agent: quickshell-weather/1.0", "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=" + weatherData.lat + "&lon=" + weatherData.lon]

        stdout: StdioCollector {
            onStreamFinished: {
                let data = JSON.parse(text);
                weatherData.parseWeatherData(data);
            }
        }

    }

}
