import 'dart:convert';

import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/data/api/api_client.dart';
import 'package:efood_multivendor/data/model/body/place_order_body.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/screens/subscriptions/SubscriptionModel.dart';
import 'package:efood_multivendor/view/screens/subscriptions/subscriptionPresenter.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:efood_multivendor/data/model/response/address_model.dart';

class SubscriptionsModelView extends ChangeNotifier {
  String url =
      "https://the-africanbasket.com/api/v1/customer/suggested-subscribes";
  String url_mySubscription =
      "https://the-africanbasket.com/api/v1/customer/abonnements-stocke";
  List<SubscriptionModel> subscriptionlist = [];
  List<SubscriptionModel> my_subscriptionlist = [];

  bool loading = false;
  getSubscriptions() async {
    loading = true;
    subscriptionlist = [];
    notifyListeners();
    Uri _url = Uri.parse(
        "https://the-africanbasket.com/api/v1/customer/suggested-subscribes");

    var _data =
        await http.get(_url, headers: Get.find<ApiClient>().getHeader());
    
    if (_data.statusCode == 200 || _data.statusCode == 201) {
      List<dynamic> responseData = json.decode(_data.body);

      if (responseData.length > 0) {

        for (int i = 0; i < responseData.length; i++) {
          int _total=0;
          SubscriptionModel subscriptionModel =
              SubscriptionModel.fromJson(responseData[i]);

          subscriptionModel.productList = [];
          subscriptionModel.sizeList = [];
          
          if (responseData[i]["food"].length > 0) {
            for (int j = 0; j < responseData[i]["food"].length; j++) {
             
              subscriptionModel.productList.add({
                "id":
                    int.parse(responseData[i]["food"][j]["food_id"].toString()),
                "qte": int.parse(responseData[i]["food"][j]["qte"].toString())
              });
               _total=_total+int.parse(responseData[i]["food"][j]["qte"].toString());
              Map<String, dynamic> _json;

              /*responseData[i]["food"][j]["food_detail"]['category_ids'] =
                  json.decode(responseData[i]["food"][j]["food_detail"]
                      ['category_ids']);*/
responseData[i]["food"][j]["food_detail"]['category_ids']=[];

              /*responseData[i]["food"][j]["food_detail"]['variations'] =
                  json.decode(
                      responseData[i]["food"][j]["food_detail"]['variations']);*/
responseData[i]["food"][j]["food_detail"]['variations']=[];
              responseData[i]["food"][j]["food_detail"]['add_ons']=[];
              /*responseData[i]["food"][j]["food_detail"]['choice_options'] =
                  json.decode(responseData[i]["food"][j]["food_detail"]
                      ['choice_options']);*/
responseData[i]["food"][j]["food_detail"]['choice_options']=[];

              Product productModel =
                  Product.fromJson(responseData[i]["food"][j]["food_detail"]);
              productModel.image =
                  responseData[i]["food"][j]["food_detail"]["image"];
              productModel.id = int.parse(
                  responseData[i]["food"][j]["food_detail"]["id"].toString());
              productModel.quantity = responseData[i]["food"][j]["qte"] == null
                  ? 0
                  : int.parse(responseData[i]["food"][j]["qte"].toString());
              subscriptionModel.productListModel.add(productModel);
            }

        /*for(int k=0;k<responseData[i]["size"].length;k++){
        if(responseData[i]["size"][k]["prix"]!=null){   
        Size_Model size_model=Size_Model(id: int.parse(responseData[i]["size"][k]["id"].toString())
        ,price: int.parse(responseData[i]["size"][k]["prix"].toString().split(".")[0]),
        addon_id: int.parse(responseData[i]["size"][k]["addon_id"].toString()),
        addon_nameEn: responseData[i]["size"][k]["addon_detail"]["name"],
        qte: int.parse(responseData[i]["size"][k]["qte"].toString())
    );

          subscriptionModel.sizeList.add(size_model);
            if(i==5){
  print("${size_model.id} ${size_model.addon_id} ${subscriptionModel.sizeList.length}");
        }
        }
    
  }*/
   
            subscriptionModel.total_quantity=_total;
            AddSubscription(subscriptionModel);
          }else{
          }
         
        }
      } else {
        loading = false;
        notifyListeners();
       // showCustomSnackBar("please try again");
      }
    }else{
      loading=false;
      notifyListeners();
       showCustomSnackBar('you_are_not_logged_in'.tr);
    }
     loading = false;
          notifyListeners();
  }

