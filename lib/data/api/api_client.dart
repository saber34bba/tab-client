import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get/get_connect/http/src/request/request.dart';

import 'package:efood_multivendor/data/model/response/address_model.dart';
import 'package:efood_multivendor/data/model/response/error_response.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as Http;

class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static final String noInternetMessage = 'Connection to API server failed due to internet connection';
  final int timeoutInSeconds = 30;

  String token;
  Map<String, String> _mainHeaders;

  ApiClient({@required this.appBaseUrl, @required this.sharedPreferences}) {
    token = sharedPreferences.getString(AppConstants.TOKEN);
    debugPrint('Token: $token');
    AddressModel _addressModel;
    try {
      _addressModel = AddressModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.USER_ADDRESS)));
      print( _addressModel.toJson());
    }catch(e) {}
    updateHeader(
      token, _addressModel == null ? null : _addressModel.zoneIds,
      sharedPreferences.getString(AppConstants.LANGUAGE_CODE),
    );
  }

Map <String,String> getHeader(){
  return _mainHeaders;
}
  void updateHeader(String token, List<int> zoneIDs, String languageCode) {
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.ZONE_ID: zoneIDs != null ? jsonEncode(zoneIDs) : null,
      AppConstants.LOCALIZATION_KEY: languageCode ?? AppConstants.languages[0].languageCode,
      'Authorization': 'Bearer $token'
    };
  }

  Future<Response<T>> getData<T>(String uri, {Map<String, dynamic> query, Map<String, String> headers, Future<T> Function(String) parser}) async {
    try {
       if(_mainHeaders["X-localization"]=="fr"){
      if(headers!=null){
          headers["X-localization"]="fr-FR";
        }else{
          _mainHeaders["X-localization"]="fr-FR";
        }
        }
      if(uri=="/api/v1/categories"){
        if(_mainHeaders["X-localization"]=="fr"){
      if(headers!=null){
          headers["X-localization"]="fr-FR";
        }else{
          _mainHeaders["X-localization"]="fr-FR";
        }
        }
                print("headeris $headers and ${_mainHeaders}");

      }
      debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
      Http.Response _response = await Http.get(
        Uri.parse(RegExp(r"^http(s)?://").hasMatch(uri) ? uri : (appBaseUrl+uri)),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse<T>(_response, uri, parser);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response<T>> postData<T>(String uri, dynamic body, {Map<String, String> headers, Future<T> Function(String) parser}) async {
    try {
      debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
      debugPrint('====> API Body: $body');
      Http.Response _response = await Http.post(
        Uri.parse(RegExp(r"^http(s)?://").hasMatch(uri) ? uri : (appBaseUrl+uri)),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse<T>(_response, uri, parser);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response<T>> postMultipartData<T>(String uri, Map<String, String> body, List<MultipartBody> multipartBody, {Map<String, String> headers, Future<T> Function(String) parser}) async {
    try {
      debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
      debugPrint('====> API Body: $body with ${multipartBody.length} files');
      Http.MultipartRequest _request = Http.MultipartRequest('POST', 
        Uri.parse(RegExp(r"^http(s)?://").hasMatch(uri) ? uri : (appBaseUrl+uri)),
      );
      _request.headers.addAll(headers ?? _mainHeaders);
      for(MultipartBody multipart in multipartBody) {
        if(multipart.file != null) {
          Uint8List _list = await multipart.file.readAsBytes();
          _request.files.add(Http.MultipartFile(
            multipart.key, multipart.file.readAsBytes().asStream(), _list.length,
            filename: '${DateTime.now().toString()}.png',
          ));
        }
      }
      _request.fields.addAll(body);
      Http.Response _response = await Http.Response.fromStream(await _request.send());
      return handleResponse<T>(_response, uri, parser);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response<T>> putData<T>(String uri, dynamic body, {Map<String, String> headers, Future<T> Function(String) parser}) async {
    try {
      debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
      debugPrint('====> API Body: $body');
      Http.Response _response = await Http.put(
        Uri.parse(RegExp(r"^http(s)?://").hasMatch(uri) ? uri : (appBaseUrl+uri)),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse<T>(_response, uri, parser);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response<T>> deleteData<T>(String uri, {Map<String, String> headers, Future<T> Function(String) parser}) async {
    try {
      debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
      Http.Response _response = await Http.delete(
        Uri.parse(RegExp(r"^http(s)?://").hasMatch(uri) ? uri : (appBaseUrl+uri)),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse<T>(_response, uri, parser);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response<T>> handleResponse<T>(Http.Response response, String uri,Future<T> Function(String) parser) async {
    T _body;
    try {
      _body = await (parser == null ? jsonDecode(response.body.toString()) : parser(response.body));
    }catch(e) {
    }
      print("[_body][${response.request.url}]<${_body.runtimeType}> $_body");
      print("-api_client--ttww ${_body}");
    Response<T> _response = Response(
      body: _body != null ? _body : response.body, 
      bodyString: response.body.toString(),
      request: Request(headers: response.request.headers, method: response.request.method, url: response.request.url),
      headers: response.headers, statusCode: response.statusCode, statusText: response.reasonPhrase,
    );
      print("[response._body][${response.request.url}]<${_response.body.runtimeType}> ${_response.body}");

    if(_response.statusCode != 200 && _response.body != null && _response.body is !String) {
      if(_response.body.toString().startsWith('{errors: [{code:')) {
        ErrorResponse _errorResponse = ErrorResponse.fromJson(_response.body);
        _response = Response(statusCode: _response.statusCode, body: _response.body, statusText: _errorResponse.errors[0].message);
      }else if(_response.body.toString().startsWith('{message')) {
        _response = Response(statusCode: _response.statusCode, body: _response.body, statusText: _response.body is Map ? (_response.body as Map)['message'] : "");
      }
    }else if(_response.statusCode != 200 && _response.body == null) {
      _response = Response(statusCode: 0, statusText: noInternetMessage);
    }
    debugPrint('====> API Response: [${_response.statusCode}] $uri\n${_response.body}');
    return _response;
  }
}

class MultipartBody {
  String key;
  XFile file;

  MultipartBody(this.key, this.file);
}