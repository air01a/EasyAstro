
import 'package:easyastro/services/network/api.dart';



/// step 3. call the class that fetches response from API and pass URL
/// we can get data by location coordinates or city name
/// N.B there are many other ways of getting weather data through the url
const weatherHost = 'api.openweathermap.org';


class WeatherModel {
  String apiKey;

  WeatherModel(this.apiKey);

  Future<dynamic> getCityWeather(String cityName) async {
    var url = '/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric';
    ApiBaseHelper networkHelper = ApiBaseHelper();
    var weatherData = networkHelper.get(weatherHost, url);
    return weatherData;
  }

  Future<dynamic> getLocationWeather(double longitude, double latitude) async {
    /// Get location
    /// await for methods that return future

    const String url = "/data/2.5/weather";
    var parameters = {'lat':latitude.toString(), 'lon': longitude.toString(), 'appid':apiKey};
    //var url = "/data/3.0/onecall?lat=$latitude&lon=$longitude&exclude={part}&appid=$apiKey";
    /// Get location data
    ApiBaseHelper networkHelper = ApiBaseHelper();

    var weatherData = networkHelper.get(weatherHost, url,  ssl:true, queryParameters: parameters);

    return weatherData;
  }

    Future<dynamic> getLocationForecast(double longitude, double latitude) async {
    /// Get location
    /// await for methods that return future

    const String url = "/data/2.5/forecast";
    var parameters = {'lat':latitude.toString(), 'lon': longitude.toString(), 'appid':apiKey};
    //var url = "/data/3.0/onecall?lat=$latitude&lon=$longitude&exclude={part}&appid=$apiKey";
    /// Get location data
    ApiBaseHelper networkHelper = ApiBaseHelper();

    var weatherData = networkHelper.get(weatherHost, url,  ssl:true, queryParameters: parameters);

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

  String getMessage(int condition) {
    if (condition < 300) {
        return 'absolutly_not_suitable';
      } else if (condition < 400) {
        return 'absolutly_not_suitable';
      } else if (condition < 600) {
        return 'absolutly_not_suitable';
      } else if (condition < 700) {
        return 'absolutly_not_suitable';
      } else if (condition < 800) {
        return 'not_suitable';
      } else if (condition == 800) {
        return 'perfect';
      } else if (condition <= 804) {
        return 'not_suitable';
      } else {
        return 'idk';
      }
  }
}