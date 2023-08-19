import 'dart:async';

import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/data/api/api_client.dart';
import 'package:efood_multivendor/data/model/body/delivery_man_body.dart';
import 'package:efood_multivendor/data/model/body/restaurant_body.dart';
import 'package:efood_multivendor/data/model/body/signup_body.dart';
import 'package:efood_multivendor/data/model/body/social_log_in_body.dart';
import 'package:efood_multivendor/firebase_options.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  AuthRepo({@required this.apiClient, @required this.sharedPreferences});

  Future<Response> registration(SignUpBody signUpBody) async {
    return await apiClient.postData(AppConstants.REGISTER_URI, signUpBody.toJson());
  }

  Future<Response> login({String phone, String password}) async {
    return await apiClient.postData(AppConstants.LOGIN_URI, {"phone": phone, "password": password});
  }
   

  Future<Response> loginWithSocialMedia(Map<String,String>map,bool facebook,bool gmail,bool apple) async {
    return await apiClient.postData(AppConstants.SOCIAL_LOGIN_URL, map);
  }

  Future<Response> registerWithSocialMedia(SocialLogInBody socialLogInBody) async {
    return await apiClient.postData(AppConstants.SOCIAL_REGISTER_URL, socialLogInBody.toJson());
  }
  Future<Response> _subscribeToTopic({String token,String topic, bool unsubscribe}) async {
    print("FirebaseMessaging >> ${unsubscribe ?? false ? "UN" : "" }REGISTER TOPIC ${topic ?? AppConstants.TOPIC}");
    if(!GetPlatform.isWeb) {
      if(unsubscribe ?? false){
        FirebaseMessaging.instance.unsubscribeFromTopic(topic ??AppConstants.TOPIC);
      }else{
        FirebaseMessaging.instance.subscribeToTopic(topic ??AppConstants.TOPIC);
      }
    }else {
      var r = await apiClient.postData("https://iid.googleapis.com/iid/v1:batch${unsubscribe ?? false ? 'Remove' : 'Add'}",{
        "to" : "/topics/${topic ??AppConstants.TOPIC}",
        "registration_tokens": [token]
      },
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key='+DefaultFirebaseOptions.ServerKey
        });
      print("RESUKT ${r.bodyString}");
    }
  }
  Future<Response> subscribeToTopic(String token,[String topic]) async {
    return _subscribeToTopic(token: token, topic: topic, unsubscribe: false);
  }
  Future<Response> unsubscribeFromTopic(String token,[String topic]) async {
    return _subscribeToTopic(token: token, topic: topic, unsubscribe: true);
  }
  Future<Response> updateToken({
    String topic,
    String oldTopic,
  }) async {
    String _deviceToken;
    if (GetPlatform.isIOS && !GetPlatform.isWeb) {
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true, announcement: false, badge: true, carPlay: false,
        criticalAlert: false, provisional: false, sound: true,
      );
      if(settings.authorizationStatus == AuthorizationStatus.authorized) {
        _deviceToken = await _saveDeviceToken();
      }
    }else {
      _deviceToken = await _saveDeviceToken();
    }
    if(oldTopic!=null){
      await unsubscribeFromTopic(_deviceToken);
    }
    await subscribeToTopic(_deviceToken);
    return await apiClient.postData(AppConstants.TOKEN_URI, {"_method": "put", "cm_firebase_token": _deviceToken});
  }

  Future<String> _saveDeviceToken() async {
    String _deviceToken = '@';
    // if(!GetPlatform.isWeb) {
      try {
        _deviceToken = await FirebaseMessaging.instance.getToken();
      }catch(e) {}
    // }
    if (_deviceToken != null) {
      print('--------Device Token---------- '+_deviceToken);
    }
    return _deviceToken;
  }

  Future<Response> forgetPassword(String email, String phone) async {
    return await apiClient.postData(AppConstants.FORGET_PASSWORD_URI+"?NDD9ZVAFOUVJT75709S4ZPM6", {
      ...((phone ?? "").isNotEmpty ? {"phone": phone} : {}), 
      ...((email ??"").isNotEmpty ? {"email": email} : {}),
    });
  }

  Future<Response> verifyToken(String email, String phone, String token) async {
    return await apiClient.postData(AppConstants.VERIFY_TOKEN_URI, {"email" : email, "phone": phone, "reset_token": token});
  }

  Future<Response> resetPassword(String resetToken, String number, String password, String confirmPassword) async {
    return await apiClient.postData(
      AppConstants.RESET_PASSWORD_URI,
      {"_method": "put", "reset_token": resetToken, "phone": number, "password": password, "confirm_password": confirmPassword},
    );
  }

  Future<Response> checkEmail(String email) async {
    return await apiClient.postData(AppConstants.CHECK_EMAIL_URI, {"email": email});
  }

  Future<Response> verifyEmail(String email, String token) async {
    return await apiClient.postData(AppConstants.VERIFY_EMAIL_URI, {"email": email, "token": token});
  }

  Future<Response> updateZone() async {
    return await apiClient.getData(AppConstants.UPDATE_ZONE_URL);
  }

  Future<Response> verifyPhone(String email, String phone, String otp) async {
    return await apiClient.postData(AppConstants.VERIFY_PHONE_URI, {"phone": phone,"email": email, "otp": otp});
  }

  // for  user token
  Future<bool> saveUserToken(String token) async {
    apiClient.token = token;
    apiClient.updateHeader(token, null, sharedPreferences.getString(AppConstants.LANGUAGE_CODE));
    return await sharedPreferences.setString(AppConstants.TOKEN, token);
  }

  String getUserToken() {
    return sharedPreferences.getString(AppConstants.TOKEN) ?? "";
  }

  bool isLoggedIn() {
    return sharedPreferences.containsKey(AppConstants.TOKEN);
  }

  bool clearSharedData() {
    if(!GetPlatform.isWeb) {
      FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.TOPIC);
      apiClient.postData(AppConstants.TOKEN_URI, {"_method": "put", "cm_firebase_token": '@'});
    }
    sharedPreferences.remove(AppConstants.TOKEN);
    sharedPreferences.setStringList(AppConstants.CART_LIST, []);
    sharedPreferences.remove(AppConstants.USER_ADDRESS);
    apiClient.token = null;
    apiClient.updateHeader(null, null, null);
    return true;
  }

  // for  Remember Email
  Future<void> saveUserNumberAndPassword(String number, String password, String countryCode) async {
    try {
      await sharedPreferences.setString(AppConstants.USER_PASSWORD, password);
      await sharedPreferences.setString(AppConstants.USER_NUMBER, number);
      await sharedPreferences.setString(AppConstants.USER_COUNTRY_CODE, countryCode);
    } catch (e) {
      throw e;
    }
  }

  String getUserNumber() {
    return sharedPreferences.getString(AppConstants.USER_NUMBER) ?? "";
  }

  String getUserCountryCode() {
    return sharedPreferences.getString(AppConstants.USER_COUNTRY_CODE) ?? "";
  }

  String getUserPassword() {
    return sharedPreferences.getString(AppConstants.USER_PASSWORD) ?? "";
  }

  bool isNotificationActive() {
    return sharedPreferences.getBool(AppConstants.NOTIFICATION) ?? true;
  }

  void setNotificationActive(bool isActive) {
    if(isActive) {
      updateToken();
    }else {
      if(!GetPlatform.isWeb) {
        FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.TOPIC);
        if(isLoggedIn()) {
          FirebaseMessaging.instance.unsubscribeFromTopic('zone_${Get.find<LocationController>().getUserAddress().zoneId}_customer');
        }
      }
    }
    sharedPreferences.setBool(AppConstants.NOTIFICATION, isActive);
  }

  Future<bool> clearUserNumberAndPassword() async {
    await sharedPreferences.remove(AppConstants.USER_PASSWORD);
    await sharedPreferences.remove(AppConstants.USER_COUNTRY_CODE);
    return await sharedPreferences.remove(AppConstants.USER_NUMBER);
  }

  bool clearSharedAddress(){
    sharedPreferences.remove(AppConstants.USER_ADDRESS);
    return true;
  }

  Future<Response> getZoneList() async {
    return await apiClient.getData(AppConstants.ZONE_LIST_URI);
  }

  Future<Response> registerRestaurant(RestaurantBody restaurant, XFile logo, XFile cover) async {
    return apiClient.postMultipartData(
      AppConstants.RESTAURANT_REGISTER_URI, restaurant.toJson(), [MultipartBody('logo', logo), MultipartBody('cover_photo', cover)],
    );
  }

  Future<Response> registerDeliveryMan(DeliveryManBody deliveryManBody, List<MultipartBody> multiParts) async {
    return apiClient.postMultipartData(AppConstants.DM_REGISTER_URI, deliveryManBody.toJson(), multiParts);
  }

}
