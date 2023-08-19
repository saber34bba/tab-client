import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SubscriptionModel {
  int id,restaurantid,abonnement_stockeid;
bool isordered=false;
int stockid;
int is_ordered=0;
int total_quantity;
DateTime created_at_dateTime;
String created_at, dateTime;
  String name_ar, name_en, name_fr;
  String des_ar, des_en, des_fr;
  String image;
  String prix;
  int status;
  List<Map<String,int>> productList=[];
  List<Product> productListModel=[];
  List<Size_Model> sizeList=[];
  SubscriptionModel(
      {this.id,
      this.stockid,
      this.abonnement_stockeid,
      this.restaurantid,
      this.name_ar,
      this.name_en,
      this.name_fr,
      this.des_ar,
      this.des_en,
      this.des_fr,
      this.status,
      this.image,
      this.created_at,
      this.dateTime,
      this.created_at_dateTime,
      this.prix,
      this.total_quantity,
      this.is_ordered
      });

  factory SubscriptionModel.fromJson(Map<String, dynamic> map) {

    String sub_url= Get.find<SplashController>().configModel.baseUrls.abonnementUrl;

int _status=0;
int _abonnement_stockeid=0;
  if(map.containsKey("Abonnement_stocke")){
    if(map["Abonnement_stocke"]["status"].toString()=="0")
     _status=0;
       if(map["Abonnement_stocke"]["status"].toString()=="1"){
      _status=1;
     }
        if(map["Abonnement_stocke"]["status"].toString()=="2"){
      _status=2;
     }

  }

int ordered=0;
    if(map.containsKey("Abonnement_stocke")){
     _abonnement_stockeid=int.parse(map["Abonnement_stocke"]["id"].toString());
     ordered=  int.parse(map["Abonnement_stocke"]["status"].toString());

  }


 
    return SubscriptionModel(
      id: map["id"],
      abonnement_stockeid: _abonnement_stockeid,
      restaurantid:map["restaurant_id"],
       name_ar: map["name_ar"],
      name_en: map["name_en"],
      name_fr: map["name_fr"],
      des_ar: map["description_er"],
      des_en: map["description_en"],
      des_fr: map["description_fr"],
      status: _status,
      is_ordered:ordered,
      created_at:map["created_at"].toString().split("T")[0],
      dateTime:map["created_at"],
      image: sub_url+"/"+map["image"],
      prix:map["prix"].toString(),
      created_at_dateTime:DateTime.parse(map["created_at"].toString().split("T")[0])
    );
  }
}

class Size_Model{
  int id,addon_id;
  int index;
  String addon_nameAr,addon_nameEn,addon_nameFr;
  int price;
  int qte;
  Size_Model({
    this.id,
    this.addon_id,
    this.addon_nameAr,
    this.addon_nameEn,
    this.addon_nameFr,
    this.price,
    this.qte
  });
factory Size_Model.fromJson(Map<dynamic,dynamic>map){

return Size_Model(
  id: int.parse(map["id"].toString()),
  addon_id: int.parse(map["addon_id"].toString()),
  addon_nameAr: map["name"],
 //addon_nameEn: map[""],
 // addon_nameFr: map[""],
  price:map["price"]==null?0: int.parse(map["price"].toString()),
  qte: int.parse(map["qte"].toString())
);
}
}

class SubscriptionSchedule {
  int id;
  String date,time;
  int quantity;
  int timeIndex,dateIndex;
  DateTime selectedDate;
  TextEditingController dateController=TextEditingController();
    TextEditingController timeController=TextEditingController();
 List< TextEditingController> quantityController=[];

List<int>timeList=[];
  SubscriptionSchedule({
    this.id,
    this.selectedDate,
    this.date,this.time,this.quantity
  });
}