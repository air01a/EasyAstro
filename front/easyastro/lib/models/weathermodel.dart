
import 'dart:convert';
import 'package:easyastro/services/api.dart';



/// step 3. call the class that fetches response from API and pass URL
/// we can get data by location coordinates or city name
/// N.B there are many other ways of getting weather data through the url
const weatherHost = 'api.openweathermap.org';
const apiKey = '89c8569620e5e090818c5e03f427ee79';

class WeatherModel {
  Future<dynamic> getCityWeather(String cityName) async {
    var url = '/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric';
    ApiBaseHelper networkHelper = ApiBaseHelper();
    var weatherData = networkHelper.get(weatherHost, url);
    return weatherData;
  }

  Future<dynamic> getLocationWeather(double longitude, double latitude) async {
    /// Get location
    /// await for methods that return future

    var url = "/data/2.5/weather";
    var parameters = {'lat':latitude, 'lon': longitude, 'appid':apiKey};
    print(url);
    print(weatherHost);
    //var url = "/data/3.0/onecall?lat=$latitude&lon=$longitude&exclude={part}&appid=$apiKey";
    /// Get location data
    ApiBaseHelper networkHelper = ApiBaseHelper();

    var weatherData = networkHelper.get(weatherHost, url,  ssl:true, queryParameters: parameters);
    print(weatherData);
    return weatherData;
  }

  /// add appropriete icon to page  according to response from API
  String getWeatherIcon(int condition) {
    if (condition < 300) {
      return '🌩';
    } else if (condition < 400) {
      return '🌧';
    } else if (condition < 600) {
      return '☔️';
    } else if (condition < 700) {
      return '☃️';
    } else if (condition < 800) {
      return '🌫';
    } else if (condition == 800) {
      return '☀️';
    } else if (condition <= 804) {
      return '☁️';
    } else {
      return '🤷‍';
    }
  }

  String getMessage(int temp) {
    if (temp > 25) {
      return 'It\'s 🍦 time';
    } else if (temp > 20) {
      return 'Time for shorts and 👕';
    } else if (temp < 10) {
      return 'You\'ll need 🧣 and 🧤';
    } else {
      return 'Bring a 🧥 just in case';
    }
  }
}