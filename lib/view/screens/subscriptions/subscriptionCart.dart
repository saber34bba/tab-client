import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/api/api_client.dart';
import 'package:efood_multivendor/data/model/response/address_model.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/my_text_field.dart';
import 'package:efood_multivendor/view/screens/address/widget/address_widget.dart';
import 'package:efood_multivendor/view/screens/cart/widget/delivery_option_button.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/address_dialogue.dart';
import 'package:efood_multivendor/view/screens/subscriptions/SubscriptionModelView.dart';
import 'package:efood_multivendor/view/screens/subscriptions/subscriptionPresenter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';

class SubscriptionCart extends StatefulWidget {
  bool showSecondPage;
  SubscriptionCart({@required this.showSecondPage});
  @override
  State<StatefulWidget> createState() {
    return _SubscriptionCart();
  }
}

class _SubscriptionCart extends State<SubscriptionCart> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<RestaurantController>().initCheckoutData(
          Provider.of<SubscriptionsModelView>(context, listen: false)
              .subscriptionModel
              .restaurantid);

      Get.find<OrderController>()
          .updateDateSlot(AppConstants.preferenceDays.indexOf("1"));

      Provider.of<SubscriptionPresenter>(context, listen: false)
          .clearData(context);

      _addressList.add(Get.find<LocationController>().getUserAddress());
    });
    super.initState();
  }

  SubscriptionPresenter subscriptionPresenter;
  SubscriptionsModelView subscriptionsModelView;
  double width, height;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    subscriptionPresenter = Provider.of<SubscriptionPresenter>(context);

    subscriptionsModelView = Provider.of<SubscriptionsModelView>(context);
    return Scaffold(
      appBar: CustomAppBar(title: 'subscriptions'.tr),
      body: Container(
          height: height,
          width: width,
          child: widget.showSecondPage
              ? _subscription_options()
              : items() 
          ),
    );
  }

  Widget items() {
    return 
    Container(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
    SingleChildScrollView(
        child: Container(
          height: height,
          
          padding: EdgeInsets.only(left: 16, right: 16),
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 20,
            ),
            Container(
              height: height,
              width: width,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.all(
                          Radius.circular(Dimensions.RADIUS_SMALL)),
                      child: CustomImage(
                        image: subscriptionsModelView.subscriptionModel.image,
                        height: 
                        ResponsiveHelper.isDesktop(context)?
                        context.width * 0.1:context.width * 0.3,
                        width:  ResponsiveHelper.isDesktop(context)?
                        context.width * 0.1:context.width * 0.3,
                        fit: BoxFit.cover,
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                         Get.find<ApiClient>().getHeader()["X-localization"]=="ar"?
                        subscriptionsModelView.subscriptionModel.name_ar:
                           Get.find<ApiClient>().getHeader()["X-localization"]=="en"?
                        subscriptionsModelView.subscriptionModel.name_en:
                         subscriptionsModelView.subscriptionModel.name_fr,
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge),
                      ),
                      SizedBox(height: 5),
                      Container(
                          width: width * 0.5,
                          child: Row(
                            children: [
                              Text(
                                "prix".tr,
                                overflow: TextOverflow.clip,
                                style: robotoMedium.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: Dimensions.fontSizeLarge),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                subscriptionsModelView.subscriptionModel.prix,
                                overflow: TextOverflow.clip,
                                style: robotoMedium.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: Dimensions.fontSizeLarge),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                Get.find<SplashController>()
                                    .configModel
                                    .currencySymbol,
                                overflow: TextOverflow.clip,
                                style: robotoMedium.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: Dimensions.fontSizeLarge),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 5,
                      ),
                      subscriptionsModelView.subscriptionModel.sizeList.isNotEmpty
                          ? Text(
                              subscriptionsModelView
                                      .subscriptionModel
                                      .sizeList[subscriptionPresenter.size_index]
                                      .price
                                      .toString() +
                                  " Dh ",
                              style: robotoMedium.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: Dimensions.fontSizeLarge),
                            )
                          : Container(),
                      SizedBox(
                        height: 5,
                      ),
                      
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('description'.tr, style: robotoMedium),
                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                Text(
                    Get.find<ApiClient>().getHeader()["X-localization"]=="ar"?
                                          subscriptionsModelView
                        .subscriptionlist[subscriptionsModelView.index].des_ar.length>100?
                                      subscriptionsModelView
                        .subscriptionlist[subscriptionsModelView.index].des_ar.substring(0,100)+"...":
                                        subscriptionsModelView
                        .subscriptionlist[subscriptionsModelView.index].des_ar: 
                                           Get.find<ApiClient>().getHeader()["X-localization"]=="en"?
                                         subscriptionsModelView
                        .subscriptionlist[subscriptionsModelView.index].des_en.length>100?
                                        subscriptionsModelView
                        .subscriptionlist[subscriptionsModelView.index].des_en.substring(0,100)+"...":
                                      subscriptionsModelView
                        .subscriptionlist[subscriptionsModelView.index].des_en:
                                          subscriptionsModelView
                        .subscriptionlist[subscriptionsModelView.index].des_fr.length>100?
                                       subscriptionsModelView
                        .subscriptionlist[subscriptionsModelView.index].des_fr.substring(0,100)+"...":
                                     subscriptionsModelView
                        .subscriptionlist[subscriptionsModelView.index].des_fr
                   ,
                    style: 
                    ResponsiveHelper.isDesktop(context)?
                    robotoRegular.copyWith(fontSize: 14):
                    robotoRegular),
                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Text('food'.tr, style: robotoMedium),
                  Container(
                          width: width*0.5,
                          child: Row(children: [
                            Text(
                          "quantity".tr,
                          overflow: TextOverflow.clip,
                          style: robotoMedium.copyWith(
                          color: Colors.grey,
                          fontSize: Dimensions.fontSizeSmall),
                          ),
                            SizedBox(width: 5,),
                            Text(
                         subscriptionsModelView. subscriptionModel.total_quantity.toString(),
                          overflow: TextOverflow.clip,
                          style: robotoMedium.copyWith(
                          color: Colors.grey,
                          fontSize: Dimensions.fontSizeSmall),
                          ),
                          SizedBox(width: 2,),
                             Text(
                           "dishes".tr,
                          overflow: TextOverflow.clip,
                          style: robotoMedium.copyWith(
                          color: Colors.grey,
                          fontSize: Dimensions.fontSizeSmall),
                          ),
                          ],)
                          ),
                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                foodListWidget(),
                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              height: 1,
              color: Colors.grey[100],
              width: width,
            ),
            SizedBox(
              height: 16,
            ),
           // Expanded(child: Container()),
          
            SizedBox(
              height: 100,
            )
          ]),
        ),
      ),
          
                Positioned(
                  bottom: 10,
                  left: 0,
                  right:0,
                  child: 
               !subscriptionsModelView.isloading? CustomButton(
                    width: ResponsiveHelper.isDesktop(context)
                        ? MediaQuery.of(context).size.width / 2.0
                        : null,
                    buttonText: 'buy this subscription'.tr,
                    onPressed: () {
                      Provider.of<SubscriptionsModelView>(context, listen: false)
                          .buySubcription(context);
                    },
                  )
                : Center(child: CircularProgressIndicator())),
      ],),
    );
    
  }