  getMy_Subscriptions(bool reload) async {
    if (my_subscriptionlist.isNotEmpty && !reload) {
      loading=false;
      notifyListeners();
      return;
    }
    loading = true;
    my_subscriptionlist = [];
    my_subscriptionlist.clear();
    notifyListeners();

    Uri _url = Uri.parse(
        "https://the-africanbasket.com/api/v1/customer/abonnements-stocke");

    var _data =
        await http.get(_url, headers: Get.find<ApiClient>().getHeader());
   
         if (_data.statusCode == 200 || _data.statusCode == 201) {
      List<dynamic> responseData = json.decode(_data.body);
      if (responseData.length > 0) {
                   loading=false;
         notifyListeners();
        for (int i = 0; i < responseData.length; i++) {

          SubscriptionModel subscriptionModel =
              SubscriptionModel.fromJson(responseData[i]);
          subscriptionModel.productList = [];
          subscriptionModel.sizeList = [];
          subscriptionModel.productListModel = [];
          int _total=0;
          if (responseData[i]["food"].length >
              0 ) {
            for (int j = 0; j < responseData[i]["food"].length; j++) {
              subscriptionModel.productList.add({
                "id":
                    int.parse(responseData[i]["food"][j]["food_id"].toString()),
                "qte": int.parse(responseData[i]["food"][j]["qte"].toString())
              });
              _total=_total+int.parse(responseData[i]["food"][j]["qte"].toString());
              Map<String, dynamic> _json;

              Product productModel =
                  Product(); 
              productModel.id =
                  int.parse(responseData[i]["food"][j]["food_id"].toString());
              productModel.quantity =
                  int.parse(responseData[i]["food"][j]["qte"].toString());
              productModel.name = responseData[i]["food"][j]["name"];
              
              subscriptionModel.productListModel.add(productModel);
            }
            subscriptionModel.total_quantity=_total;
            AddMy_Subscription(subscriptionModel);
          }
                     
          my_subscriptionlist.sort((b, a) => a.created_at_dateTime.compareTo(b.created_at_dateTime));
          loading = false;
          notifyListeners();
        }
      } else {
        loading = false;
        notifyListeners();
      }
    } else {
      loading = false;
      notifyListeners();
      //showCustomSnackBar("please try again");
    }
  }

  AddMy_Subscription(SubscriptionModel _subscription) {
    if (my_subscriptionlist.indexWhere(
            (element) => element.abonnement_stockeid==_subscription.abonnement_stockeid) >
        0) {
      return;
    }
    my_subscriptionlist.add(_subscription);
    notifyListeners();
  }

  AddSubscription(SubscriptionModel _subscription) {
    subscriptionlist.add(_subscription);
    notifyListeners();
  }

  int index;
  SubscriptionModel subscriptionModel;
  selectSubscription(int _index) {
    subscriptionModel = subscriptionlist[_index];
    index = _index;
    notifyListeners();
  }

  selectFromMySubscription(int _index) {
    subscriptionModel = my_subscriptionlist[_index];

    index = _index;
    notifyListeners();
  }

  verifyFirstPage(BuildContext context) {
    SubscriptionPresenter subscriptionPresenter =
        Provider.of<SubscriptionPresenter>(context, listen: false);
    if (subscriptionPresenter.productList.isEmpty) {
      showCustomSnackBar("please choose products for this subscription");
      return false;
    }
    return true;
  }

  bool verifySecondPage(BuildContext context) {
    bool _isverified = true;
    SubscriptionPresenter subscriptionPresenter =
        Provider.of<SubscriptionPresenter>(context, listen: false);
    for (int i = 0;
        i < subscriptionPresenter.subscriptionSchedule.length;
        i++) {
     
    }
    return _isverified;
  }

  bool isloading = false;
  buySubcription(BuildContext context) async {
    isloading = true;
    notifyListeners();
    SubscriptionPresenter subscriptionPresenter =
        Provider.of<SubscriptionPresenter>(context, listen: false);
    Uri _url = Uri.parse(
        "https://the-africanbasket.com/api/v1/customer/abonnement_stocke");
    var request = new http.MultipartRequest("POST", _url);
    request.headers.addAll({
      "Authorization": "Bearer " + Get.find<AuthController>().getUserToken()
    });
    request.fields['abonnement_id'] = subscriptionModel.id.toString();
    List<Map<String, dynamic>> map = [];
    for (int i = 0;
        i < subscriptionPresenter.subscriptionSchedule.length;
        i++) {
      String _date = subscriptionPresenter.formatDate(
          subscriptionPresenter.subscriptionSchedule[i].selectedDate);
      String _time = subscriptionPresenter.orderTime;
      map.add({
        "date": _date,
        "time": _time,
      });
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    var data = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Center(
                child: Padding(
              padding: EdgeInsets.all(16),
              child: Stack(
                children: [
                  Container(
                    color: Colors.white,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.only(
                        top: 30, bottom: 30, left: 16, right: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/image/logo.png",
                          width:
                          ResponsiveHelper.isDesktop(context)?
                           MediaQuery.of(context).size.width * 0.2:
                           MediaQuery.of(context).size.width * 0.5,
                        ),
                        Container(
                          color: Colors.white,
                          child: Text(
                            "subscription_confirmation".tr,
                            style: robotoMedium.copyWith(
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(),
                            child: Icon(Icons.close)),
                      ))
                ],
              ),
            ));
          });

    }

