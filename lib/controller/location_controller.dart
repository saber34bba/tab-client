import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/wishlist_controller.dart';
import 'package:efood_multivendor/data/api/api_checker.dart';
import 'package:efood_multivendor/data/model/response/address_model.dart';
import 'package:efood_multivendor/data/model/response/place_details_model.dart';
import 'package:efood_multivendor/data/model/response/prediction_model.dart';
import 'package:efood_multivendor/data/model/response/response_model.dart';
import 'package:efood_multivendor/data/model/response/zone_response_model.dart';
import 'package:efood_multivendor/data/repository/auth_repo.dart';
import 'package:efood_multivendor/data/repository/location_repo.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/view/base/confirmation_dialog.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';


final String _defaultImg = "assets/image/weather/day/113.png#0"; // 113
enum LocationAnimation {
  NONE,
  SNOW,
  BROUILLARD,
  RAIN,
  WIND,
  ORAGE,
}
class LocationController extends GetxController implements GetxService {
  final LocationRepo locationRepo;
  final SharedPreferences sharedPreferences;

  LocationController({@required this.sharedPreferences,@required this.locationRepo}){

    var value = jsonDecode(sharedPreferences.getString("weatherInfos") ?? "null");
    DateTime now = DateTime.now();
    String date = DateFormat('yyyy-MM-dd HH:00').format(now);
    String day = date.split(" ").first;
    if(value != null && value.containsKey(date)){
      _weatherInfos["day"] = day;
      _weatherInfos["response"] = value;
      _weatherInfos["icon"] =  _weatherInfos["response"][date]["condition"]['icon'].toString().replaceFirst(RegExp(r'//cdn.weatherapi.com/weather/64x64'), 'assets/image/weather')+"#"+_weatherInfos["response"][date]["precip_mm"].toString();
    }
  }
  Position _myPosition = Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1);
  Position _position = Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1);
  Position _pickPosition = Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1);
  bool _loading = false;
  String _address = '';
  Map<String, dynamic> _weatherInfos = {
    "TTL" : Timer(Duration.zero,(){}),
    "icon" : _defaultImg,
  };
  String _pickAddress = '';
  List<Marker> _markers = <Marker>[];
  List<AddressModel> _addressList;
  List<AddressModel> _allAddressList;
  int _addressTypeIndex = 0;
  List<String> _addressTypeList = ['home', 'office', 'others'];
  bool _isLoading = false;
  bool _inZone = false;
  int _zoneID = 0;
  bool _buttonDisabled = true;
  bool _changeAddress = true;
  GoogleMapController _mapController;
  List<PredictionModel> _predictionList = [];
  bool _updateAddAddressData = true;
  LocationAnimation _locationAnimation = LocationAnimation.NONE;
  Map<int, List<LocationAnimation>> _typesMap = {
    113 : [],
    116 : [],
    119 : [],
    122 : [],
    143 : [],
    176 : [LocationAnimation.RAIN,],
    179 : [LocationAnimation.SNOW,],
    182 : [LocationAnimation.SNOW,LocationAnimation.RAIN],
    185 : [LocationAnimation.RAIN],
    200 : [LocationAnimation.ORAGE],
    227 : [LocationAnimation.SNOW, LocationAnimation.WIND],
    230 : [LocationAnimation.SNOW, LocationAnimation.WIND],
    248 : [LocationAnimation.BROUILLARD],
    260 : [LocationAnimation.BROUILLARD],
    263 : [LocationAnimation.SNOW],
    266 : [LocationAnimation.SNOW],
    281 : [LocationAnimation.RAIN],
    284 : [LocationAnimation.RAIN],
    293 : [LocationAnimation.RAIN],
    296 : [LocationAnimation.RAIN],
    299 : [LocationAnimation.RAIN],
    302 : [LocationAnimation.RAIN],
    305 : [LocationAnimation.RAIN],
    308 : [LocationAnimation.RAIN],
    311 : [LocationAnimation.RAIN],
    314 : [LocationAnimation.RAIN],
    317 : [LocationAnimation.RAIN, LocationAnimation.SNOW],
    320 : [LocationAnimation.RAIN, LocationAnimation.SNOW],
    323 : [LocationAnimation.SNOW],
    326 : [LocationAnimation.SNOW],
    329 : [LocationAnimation.SNOW],
    332 : [LocationAnimation.SNOW],
    335 : [LocationAnimation.SNOW],
    338 : [LocationAnimation.SNOW],
    350 : [LocationAnimation.SNOW],
    353 : [LocationAnimation.RAIN],
    356 : [LocationAnimation.RAIN],
    359 : [LocationAnimation.RAIN],
    362 : [LocationAnimation.RAIN, LocationAnimation.SNOW],
    365 : [LocationAnimation.RAIN, LocationAnimation.SNOW],
    368 : [LocationAnimation.SNOW],
    371 : [LocationAnimation.SNOW],
    374 : [LocationAnimation.SNOW],
    377 : [LocationAnimation.SNOW],
    386 : [LocationAnimation.ORAGE],
    389 : [LocationAnimation.ORAGE],
    392 : [LocationAnimation.ORAGE, LocationAnimation.SNOW],
    395 : [LocationAnimation.ORAGE, LocationAnimation.SNOW],
  };

  List<PredictionModel> get predictionList => _predictionList;
  bool get isLoading => _isLoading;
  bool get loading => _loading;
  Position get position => _position;
  Position get pickPosition => _pickPosition;
  String get address => _address;
  String get pickAddress => _pickAddress;
  List<Marker> get markers => _markers;
  List<AddressModel> get addressList => _addressList;
  List<String> get addressTypeList => _addressTypeList;
  int get addressTypeIndex => _addressTypeIndex;
  bool get inZone => _inZone;
  int get zoneID => _zoneID;
  String get wheaterIcon => (Get.find<SplashController>().configModel != null && Get.find<SplashController>().configModel.weatherEnable ? _defaultImg : _weatherInfos["icon"] as String).split("#").first;
  double get precipitations => Get.find<SplashController>().configModel != null && Get.find<SplashController>().configModel.weatherEnable ? (double.tryParse((_weatherInfos["icon"] as String).split("#").last) ?? 0) : 0;
  bool get hasPrecipitation => precipitations > 0;
  List<LocationAnimation> get precipitationType =>
    _typesMap[(double.tryParse(_weatherInfos["icon"].toString().split("/").last.split(".").first) ?? 113).toInt()] ?? [];
  bool get buttonDisabled => _buttonDisabled;
  GoogleMapController get mapController => _mapController;

  Future<AddressModel> getCurrentLocation(bool fromAddress, {GoogleMapController mapController, LatLng defaultLatLng, bool notify = true}) async {
    _loading = true;
    if(notify) {
      update();
    }
    AddressModel _addressModel;
    try {
      Position newLocalData = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _myPosition = newLocalData;
    }catch(e) {
      _myPosition = Position(
        latitude: defaultLatLng != null ? defaultLatLng.latitude : double.parse(Get.find<SplashController>().configModel.defaultLocation.lat ?? '0'),
        longitude: defaultLatLng != null ? defaultLatLng.longitude : double.parse(Get.find<SplashController>().configModel.defaultLocation.lng ?? '0'),
        timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1,
      );
    }
    if(fromAddress) {
      _position = _myPosition;
    }else {
      _pickPosition = _myPosition;
    }
    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(_myPosition.latitude, _myPosition.longitude), zoom: 16),
      ));
    }

    String _weatherFromGeocode = await getWeatherFromGeocode();

    String _addressFromGeocode = await getAddressFromGeocode(LatLng(_myPosition.latitude, _myPosition.longitude));
    fromAddress ? _address = _addressFromGeocode : _pickAddress = _addressFromGeocode;
    ZoneResponseModel _responseModel = await getZone(_myPosition.latitude.toString(), _myPosition.longitude.toString(), true);
    _buttonDisabled = !_responseModel.isSuccess;
    _addressModel = AddressModel(
      latitude: _myPosition.latitude.toString(), longitude: _myPosition.longitude.toString(), addressType: 'others',
      zoneId: _responseModel.isSuccess ? _responseModel.zoneIds[0] : 0, zoneIds: _responseModel.zoneIds,
      address: _addressFromGeocode, zoneData: _responseModel.zoneData,
    );
    _loading = false;
    update();
    return _addressModel;
  }

  Future<ZoneResponseModel> getZone(String lat, String long, bool markerLoad, {bool updateInAddress = false}) async {
    if(markerLoad) {
      _loading = true;
    }else {
      _isLoading = true;
    }
    print('problem start');
    if(!updateInAddress){
      update();
    }
    ZoneResponseModel _responseModel;
    Response response = await locationRepo.getZone(lat, long);
    if(response.statusCode == 200) {
      _inZone = true;
      _zoneID = int.parse(jsonDecode(response.body['zone_id'])[0].toString());
      List<int> _zoneIds = [];
      jsonDecode(response.body['zone_id']).forEach((zoneId){
        _zoneIds.add(int.parse(zoneId.toString()));
      });
      List<ZoneData> _zoneData = [];
      response.body['zone_data'].forEach((zoneData) => _zoneData.add(ZoneData.fromJson(zoneData)));
      _responseModel = ZoneResponseModel(true, '' , _zoneIds, _zoneData);
      if(updateInAddress) {
        print('here problem');
        AddressModel _address = getUserAddress();
        _address.zoneData = _zoneData;
        saveUserAddress(_address);
      }
    }else {
      _inZone = false;
      _responseModel = ZoneResponseModel(false, response.statusText, [], []);
    }
    if(markerLoad) {
      _loading = false;
    }else {
      _isLoading = false;
    }
    update();
    return _responseModel;
  }

  void updatePosition(CameraPosition position, bool fromAddress) async {
    if(_updateAddAddressData) {
      _loading = true;
      update();
      try {
        if (fromAddress) {
          _position = Position(
            latitude: position.target.latitude, longitude: position.target.longitude, timestamp: DateTime.now(),
            heading: 1, accuracy: 1, altitude: 1, speedAccuracy: 1, speed: 1,
          );
        } else {
          _pickPosition = Position(
            latitude: position.target.latitude, longitude: position.target.longitude, timestamp: DateTime.now(),
            heading: 1, accuracy: 1, altitude: 1, speedAccuracy: 1, speed: 1,
          );
        }
        ZoneResponseModel _responseModel = await getZone(position.target.latitude.toString(), position.target.longitude.toString(), true);
        _buttonDisabled = !_responseModel.isSuccess;
        if (_changeAddress) {
          String _addressFromGeocode = await getAddressFromGeocode(LatLng(position.target.latitude, position.target.longitude));
          fromAddress ? _address = _addressFromGeocode : _pickAddress = _addressFromGeocode;
        } else {
          _changeAddress = true;
        }
      } catch (e) {}
      _loading = false;
      update();
    }else {
      _updateAddAddressData = true;
    }
  }

  Future<ResponseModel> deleteUserAddressByID(int id, int index) async {
    Response response = await locationRepo.removeAddressByID(id);
    ResponseModel _responseModel;
    if (response.statusCode == 200) {
      _addressList.removeAt(index);
      _responseModel = ResponseModel(true, response.body['message']);
    } else {
      _responseModel = ResponseModel(false, response.statusText);
    }
    update();
    return _responseModel;
  }

  Future<void> getAddressList() async {
    Response response = await locationRepo.getAllAddress();
    if (response.statusCode == 200) {
      _addressList = [];
      _allAddressList = [];
      response.body['addresses'].forEach((address) {
        _addressList.add(AddressModel.fromJson(address));
        _allAddressList.add(AddressModel.fromJson(address));
      });
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void filterAddresses(String queryText) {
    if(_addressList != null) {
      _addressList = [];
      if (queryText == null || queryText.isEmpty) {
        _addressList.addAll(_allAddressList);
      } else {
        _allAddressList.forEach((address) {
          if (address.address.toLowerCase().contains(queryText.toLowerCase())) {
            _addressList.add(address);
          }
        });
      }
      update();
    }
  }

  Future<ResponseModel> addAddress(AddressModel addressModel, bool fromCheckout, int restaurantZoneId) async {
    _isLoading = true;
    update();
    Response response = await locationRepo.addAddress(addressModel);
    _isLoading = false;
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      if(fromCheckout && !response.body['zone_ids'].contains(restaurantZoneId)) {
        responseModel = ResponseModel(false, 'your_selected_location_is_from_different_zone'.tr);
      }else {
        getAddressList();
        Get.find<OrderController>().setAddressIndex(0);
        String message = response.body["message"];
        responseModel = ResponseModel(true, message);
      }
    } else {
      responseModel = ResponseModel(false, response.statusText == 'Out of coverage!' ? 'service_not_available_in_this_area'.tr : response.statusText);
    }
    update();
    return responseModel;
  }

  Future<ResponseModel> updateAddress(AddressModel addressModel, int addressId) async {
    _isLoading = true;
    update();
    Response response = await locationRepo.updateAddress(addressModel, addressId);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      getAddressList();
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<bool> saveUserAddress(AddressModel address) async {
    String userAddress = jsonEncode(address.toJson());
    return await locationRepo.saveUserAddress(userAddress, address.zoneIds);
  }

  AddressModel getUserAddress() {
    AddressModel _addressModel;
    try {
      _addressModel = AddressModel.fromJson(jsonDecode(locationRepo.getUserAddress()));
    }catch(e) {}
    return _addressModel;
  }

  void setAddressTypeIndex(int index) {
    _addressTypeIndex = index;
    update();
  }

  void saveAddressAndNavigate(AddressModel address, bool fromSignUp, String route, bool canRoute) {
    if(Get.find<CartController>().cartList.length > 0) {
      Get.dialog(ConfirmationDialog(
        icon: Images.warning, title: 'are_you_sure_to_reset'.tr, description: 'if_you_change_location'.tr,
        onYesPressed: () {
          Get.back();
          _setZoneData(address, fromSignUp, route, canRoute);
        },
        onNoPressed: () {
          Get.back();
          Get.back();
        },
      ));
    }else {
      _setZoneData(address, fromSignUp, route, canRoute);
    }
  }

  void _setZoneData(AddressModel address, bool fromSignUp, String route, bool canRoute) {
    Get.find<LocationController>().getZone(address.latitude, address.longitude, false).then((response) async {
      if (response.isSuccess) {
        Get.find<CartController>().clearCartList();
        address.zoneId = response.zoneIds[0];
        address.zoneIds = [];
        address.zoneIds.addAll(response.zoneIds);
        address.zoneData = [];
        address.zoneData.addAll(response.zoneData);
        autoNavigate(address, fromSignUp, route, canRoute);
      } else {
        Get.back();
        showCustomSnackBar(response.message);
      }
    });
  }

  void autoNavigate(AddressModel address, bool fromSignUp, String route, bool canRoute) async {
    // if(!GetPlatform.isWeb) {
      if (Get.find<LocationController>().getUserAddress() != null && Get.find<LocationController>().getUserAddress().zoneId != address.zoneId) {
        Get.find<AuthRepo>().updateToken(
          topic: 'zone_${address.zoneId}_customer', 
          oldTopic: 'zone_${Get.find<LocationController>().getUserAddress().zoneId}_customer'
        );
        // FirebaseMessaging.instance.subscribeToTopic('zone_${address.zoneId}_customer');
      } else {
        Get.put(AuthRepo()).updateToken(topic: 'zone_${address.zoneId}_customer');
        //Get.find<AuthRepo>().updateToken(topic: 'zone_${address.zoneId}_customer');
        // FirebaseMessaging.instance.subscribeToTopic('zone_${address.zoneId}_customer');
      }
    // }
    await Get.find<LocationController>().saveUserAddress(address);
    if(Get.find<AuthController>().isLoggedIn()) {
      await Get.find<WishListController>().getWishList();
      Get.find<AuthController>().updateZone();
    }
    HomeScreen.loadData(true);
    Get.find<OrderController>().clearPrevData();
    if(fromSignUp) {
      Get.offAllNamed(RouteHelper.getInterestRoute());
    }else {
      if(route != null && canRoute) {
        Get.offAllNamed(route);
      }else {
        Get.offAllNamed(RouteHelper.getInitialRoute());
      }
    }
  }

  Future<Position> setLocation(String placeID, String address, GoogleMapController mapController) async {
    _loading = true;
    update();

    LatLng _latLng = LatLng(0, 0);
    Response response = await locationRepo.getPlaceDetails(placeID);
    if(response.statusCode == 200) {
      PlaceDetailsModel _placeDetails = PlaceDetailsModel.fromJson(response.body);
      if(_placeDetails.status == 'OK') {
        _latLng = LatLng(_placeDetails.result.geometry.location.lat, _placeDetails.result.geometry.location.lng);
      }
    }

    _pickPosition = Position(
      latitude: _latLng.latitude, longitude: _latLng.longitude,
      timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1,
    );

    _pickAddress = address;
    _changeAddress = false;

    if(mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _latLng, zoom: 16)));
    }
    _loading = false;
    update();
    return _pickPosition;
  }

  void disableButton() {
    _buttonDisabled = true;
    _inZone = true;
    update();
  }

  void setAddAddressData() {
    _position = _pickPosition;
    _address = _pickAddress;
    _updateAddAddressData = false;
    update();
  }

  void setUpdateAddress(AddressModel address){
    _position = Position(
      latitude: double.parse(address.latitude), longitude: double.parse(address.longitude), timestamp: DateTime.now(),
      altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, floor: 1, accuracy: 1,
    );
    _address = address.address;
    _addressTypeIndex = _addressTypeList.indexOf(address.addressType);
  }

  void setPickData() {
    _pickPosition = _position;
    _pickAddress = _address;
  }

  void setMapController(GoogleMapController mapController) {
    _mapController = mapController;
  }

  Future<String> getAddressFromGeocode(LatLng latLng) async {
    (_weatherInfos["TTL"] as Timer).cancel();
    Response response = await locationRepo.getAddressFromGeocode(latLng);
    String _address = 'Unknown Location Found';
    if(response.statusCode == 200 && response.body['status'] == 'OK') {
      _address = response.body['results'][0]['formatted_address'].toString();
    }else {
      showCustomSnackBar(response.body['error_message'] ?? response.bodyString);
    }
    return _address;
  }
    Future<String> getWeatherFromGeocode([LatLng latLng]) async {
      if(Get.find<SplashController>().configModel != null && Get.find<SplashController>().configModel.weatherEnable == false){
        _weatherInfos["icon"] = _defaultImg;
        return _defaultImg;
      }
    if(latLng == null){
      latLng = LatLng(_myPosition.latitude, _myPosition.longitude);
    }
    DateTime now = DateTime.now();
    String date = DateFormat('yyyy-MM-dd HH:00').format(now);
    String day = date.split(" ").first;
    if(
     !_weatherInfos.containsKey("response") || 
     ( _weatherInfos.containsKey("response") && 
      _weatherInfos.containsKey("day") &&  
      _weatherInfos["day"] is String && 
      day != _weatherInfos["day"] )
    ){
      _weatherInfos.remove("response");
      Response<Map<String, dynamic>> response =  await locationRepo.getWeatherFromGeocode<Map<String, dynamic>>(latLng);
      if(response.statusCode == 200) {
        _weatherInfos["day"] = day;
        _weatherInfos["response"] = response.body;
        sharedPreferences.setString("weatherInfos",jsonEncode(_weatherInfos["response"]));
      }
    }
    if(_weatherInfos.containsKey("response")) {
      _weatherInfos["icon"] =  _weatherInfos["response"][date]["condition"]['icon'].toString().replaceFirst(RegExp(r'//cdn.weatherapi.com/weather/64x64'), 'assets/image/weather')+"#"+_weatherInfos["response"][date]["precip_mm"].toString();
    }

    // check next hour
    _weatherInfos["TTL"] = Timer(Duration(minutes: _weatherInfos.containsKey("response") ? (60 - now.minute) : 1), (){
      String _oldWeather = _weatherInfos["icon"];
      getWeatherFromGeocode(latLng);
      if(_oldWeather != _weatherInfos["icon"]){
        update();
      }
    });
    return _weatherInfos["icon"];
  }

  Future<List<PredictionModel>> searchLocation(BuildContext context, String text) async {
    if(text != null && text.isNotEmpty) {
      Response response = await locationRepo.searchLocation(text);
      if (response.statusCode == 200 && response.body['status'] == 'OK') {
        _predictionList = [];
        response.body['predictions'].forEach((prediction) => _predictionList.add(PredictionModel.fromJson(prediction)));
      } else {
        showCustomSnackBar(response.body['error_message'] ?? response.bodyString);
      }
    }
    return _predictionList;
  }

  void setPlaceMark(String address) {
    _address = address;
  }

  Future<void> zoomToFit(GoogleMapController controller, List<LatLng> list, {double padding = 0.5}) async {
    LatLngBounds _bounds = _computeBounds(list);
    LatLng _centerBounds = LatLng(
      (_bounds.northeast.latitude + _bounds.southwest.latitude)/2,
      (_bounds.northeast.longitude + _bounds.southwest.longitude)/2,
    );

    if(controller != null) {
      controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _centerBounds, zoom: GetPlatform.isWeb ? 10 : 16)));
    }

    bool keepZoomingOut = true;

    int _count = 0;
    while(keepZoomingOut) {
      _count++;
      final LatLngBounds screenBounds = await controller.getVisibleRegion();
      if(_fits(_bounds, screenBounds) || _count == 200) {
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: _centerBounds,
          zoom: zoomLevel,
        )));
        break;
      }
      else {
        // Zooming out by 0.1 zoom level per iteration
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: _centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }

  bool _fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck;
  }

  LatLngBounds _computeBounds(List<LatLng> list) {
    assert(list.isNotEmpty);
    var firstLatLng = list.first;
    var s = firstLatLng.latitude,
        n = firstLatLng.latitude,
        w = firstLatLng.longitude,
        e = firstLatLng.longitude;
    for (var i = 1; i < list.length; i++) {
      var latlng = list[i];
      s = min(s, latlng.latitude);
      n = max(n, latlng.latitude);
      w = min(w, latlng.longitude);
      e = max(e, latlng.longitude);
    }
    return LatLngBounds(southwest: LatLng(s, w), northeast: LatLng(n, e));
  }

}
