import 'package:efood_multivendor/data/model/response/basic_campaign_model.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/data/model/response/restaurant_model.dart';

class BannerModel {
  List<BasicCampaignModel> campaigns;
  List<Banner> _banners;
  List<Banner> get banners => _banners.where((banner) => !banner.popup).toList(growable: false);
  List<Banner> get popups => _banners.where((banner) => banner.popup).toList(growable: false);

  BannerModel({this.campaigns, List<Banner> banners}):
    _banners = banners;

  BannerModel.fromJson(Map<String, dynamic> json) {
    if (json['campaigns'] != null) {
      campaigns = [];
      json['campaigns'].forEach((v) {
        campaigns.add(BasicCampaignModel.fromJson(v));
      });
    }
    if (json['banners'] != null) {
      _banners = [];
      json['banners'].forEach((v) {
        _banners.add(Banner.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.campaigns != null) {
      data['campaigns'] = this.campaigns.map((v) => v.toJson()).toList();
    }
    if (this._banners != null) {
      data['banners'] = this._banners.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Banner {
  int id;
  String title;
  String type;
  String image;
  Restaurant restaurant;
  Product food;
  String link;
  bool popup;

  Banner(
      {this.id, this.title, this.type, this.image, this.restaurant, this.food, this.popup, this.link});

  Banner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
    image = json['image'];
    link = json['link'] ?? "";
    popup = json['popup'];
    restaurant = json['restaurant'] != null ? Restaurant.fromJson(json['restaurant']) : null;
    food = json['food'] != null ? Product.fromJson(json['food']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['type'] = this.type;
    data['image'] = this.image;
    data['link'] = this.link;
    data['popup'] = this.popup;
    if (this.restaurant != null) {
      data['restaurant'] = this.restaurant.toJson();
    }
    if (this.food != null) {
      data['food'] = this.food.toJson();
    }
    return data;
  }
}