    isloading = false;
    notifyListeners();
  }

  postdata(BuildContext context, bool firstpage, AddressModel _address) async {
    try {
      if (!verifySecondPage(context)) {
        showCustomSnackBar("verify_information".tr);
        return;
      }

      if (!verifyQuantity(context)) {
        
        showCustomSnackBar("add_product_qte".tr);
        return;
      }

      isloading = true;
      notifyListeners();
      SubscriptionPresenter subscriptionPresenter =
          Provider.of<SubscriptionPresenter>(context, listen: false);

      Uri _url = Uri.parse(
          "https://the-africanbasket.com/api/v1/customer/order/placeSub");
      var request = new http.MultipartRequest("POST", _url);
      request.headers.addAll({
        "Authorization": "Bearer " + Get.find<AuthController>().getUserToken()
      });
      List<Map<dynamic, dynamic>> foodmap = [];
      List<Map<String, dynamic>> map = [];
      for (int i = 0;
          i < subscriptionPresenter.subscriptionSchedule.length;
          i++) {
        foodmap = [];
        String _date = subscriptionPresenter.formatDate(
            subscriptionPresenter.subscriptionSchedule[i].selectedDate);
        String _time = "10:55";
        String scheduleat = _date + " " + _time;
        for (int j = 0; j < subscriptionModel.productList.length; j++) {
          if (subscriptionPresenter
              .subscriptionSchedule[i].quantityController[j].text.isNotEmpty)
            foodmap.add({
              "food_id": subscriptionModel.productListModel[j].id,
              "quantity": subscriptionPresenter
                  .subscriptionSchedule[i].quantityController[j].text,
              "price": 0,
              "add_ons": [],
              "item_campaign_id": null,
              "variation": [],
              "variant": [],
            });
        }

        String __date = subscriptionPresenter.formatDate(
            subscriptionPresenter.subscriptionSchedule[i].selectedDate);
        String __time = DateFormat.Hm().format(Get.find<OrderController>()
            .timeSlots[
                subscriptionPresenter.subscriptionSchedule[i].timeList.first]
            .startTime);
        String _scheduleat = __date + " " + __time;
        Map<String, dynamic> _map = {
          "abonnement_stocke": subscriptionModel.abonnement_stockeid,
          "abonnement_id": subscriptionModel.id.toString(),
          "contact_person_name": _address.contactPersonName ??
              '${Get.find<UserController>().userInfoModel.fName} '
                  '${Get.find<UserController>().userInfoModel.lName}',
          "contact_person_number": _address.contactPersonNumber ??
              Get.find<UserController>().userInfoModel.phone,
          "schedule_at": _scheduleat,
          "order_type": "delivery",
          "payment_method": "cash_on_delivery", //free
          "restaurant_id":
              Provider.of<SubscriptionsModelView>(context, listen: false)
                  .subscriptionModel
                  .restaurantid
                  .toString(),
          "latitude": _address.latitude,
          "longitude": _address.longitude,
          "order_amount": "1",
          "distance": Get.find<OrderController>().distance.toString(),
          "address": _address.address,
          "tax_amount": "0",
          "road": subscriptionPresenter.streetNumberController.text,
          "house": subscriptionPresenter.houseController.text,
          "floor": subscriptionPresenter.floorController.text,
          "cart": json.encode(foodmap)
        };

        map.add(_map);
      }

      request.fields.addAll({"subscription": json.encode(map)});
      var streamedResponse = await request.send();

      var response = await http.Response.fromStream(streamedResponse);

      var data = json.decode(response.body);
        
      if (response.statusCode == 200 || response.statusCode == 201) {
        int index = my_subscriptionlist
            .indexWhere((element) => subscriptionModel.id == element.id);
        my_subscriptionlist[index].status = 0;
        my_subscriptionlist[index].isordered = true;
        isloading = false;
        notifyListeners();
        Navigator.pop(context);
      }else{
        showCustomSnackBar(data["errors"][0]["message"]);
        isloading=false;
        notifyListeners();
        
        return;
      }
      isloading = false;
      notifyListeners();
    } catch (e, stacktrace) {
      
      showCustomSnackBar("verify_information".tr);
      isloading = false;
      notifyListeners();
    }
  }

  place(Map<dynamic, dynamic> map) {}

  clearData() {
    isloading = false;
    notifyListeners();
  }

  verifyQuantity(BuildContext context) {
    int total_in_schedule = 0;
    int total_in_subscription = 0;
    for (int j = 0;
        j <
            Provider.of<SubscriptionPresenter>(context, listen: false)
                .subscriptionSchedule
                .length;
        j++) {
      for (int i = 0; i < subscriptionModel.productListModel.length; i++) {
        if (Provider.of<SubscriptionPresenter>(context, listen: false)
            .subscriptionSchedule[j]
            .quantityController[i]
            .text
            .isNotEmpty) {
          total_in_schedule = total_in_schedule +
              int.parse(
                  Provider.of<SubscriptionPresenter>(context, listen: false)
                      .subscriptionSchedule[j]
                      .quantityController[i]
                      .text);
        }
      }
    }
    for (int i = 0; i < subscriptionModel.productListModel.length; i++) {
      total_in_subscription = total_in_subscription +
          subscriptionModel.productListModel[i].quantity;
    }

    if (total_in_subscription != total_in_schedule) {
      return false;
    } else {
      return true;
    }
  }


}
