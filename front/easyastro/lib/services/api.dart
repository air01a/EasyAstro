import 'dart:io';
import 'package:easyastro/services/apiexception.dart';
import 'package:easyastro/services/globals.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';


class ApiBaseHelper {
 // final String _baseUrl = ServerInfo().host;


  Uri getUri(String host, String url, bool? ssl, {Map<String,dynamic>? queryParameters}) {
    var function = Uri.http;
    if (queryParameters == null) queryParameters = {};
    if (ssl!=null && ssl) {
      function = Uri.https;
    }

    return function(host, url,queryParameters);
  }

  Future<dynamic> get(String host, String url, {Map<String,dynamic>? queryParameters,  bool? ssl}) async {
    dynamic responseJson;
    http.Response response;
    try {
      response = await http.get(getUri(url, host, ssl, queryParameters: queryParameters));
      responseJson = _returnResponse(response);
    } on SocketException {

      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> post(String host, String url, dynamic body,{ bool? ssl}) async {

    dynamic responseJson;
    try {
      final response = await http.post(getUri(url, host, ssl), headers: <String, String>{
                                  'Content-Type': 'application/json',
                                },body: jsonEncode(body));
      responseJson = _returnResponse(response);
    } on SocketException {

      throw FetchDataException('No Internet connection');
    }

    return responseJson;
  }

  Future<dynamic> put(String host, String url, dynamic body,{ bool? ssl}) async {

    dynamic responseJson;
    try {
      final response = await http.put(getUri(url, host, ssl), body: jsonEncode(body));
      responseJson = _returnResponse(response);
    } on SocketException {

      throw FetchDataException('No Internet connection');
    }

    return responseJson;
  }

  Future<dynamic> delete(String host, String url,{ bool? ssl}) async {
    var apiResponse;
    try {
      final response = await http.delete(getUri(url, host, ssl));
      apiResponse = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return apiResponse;
  }
  
dynamic _returnResponse(http.Response response) {
  switch (response.statusCode) {
    case 200:
      var responseJson = json.decode(response.body.toString());
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

