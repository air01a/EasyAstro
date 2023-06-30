import 'dart:io';
import 'package:easyastro/services/network/apiexception.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';


class ApiBaseHelper {
 // final String _baseUrl = ServerInfo().host;

  String lastErrorStr='no_error';
  int lastError = 0;

  Uri getUri(String host, String url, bool? ssl, {Map<String,dynamic>? queryParameters}) {
    var function = Uri.http;
    if (queryParameters == null) queryParameters = {};
    if (ssl!=null && ssl) {
      function = Uri.https;
    }

    return function(host, url,queryParameters);
  }

  Future<dynamic> get(String host, String url, {Map<String,dynamic>? queryParameters,  bool? ssl, bool? binary}) async {
    dynamic responseJson;
    http.Response response;
    try {
      response = await http.get(getUri(host, url, ssl, queryParameters: queryParameters));
      if (binary==null || binary==false) { 
        responseJson = _returnResponse(response);
        return responseJson;
      } else {
        return response.bodyBytes;
      }
    } on SocketException {
      lastError=1;
      lastErrorStr="no_connection";
      //throw FetchDataException('No Internet connection');
    }
    
  }

  Future<dynamic> post(String host, String url, dynamic body,{ bool? ssl}) async {

    dynamic responseJson;
    try {
      final response = await http.post(getUri(host, url, ssl), headers: <String, String>{
                                  'Content-Type': 'application/json',
                                },body: jsonEncode(body));
      responseJson = _returnResponse(response);
    } catch(_)  {
        lastError=1;
        lastErrorStr="no_connection";
        return null;
    }
    return responseJson;
  }

  Future<dynamic> put(String host, String url, dynamic body,{ bool? ssl}) async {

    dynamic responseJson;
    try {
      final response = await http.put(getUri(host, url, ssl), body: jsonEncode(body));
      responseJson = _returnResponse(response);
    } catch(_) {
        lastError=1;
        lastErrorStr="no_connection";
    }

    return responseJson;
  }

  Future<dynamic> delete(String host, String url,{ bool? ssl}) async {
    var apiResponse;
    try {
      final response = await http.delete(getUri(host, url, ssl));
      apiResponse = _returnResponse(response);
    } catch(_) {
        lastError=1;
        lastErrorStr="no_connection";
    }
    return apiResponse;
  }
  
dynamic _returnResponse(http.Response response) {
  switch (response.statusCode) {
    case 200:
      var responseJson = json.decode(response.body.toString());
      return responseJson;
    case 400:
          lastError=400;
          lastErrorStr=response.body.toString();
      throw BadRequestException(response.body.toString());
    case 401:
    case 403:
          lastError=400;
          lastErrorStr=response.body.toString();
      throw UnauthorisedException(response.body.toString());
    case 500:
    default:
          lastError=4;
          lastErrorStr="Error occured while Communication with Server with StatusCode : ${response.statusCode}";
      throw FetchDataException(
          'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}

