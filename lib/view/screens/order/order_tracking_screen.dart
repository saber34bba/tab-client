import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/data/model/body/notification_body.dart';
import 'package:efood_multivendor/data/model/response/address_model.dart';
import 'package:efood_multivendor/data/model/response/conversation_model.dart';
import 'package:efood_multivendor/data/model/response/order_model.dart';
import 'package:efood_multivendor/data/model/response/restaurant_model.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/screens/order/widget/track_details_view.dart';
import 'package:efood_multivendor/view/screens/order/widget/tracking_stepper_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderID;
  OrderTrackingScreen({@required this.orderID});

  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> with WidgetsBindingObserver {
  GoogleMapController _controller;
  bool _isLoading = true;
  Timer _timer;
  LatLng _lat_lng;
  final _mapMarkerSC = StreamController<List<Marker>>();
  Stream<List<Marker>> get mapMarkerStream => _mapMarkerSC.stream;
  StreamSink<List<Marker>> get _mapMarkerSink => _mapMarkerSC.sink;

  OrderModel _track;
  void _loadData() async {
    await Get.find<LocationController>().getCurrentLocation(true, notify: false, defaultLatLng: LatLng(
      double.parse(Get.find<LocationController>().getUserAddress().latitude),
      double.parse(Get.find<LocationController>().getUserAddress().longitude),
    ));
    Get.find<OrderController>().trackOrder(widget.orderID, null, true);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mapMarkerSink.add([]);
    _loadData();
    // Get.find<OrderController>().callTrackOrderApi(orderModel: Get.find<OrderController>().trackModel, orderId: widget.orderID.toString());
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Get.find<OrderController>().callTrackOrderApi(orderModel: Get.find<OrderController>().trackModel, orderId: widget.orderID.toString());
    }else if(state == AppLifecycleState.paused){
      Get.find<OrderController>().cancelTimer();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    Get.find<OrderController>().cancelTimer();
    WidgetsBinding.instance.removeObserver(this);
    _mapMarkerSC.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'order_tracking'.tr),
      body: GetBuilder<OrderController>(builder: (orderController) {
        if(orderController.trackModel != null && _track == null) {
          _track = orderController.trackModel;

          /*if(_controller != null && GetPlatform.isWeb) {
            if(_track.deliveryAddress != null) {
              _controller.showMarkerInfoWindow(MarkerId('destination'));
            }
            if(_track.restaurant != null) {
              _controller.showMarkerInfoWindow(MarkerId('restaurant'));
            }
            if(_track.deliveryMan != null) {
              _controller.showMarkerInfoWindow(MarkerId('delivery_boy'));
            }
          }*/
        }

        return _track != null ? Center(child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: Stack(children: [
          StreamBuilder<List<Marker>>(
            stream: mapMarkerStream,
            builder: (context, snapshot) {
              print("\n\n\n\n\n\n\nSTREAM GOOGLE ${(snapshot.data??[]).map((e) => e.infoWindow.title).toList()}\n\n\n\n\n\n\n");
              return GoogleMap(
                trafficEnabled: true,
                initialCameraPosition: CameraPosition(target: LatLng(
                  double.parse(_track.deliveryAddress.latitude), double.parse(_track.deliveryAddress.longitude),
                ), zoom: 16),
                minMaxZoomPreference: MinMaxZoomPreference(0, 16),
                zoomControlsEnabled: true,
                markers: Set<Marker>.of(snapshot.data ?? []),
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                  setMarker(
                    _track.restaurant,
                    _track.deliveryMan ?? DeliveryMan(location: ''),
                    _track.orderType == 'take_away' ? Get.find<LocationController>().position.latitude == 0 ? _track.deliveryAddress : AddressModel(
                      latitude: Get.find<LocationController>().position.latitude.toString(),
                      longitude: Get.find<LocationController>().position.longitude.toString(),
                      address: Get.find<LocationController>().address,
                    ) : _track.deliveryAddress,
                    _track.orderType == 'take_away',
                  );
                },
              );
            },
          ),

          _isLoading ? Center(child: CircularProgressIndicator()) : SizedBox(),

          Positioned(
            top: Dimensions.PADDING_SIZE_SMALL, left: Dimensions.PADDING_SIZE_SMALL, right: Dimensions.PADDING_SIZE_SMALL,
            child: TrackingStepperWidget(status: _track.orderStatus, takeAway: _track.orderType == 'take_away'),
          ),
          Positioned(
            bottom: Dimensions.PADDING_SIZE_SMALL, left: Dimensions.PADDING_SIZE_SMALL, right: Dimensions.PADDING_SIZE_SMALL,
            child: TrackDetailsView(track: _track, callback: () async {
              orderController.cancelTimer();
              await Get.toNamed(RouteHelper.getChatRoute(
                notificationBody: NotificationBody(deliverymanId: _track.deliveryMan.id, orderId: int.parse(widget.orderID)),
                user: User(id: _track.deliveryMan.id, fName: _track.deliveryMan.fName, lName: _track.deliveryMan.lName, image: _track.deliveryMan.image),
              ));
              orderController.callTrackOrderApi(orderModel: _track, orderId: _track.id.toString());
            }),
          ),

        ]))) : Center(child: CircularProgressIndicator());
      }),
    );
  }

  void setMarker(Restaurant restaurant, DeliveryMan deliveryMan, AddressModel addressModel, bool takeAway) async {
    print("SETMARKER $_isLoading $_controller");
    if(_isLoading == false || _controller == null) return;
    try {
      ImageConfiguration imageConfiguration =  ImageConfiguration(
        size:Size(29,43),
      );

      // Animate to coordinate
      LatLngBounds bounds;
      double _rotation = 0;
      if(_controller != null) {
        if (double.parse(addressModel.latitude) < double.parse(restaurant.latitude)) {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(addressModel.latitude), double.parse(addressModel.longitude)),
            northeast: LatLng(double.parse(restaurant.latitude), double.parse(restaurant.longitude)),
          );
          _rotation = 0;
        }else {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(restaurant.latitude), double.parse(restaurant.longitude)),
            northeast: LatLng(double.parse(addressModel.latitude), double.parse(addressModel.longitude)),
          );
          _rotation = 180;
        }
      }
      LatLng centerBounds = LatLng(
        (bounds.northeast.latitude + bounds.southwest.latitude)/2,
        (bounds.northeast.longitude + bounds.southwest.longitude)/2,
      );

      _controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: centerBounds, zoom: GetPlatform.isWeb ? 10 : 17)));
      if(!ResponsiveHelper.isWeb()) {
        zoomToFit(_controller, bounds, centerBounds, padding: 1.5);
      }

      // Marker
      Marker _addressMarker;
      Marker _restaurantMarker;
      Marker _deliveryManMarker;

      if(addressModel != null){
        _addressMarker = Marker(
          markerId: MarkerId('destination'),
          position: LatLng(double.parse(addressModel.latitude), double.parse(addressModel.longitude)),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: addressModel.address,
          ),
          icon: await BitmapDescriptor.fromAssetImage(
            imageConfiguration,
            takeAway ? Images.my_location_marker : Images.user_marker,
          ),
        );
      }
      if(restaurant != null ){
        _restaurantMarker = Marker(
          markerId: MarkerId('restaurant'),
          position: LatLng(double.parse(restaurant.latitude), double.parse(restaurant.longitude)),
          infoWindow: InfoWindow(
            title: 'restaurant'.tr,
            snippet: restaurant.address,
          ),
          icon: await BitmapDescriptor.fromAssetImage(
            imageConfiguration,
            Images.restaurant_marker,
          ),
        );
      }      
      if(deliveryMan != null){
        var icon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(
            size:Size(29,43),
          ),
          Images.delivery_man_marker,
        );
        _timer?.cancel();
        Future<Null> Function() timerFn;
        timerFn = () async {
            print("NEW LAT LNG _mapMarkerSC.isClosed? ${_mapMarkerSC.isClosed}");
          if(_mapMarkerSC.isClosed) return; // cancle timer if the stream is closed
          try {
            // recordLocation();
            var lat_lng = await Get.find<OrderController>().getDeliveryManLocation(widget.orderID)
              .catchError(()=>_lat_lng);

            print("NEW LAT LNG $lat_lng .. $_lat_lng");

            if(lat_lng != null && (_lat_lng == null || _lat_lng.latitude != lat_lng.latitude || _lat_lng.longitude != lat_lng.longitude)){
              _lat_lng  = LatLng(lat_lng.latitude,lat_lng.longitude);
              //refresh UI
              _mapMarkerSink.add([
                _restaurantMarker,
                _addressMarker,
                Marker(
                  markerId: MarkerId("delivery_boy ${DateTime.now()}"),
                  position: lat_lng,
                  infoWindow: InfoWindow(
                    title: 'delivery_man'.tr,
                    snippet: deliveryMan.location,
                  ),
                  rotation: _rotation,
                  icon: icon,
                ),
              ].where((element) => element != null).whereType<Marker>().toList());
            }
          } catch (e) {
            print("NEW LAT LNG Error $e");  
          }finally{
            _timer = Timer(Duration(seconds: 1), timerFn );
          }
        };
        _timer = Timer(Duration(seconds: 1), timerFn );
      }
      _mapMarkerSink.add([
        _restaurantMarker,
        _addressMarker,
        _deliveryManMarker,
      ].where((element) => element != null).whereType<Marker>().toList());
    }catch(e) {}
      _isLoading = false;
      try {
        if(mounted) setState(() {});
      } catch (e) {}
  }

  Future<void> zoomToFit(GoogleMapController controller, LatLngBounds bounds, LatLng centerBounds, {double padding = 0.5}) async {
    bool keepZoomingOut = true;

    while(keepZoomingOut) {
      final LatLngBounds screenBounds = await controller.getVisibleRegion();
      if(fits(bounds, screenBounds)){
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
        break;
      }
      else {
        // Zooming out by 0.1 zoom level per iteration
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }

  bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck;
  }

  Future<Uint8List> convertAssetToUnit8List(String imagePath, {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png)).buffer.asUint8List();
}
}
