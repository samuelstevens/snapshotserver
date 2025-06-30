"""
Quick grab of National Weather Service data for The Ohio State University (40.0076 N, -83.0300 W).
"""

import requests

_LAT, _LON = 40.0076, -83.0300
_HEADERS = {
    # NWS blocks requests that lack an identifying UA/contact.
    "User-Agent": "snapshotserver (samuel.robert.stevens@gmail.com)"
}


def get_weather(coords: tuple[float, float]) -> dict[str, str]:
    """Return the current hour’s forecast for OSU’s main campus."""
    # 1. Map lat/lon to the grid endpoint
    lat, lon = coords
    r = requests.get(
        f"https://api.weather.gov/points/{lat},{lon}",
        headers=_HEADERS,
        timeout=10,
    )
    r.raise_for_status()
    grid = r.json()["properties"]

    # 2. Follow the hourly forecast URL
    hr = requests.get(grid["forecastHourly"], headers=_HEADERS, timeout=10)
    hr.raise_for_status()
    current = hr.json()["properties"]["periods"][0]  # first = now

    return {
        "timestamp": current["startTime"],
        "temperature": f"{current['temperature']} {current['temperatureUnit']}",
        "wind": f"{current['windSpeed']} {current['windDirection']}",
        "short": current["shortForecast"],
        "detailed": current["detailedForecast"],
    }
