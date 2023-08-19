import 'dart:convert';

class ProductModel {
  int totalSize;
  String limit;
  int offset;
  List<Product> products;

  ProductModel( {
    this.totalSize ,
    this.limit ,
    this.offset ,
    this.products
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'].toString();
    offset = (json['offset'] != null && json['offset'].toString().trim().isNotEmpty) ? int.parse(json['offset'].toString()) : null;
    if (json['products'] != null) {
      products = [];
      json['products'].forEach((v) {
        products.add(new Product.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_size'] = this.totalSize;
    data['limit'] = this.limit;
    data['offset'] = this.offset;
    if (this.products != null) {
      data['products'] = this.products.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Product {
  int id;
  String name;
  String description;
  String image;
  int categoryId;
  int quantity;
  List<CategoryIds> categoryIds;
  List<Variation> variations;
  List<AddOns> addOns;
  List<ChoiceOptions> choiceOptions;
  double price;
  double tax;
  double discount;
  String discountType;
  String availableTimeStarts;
  String availableTimeEnds;
  int restaurantId;
  String restaurantName;
  double restaurantDiscount;
  bool scheduleOrder;
  double avgRating;
  int ratingCount;
  int veg;

  Product(
      {this.id,
        this.name,
        this.description,
        this.image,
        this.quantity,
        this.categoryId,
        this.categoryIds,
        this.variations,
        this.addOns,
        this.choiceOptions,
        this.price,
        this.tax,
        this.discount,
        this.discountType,
        this.availableTimeStarts,
        this.availableTimeEnds,
        this.restaurantId,
        this.restaurantName,
        this.restaurantDiscount,
        this.scheduleOrder,
        this.avgRating,
        this.ratingCount,
        this.veg,
      });

  Product.fromJson(Map<String, dynamic> _json) {
   

    id = _json['id'];
    name = _json['name'];
    description = _json['description'];
    image = _json['image'];
    categoryId = _json['category_id'];
    if (_json['category_ids'] != null) {
      categoryIds = [];
      _json['category_ids'].forEach((v) {
        categoryIds.add(new CategoryIds.fromJson(v));
      });
    }
    if (_json['variations'] != null) {
      variations = [];
      _json['variations'].forEach((v) {
        variations.add(new Variation.fromJson(v));
      });
    }
    
    if (_json['add_ons'] != null) {
      addOns = [];
      
      _json['add_ons'].forEach((v) {
        if(v!="")
        addOns.add(new AddOns.fromJson(v));
      });
    }
    if (_json['choice_options'] != null) {
      choiceOptions = [];
      _json['choice_options'].forEach((v) {
        choiceOptions.add(new ChoiceOptions.fromJson(v));
      });
    }
    price = _json['price'].toDouble();
    tax = _json['tax'] != null ? _json['tax'].toDouble() : null;
    discount = _json['discount'].toDouble();
    discountType = _json['discount_type'];
    availableTimeStarts = _json['available_time_starts'];
    availableTimeEnds = _json['available_time_ends'];
    restaurantId = _json['restaurant_id'];
    restaurantName = _json['restaurant_name'];
    restaurantDiscount = _json.containsKey("restaurant_discount")? _json['restaurant_discount'].toDouble():0;
    scheduleOrder = _json['schedule_order'];
    avgRating = _json['avg_rating'].toDouble();
    ratingCount = _json['rating_count'];
    veg = _json['veg'] != null ? int.parse(_json['veg'].toString()) : 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['image'] = this.image;
    data['category_id'] = this.categoryId;
    if (this.categoryIds != null) {
      data['category_ids'] = this.categoryIds.map((v) => v.toJson()).toList();
    }
    if (this.variations != null) {
      data['variations'] = this.variations.map((v) => v.toJson()).toList();
    }
    if (this.addOns != null) {
      data['add_ons'] = this.addOns.map((v) => v.toJson()).toList();
    }
    if (this.choiceOptions != null) {
      data['choice_options'] =
          this.choiceOptions.map((v) => v.toJson()).toList();
    }
    data['price'] = this.price;
    data['tax'] = this.tax;
    data['discount'] = this.discount;
    data['discount_type'] = this.discountType;
    data['available_time_starts'] = this.availableTimeStarts;
    data['available_time_ends'] = this.availableTimeEnds;
    data['restaurant_id'] = this.restaurantId;
    data['restaurant_name'] = this.restaurantName;
    data['restaurant_discount'] = this.restaurantDiscount;
    data['schedule_order'] = this.scheduleOrder;
    data['avg_rating'] = this.avgRating;
    data['rating_count'] = this.ratingCount;
    data['veg'] = this.veg;
    return data;
  }
}

class CategoryIds {
  String id;

  CategoryIds({this.id});

  CategoryIds.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    return data;
  }
}

class Variation {
  String type;
  double price;

  Variation({this.type, this.price});

  Variation.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    price = json['price'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['price'] = this.price;
    return data;
  }
}

class AddOns {
  int id;
  String name;
  double price;

  AddOns(
      {this.id,
        this.name,
        this.price});

  AddOns.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    return data;
  }
}

class ChoiceOptions {
  String name;
  String title;
  List<String> options;

  ChoiceOptions({this.name, this.title, this.options});

  ChoiceOptions.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    title = json['title'];
    options = json['options'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['title'] = this.title;
    data['options'] = this.options;
    return data;
  }
}
