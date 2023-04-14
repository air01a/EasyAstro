import 'dart:io';
import 'package:front_test/services/apiexception.dart';
import 'package:front_test/services/globals.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';


class ApiBaseHelper {
  final String _baseUrl = ServerInfo().host;


  Future<dynamic> get(String url) async {
    print('Api Get, url $url');
    dynamic responseJson;
    try {
      final response = await http.get(Uri.http(_baseUrl, url));
      responseJson = _returnResponse(response);
    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    }
    print('api get recieved!');
    return responseJson;
  }

  Future<dynamic> post(String url, dynamic body) async {
    print('Api Post, url $url ${jsonEncode(body)}');
    dynamic responseJson;
    try {
      final response = await http.post(Uri.http(_baseUrl, url), headers: <String, String>{
                                  'Content-Type': 'application/json',
                                },body: jsonEncode(body));
      responseJson = _returnResponse(response);
    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    }
    print('api post.');
    return responseJson;
  }

  Future<dynamic> put(String url, dynamic body) async {
    print('Api Put, url $url ${jsonEncode(body)}');
    dynamic responseJson;
    try {
      final response = await http.put(Uri.http(_baseUrl, url), body: jsonEncode(body));
      responseJson = _returnResponse(response);
    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    }
    print('api put.');
    print(responseJson.toString());
    return responseJson;
  }

  Future<dynamic> delete(String url) async {
    print('Api delete, url $url');
    var apiResponse;
    try {
      final response = await http.delete(Uri.http(_baseUrl, url));
      apiResponse = _returnResponse(response);
    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    }
    print('api delete.');
    return apiResponse;
  }
  
dynamic _returnResponse(http.Response response) {
  switch (response.statusCode) {
    case 200:
      var responseJson = json.decode(response.body.toString());
      print(responseJson);
      return responseJson;
    case 400:
      throw BadRequestException(response.body.toString());
    case 401:
    case 403:
      throw UnauthorisedException(response.body.toString());
    case 500:
    default:
      throw FetchDataException(
          'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}