Widget foodListWidget(){
  return               GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 4,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1,
                ),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: subscriptionsModelView
                    .subscriptionlist[subscriptionsModelView.index]
                    .productListModel
                    .length,
                itemBuilder: (context, i) {
                  return InkWell(
                    onTap: () {
                      
                    },
                    child: Container(
                        alignment: Alignment.center,
                      
                        decoration: BoxDecoration(
                          color: subscriptionPresenter.productList.contains(
                                  subscriptionsModelView
                                      .subscriptionlist[
                                          subscriptionsModelView.index]
                                      .productListModel[i]
                                      .id)
                              ? Theme.of(context).backgroundColor
                              : Colors.white,//Theme.of(context).disabledColor,
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          border: subscriptionPresenter.productList.contains(
                                  subscriptionsModelView
                                      .subscriptionlist[
                                          subscriptionsModelView.index]
                                      .productListModel[i]
                                      .id)
                              ? Border.all(
                                  color: Theme.of(context).disabledColor,
                                  width: 2)
                              : null,
                        ),
                        child: Column(
                          
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: subscriptionsModelView
                                      .subscriptionlist[
                                          subscriptionsModelView.index]
                                      .productListModel[i]
                                      .image ==
                                  null
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            subscriptionsModelView
                                        .subscriptionlist[
                                            subscriptionsModelView.index]
                                        .productListModel[i]
                                        .image !=
                                    null
                                ? ClipRRect(
                                   borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                                  child: Image.network(
                                      '${Get.find<SplashController>().configModel.baseUrls.productImageUrl}/${subscriptionsModelView.subscriptionlist[subscriptionsModelView.index].productListModel[i].image}',
                                    height:80,
                                    width:double.infinity,                                   
                                      fit: BoxFit.cover),
                                )
                                : Container(),
                            subscriptionsModelView
                                        .subscriptionlist[
                                            subscriptionsModelView.index]
                                        .productListModel[i]
                                        .image ==
                                    null
                                ? Container()
                                : Container(
                                    width: 10,
                                  ),
                            Container(
                                padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                   width: double.infinity,
                                    child: Text(
                                      subscriptionsModelView
                                          .subscriptionlist[
                                              subscriptionsModelView.index]
                                          .productListModel[i]
                                          .name,
                                      
                                      overflow:
                                       TextOverflow.clip
                                      ,
                                      style: robotoRegular.copyWith(
                                        color: subscriptionPresenter.productList
                                                .contains(subscriptionsModelView
                                                    .subscriptionlist[
                                                        subscriptionsModelView.index]
                                                    .productListModel[i]
                                                    .id)
                                            ? Colors.black
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    "quantity".tr +
                                        ": " +
                                        subscriptionsModelView
                                            .subscriptionlist[
                                                subscriptionsModelView.index]
                                            .productListModel[i]
                                            .quantity
                                            .toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: robotoRegular.copyWith(
                                      color: Colors.black.withOpacity(0.3),
                                      fontSize: 14
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            )
                          ],
                        )),
                  );
                },
              );
}
  List<AddressModel> _addressList = [];

  double _taxPercent = 0;
  Widget _subscription_options() {
    return GetBuilder<RestaurantController>(builder: (restController) {
      if (restController.restaurant != null) {

        bool _todayClosed = false;
        bool _tomorrowClosed = false;
        _todayClosed = restController.isRestaurantClosed(
            true,
            restController.restaurant.active,
            restController.restaurant.schedules);
        _tomorrowClosed = restController.isRestaurantClosed(
            false,
            restController.restaurant.active,
            restController.restaurant.schedules);
        _taxPercent = restController.restaurant.tax;
      }

      return GetBuilder<OrderController>(builder: (orderController) {
        double _deliveryCharge = -1;
        double _charge = -1;
        if (restController.restaurant != null &&
            orderController.distance != null &&
            orderController.distance != -1) {
          double _zoneCharge = Get.find<LocationController>()
              .getUserAddress()
              .zoneData
              .firstWhere((data) => data.id == restController.restaurant.zoneId)
              .perKmShippingCharge;
          double _perKmCharge =
              restController.restaurant.selfDeliverySystem == 1
                  ? restController.restaurant.perKmShippingCharge
                  : (_zoneCharge != null
                      ? _zoneCharge
                      : Get.find<SplashController>()
                          .configModel
                          .perKmShippingCharge);
          double _minimumCharge =
              restController.restaurant.selfDeliverySystem == 1
                  ? restController.restaurant.minimumShippingCharge
                  : (_zoneCharge != null
                      ? Get.find<LocationController>()
                          .getUserAddress()
                          .zoneData
                          .firstWhere((data) =>
                              data.id == restController.restaurant.zoneId)
                          .minimumShippingCharge
                      : Get.find<SplashController>()
                          .configModel
                          .minimumShippingCharge);
          _deliveryCharge = orderController.distance * _perKmCharge;
          _charge = orderController.distance * _perKmCharge;
          if (_deliveryCharge < _minimumCharge) {
            _deliveryCharge = _minimumCharge;
            _charge = _minimumCharge;
          }
        }
        return (Stack(fit: StackFit.expand, children: [
          Container(
            height: height,
            width: width,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.max, children: [
                Container(
                  width: context.width,
                  color: Theme.of(context).cardColor,
                  padding: EdgeInsets.symmetric(
                      vertical: Dimensions.PADDING_SIZE_SMALL,
                      horizontal: Dimensions.PADDING_SIZE_SMALL),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                                vertical: Dimensions.PADDING_SIZE_SMALL),
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.05),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.RADIUS_LARGE)),
                           
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Text(
                              'prix'.tr,
                              style: robotoMedium.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: Dimensions.fontSizeLarge),
                            ),
                            SizedBox(width:5),
                                Text(
                                  subscriptionsModelView
                                      .subscriptionModel.prix,
                                  overflow: TextOverflow.clip,
                                  style: robotoMedium.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: Dimensions.fontSizeLarge),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  Get.find<SplashController>()
                                      .configModel
                                      .currencySymbol,
                                  overflow: TextOverflow.clip,
                                  style: robotoMedium.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: Dimensions.fontSizeLarge),
                                ),
                              ],
                            )),
                        SizedBox(height: 10),
                        Text('delivery_type'.tr, style: robotoMedium),
                        SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(children: [
                              DeliveryOptionButton(
                                value: 'delivery',
                                title: 'home_delivery'.tr,
                                charge: 10,
                                isFree: false,
                                image: Images.home_delivery,
                                index: 0,
                              ),
                              SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),
                            ])),
                        restController.restaurant != null
                            ? Center(
                                child: Text('delivery_charge'.tr +
                                    ': ' +
                                    '${(orderController.orderType == 'take_away' || (orderController.deliverySelectIndex == 0 ? restController.restaurant.freeDelivery : true)) ? 'free'.tr : _charge != -1 ? PriceConverter.convertPrice(orderController.deliverySelectIndex == 0 ? _charge : _deliveryCharge) : 'calculating'.tr}'),
                              )
                            : Container(),
                        SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                        

                        Container(
                          color: Theme.of(context).cardColor,
                          padding: EdgeInsets.symmetric(
                              vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                              horizontal: Dimensions.PADDING_SIZE_SMALL),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('deliver_to'.tr,
                                          style: robotoMedium),
                                      InkWell(
                                        onTap: () async {},
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(children: [
                                            Text('add_new'.tr,
                                                style: robotoMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color: Theme.of(context)
                                                        .primaryColor)),
                                            SizedBox(
                                                width: Dimensions
                                                    .PADDING_SIZE_EXTRA_SMALL),
                                            Icon(Icons.add,
                                                size: 20,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ]),
                                        ),
                                      ),
                                    ]),
                                InkWell(
                                  onTap: () {
                                    Get.dialog(
                                      AddressDialogue(
                                          addressList: _addressList,
                                          streetNumberController:
                                              subscriptionPresenter
                                                  .streetNumberController,
                                          houseController: subscriptionPresenter
                                              .houseController,
                                          floorController: subscriptionPresenter
                                              .floorController),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      _addressList.isEmpty
                                          ? Container()
                                          : Expanded(
                                              child: AddressWidget(
                                                  address: _addressList[
                                                      orderController
                                                          .addressIndex],
                                                  fromAddress: false,
                                                  fromCheckout: true)),
                                      Icon(Icons.arrow_drop_down_sharp)
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    height: Dimensions.PADDING_SIZE_DEFAULT),
                                Text(
                                  'street_number'.tr,
                                  style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall),
                                ),
                                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                                MyTextField(
                                  hintText: 'ex_24th_street'.tr,
                                  inputType: TextInputType.streetAddress,
                                  focusNode: subscriptionPresenter.streetNode,
                                  nextFocus: subscriptionPresenter.houseNode,
                                  controller: subscriptionPresenter
                                      .streetNumberController,
                                  showBorder: true,
                                ),
                                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                                Text(
                                  'house'.tr +
                                      ' / ' +
                                      'floor'.tr +
                                      ' ' +
                                      'number'.tr,
                                  style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall),
                                ),
                                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                                Row(
                                  children: [
                                    Expanded(
                                      child: MyTextField(
                                        hintText: 'ex_34'.tr,
                                        inputType: TextInputType.text,
                                        focusNode:
                                            subscriptionPresenter.houseNode,
                                        nextFocus:
                                            subscriptionPresenter.floorNode,
                                        controller: subscriptionPresenter
                                            .houseController,
                                        showBorder: true,
                                      ),
                                    ),
                                    SizedBox(
                                        width: Dimensions.PADDING_SIZE_SMALL),
                                    Expanded(
                                      child: MyTextField(
                                        hintText: 'ex_3a'.tr,
                                        inputType: TextInputType.text,
                                        focusNode:
                                            subscriptionPresenter.floorNode,
                                        inputAction: TextInputAction.done,
                                        controller: subscriptionPresenter
                                            .floorController,
                                        showBorder: true,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                              ]),
                        )
                      ]),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                // Time Slot
                /*
                              restController.restaurant.scheduleOrder ?*/
                Container(
                  color: Theme.of(context).cardColor,
                  padding: EdgeInsets.symmetric(
                      vertical: Dimensions.PADDING_SIZE_SMALL,
                      horizontal: Dimensions.PADDING_SIZE_SMALL),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Text('delivery_time'.tr, style: robotoMedium),
                              Expanded(child: Container()),
                              IconButton(
                                  highlightColor: Colors.yellow,
                                  hoverColor: Colors.grey,
                                  onPressed: () {
                                    Provider.of<SubscriptionPresenter>(context,
                                            listen: false)
                                        .addSchedule(context);
                                    
                                  },
                                  icon: Icon(Icons.add))
                            ],
                          ),
                        ),
                        Text(
                          'date & hours'.tr + ' / ' + 'quantity'.tr,
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall),
                        ),
                        SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                        for (int j = 0;
                            j <
                                subscriptionPresenter
                                    .subscriptionSchedule.length;
                            j++)
                          subscriptionScheduleWidget(
                              j, restController, orderController),
                        SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                      ]),
                ),
                SizedBox(
                  height: 100,
                )
                //  Expanded(child: Container())
              ]),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 100,
              color: Colors.white,
              padding: EdgeInsets.only(left: 16, right: 16),
              child: subscriptionsModelView.isloading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : CustomButton(
                      width: ResponsiveHelper.isDesktop(context)
                          ? MediaQuery.of(context).size.width / 2.0
                          : null,

                      buttonText: 'order_now'.tr, //'order_now'.tr,
                      onPressed: () {
                        AddressModel _address =
                            _addressList[orderController.addressIndex];
                        Provider.of<SubscriptionsModelView>(context,
                                listen: false)
                            .postdata(context, false, _address);
                      },
                    ),
            ),
          )
        ]));
      });
    });
  }

  Widget timeWidget() {
    return Text("");
  }

  Widget subscriptionScheduleWidget(int j, RestaurantController restController,
      OrderController orderController) {
    return Container(
        padding: EdgeInsets.only(bottom: 10),
        width: width,
        child: Column(
          children: [
            Row(mainAxisSize: MainAxisSize.max, children: [
              Expanded(
                child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.PADDING_SIZE_SMALL),
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius:
                            BorderRadius.circular(Dimensions.RADIUS_SMALL),
                        border:
                            Border.all(color: Theme.of(context).disabledColor)),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_sharp,
                          color: Theme.of(context).disabledColor,
                          size: 16,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Material(
                          color: Colors.transparent,
                          child: Ink(
                            padding: EdgeInsets.only(
                                left: 10, right: 10, bottom: 10, top: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: InkWell(
                              onTap: () {
                                Provider.of<SubscriptionPresenter>(context,
                                        listen: false)
                                    .selectDate(j, context);
                              },
                              child: Text(
                                (subscriptionPresenter.formatDate(
                                    subscriptionPresenter
                                        .subscriptionSchedule[j].selectedDate)),
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
              SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
              orderController.slotIndexList==null
              || orderController.slotIndexList.isEmpty
              ||  orderController.slotIndexList.length==0
              
                  ? Container()
                  : Container(
                      width: 100,
                      padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.PADDING_SIZE_SMALL),
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          border: Border.all(
                              color: Theme.of(context).disabledColor)),
                      child: DropdownButton<int>(
                        hint: Text("time"),
                        value: subscriptionPresenter
                                .subscriptionSchedule[j].timeList.isEmpty
                            ? null
                            : subscriptionPresenter
                                .subscriptionSchedule[j].timeList.first,
                        //orderController.selectedTimeSlot,
                        items: orderController.slotIndexList.map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text((value == 0 &&
                                    orderController.selectedDateSlot == 0 &&
                                    restController.isRestaurantOpenNow(
                                        restController.restaurant.active,
                                        restController.restaurant.schedules))
                                ? 'now'.tr
                                : '${DateConverter.dateToTimeOnly(orderController.timeSlots[value].startTime)} '
                                    '- ${DateConverter.dateToTimeOnly(orderController.timeSlots[value].endTime)}'),
                          );
                        }).toList(),
                        onChanged: (int value) {
                          Provider.of<SubscriptionPresenter>(context,
                                  listen: false)
                              .updateTimeSlot(j, value);
                          // orderController.updateTimeSlot(value);
                        },
                        isExpanded: true,
                        underline: SizedBox(),
                      ),
                    ),
              SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
              IconButton(
                  padding: EdgeInsets.all(5),
                  highlightColor: Colors.grey[100],
                  hoverColor: Colors.grey[100],
                  onPressed: () {
                    Provider.of<SubscriptionPresenter>(context, listen: false)
                        .removeSchedule(j);
                  },
                  icon: Icon(Icons.delete_outline, color: Colors.red))
            ]),
            SizedBox(height: 16),
            for (int i = 0;
                i <
                    subscriptionsModelView
                        .my_subscriptionlist[subscriptionsModelView.index]
                        .productListModel
                        .length;
                i++) /*
   subscriptionPresenter.getQuantity(context,i,j).toString()=="0"?Container():*/
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      constraints: BoxConstraints(maxWidth: width / 2),
                      child: Row(children: [
                        Expanded(
                            child: Row(children: [
                          Flexible(
                            child: Text(
                              subscriptionsModelView
                                  .my_subscriptionlist[
                                      subscriptionsModelView.index]
                                  .productListModel[i]
                                  .name,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                          SizedBox(width: 5),
                          Row(
                            children: [
                              Text(
                                "remaining quantity".tr,
                                style: robotoBold.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).disabledColor),
                                overflow: TextOverflow.clip,
                              ),
                              Text(
                                subscriptionPresenter.getQuantity(
                                    context, i, j),
                                style: robotoBold.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).disabledColor),
                                overflow: TextOverflow.clip,
                              ),
                            ],
                          )
                        ]))
                      ]),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: MyTextField(
                        hintText: 'qte'.tr,
                        inputType: TextInputType.number,
                        inputAction: TextInputAction.done,
                        controller: subscriptionPresenter
                            .subscriptionSchedule[j].quantityController[i],
                        onChanged: (val) {
                          if (val.toString().substring(0) == "0") {
                            setState(() {
                              subscriptionPresenter
                                  .subscriptionSchedule[j].quantityController[i]
                                  .clear();
                            });
                          }
                          if (val != "") if (int.parse(subscriptionPresenter
                                  .getQuantity(context, i, j)) <
                              0)
                          /*if(int.parse(val.toString())>subscriptionsModelView.my_subscriptionlist[subscriptionsModelView.index]
                    .productListModel[i].quantity)*/
                          {
                            setState(() {
                              subscriptionPresenter
                                  .subscriptionSchedule[j].quantityController[i]
                                  .clear();
                            });
                          }
                        },
                        showBorder: true,
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              )
          ],
        ));
  }
}
