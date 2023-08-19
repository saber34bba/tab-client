import 'package:efood_multivendor/data/api/api_client.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class TraiteurRepo {
  
  final ApiClient apiClient;
  TraiteurRepo({@required this.apiClient});

  Future<Response> askTraiteur(Map<String, String> data) async {
    return await apiClient.postData(AppConstants.TRAITEUR_URI, data);
  }

}