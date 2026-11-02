import ".."
import QtQuick
import Quickshell.Io
pragma Singleton

QtObject {
    id: weatherData

    property double lat: SettingsManager.weatherCoords[0]
    property double lon: SettingsManager.weatherCoords[1]
    property Process getWeatherDataProcess
    // weather data
    property var wData
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
        const dataPoints = data?.properties?.timeseries;
        let weatherPoints = [];
        let smallestDiff = 31 * 60 * 1000;
        if (Array.isArray(dataPoints)) {
            for (let i = 0; i < dataPoints.length; i++) {
                const diff = Math.abs(Date.now() - new Date(dataPoints[i]?.time).getTime());
                if (diff < smallestDiff) {
                    smallestDiff = diff;
                    weatherPoints = dataPoints.slice(i, i + 4);
                }
            }
        }
        const wPoints = weatherPoints.map(point => {
            const details = point?.data;
            const temperature = details?.instant?.details?.air_temperature;
            const symbol = details?.next_1_hours?.summary?.symbol_code
                || details?.next_6_hours?.summary?.symbol_code
                || details?.next_12_hours?.summary?.symbol_code || "";
            const info = weatherIcons[symbol]
                || weatherIcons[symbol.replace(/_(day|night|polartwilight)$/, "")];
            return {
                "temp": Number.isFinite(temperature) ? temperature : "",
                "icon": info ? info.icon : "󰼯",
                "wText": info ? info.english : "No data",
                "latestUpdate": point?.time ? new Date(point.time) : null
            };
        });
        weatherData.weatherDataReady(wPoints);
    }

    getWeatherDataProcess: Process {
        running: false
        command: ["curl", "--fail", "--silent", "--show-error", "--connect-timeout", "5", "--max-time", "15", "-H", "User-Agent: quickshell-weather/1.0", "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=" + weatherData.lat + "&lon=" + weatherData.lon]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    weatherData.parseWeatherData(JSON.parse(text));
                } catch (error) {
                    console.warn("[WeatherDataProvider] Invalid weather response:", error);
                    weatherData.weatherDataReady([]);
                }
            }
        }

    }

}
