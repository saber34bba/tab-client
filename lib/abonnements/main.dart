import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../data/model/response/restaurant_model.dart';
import './Screens/home/home.dart';

void main() {
  runApp(AbonnementsApp());
}

class AbonnementsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Abonnement',
      home: HomePage(),
    );
  }
}
class Abonnements extends StatefulWidget {
  final int restaurantId;
  Abonnements({Key key, @required this.restaurantId}) : super(key: key);

  @override
  State<Abonnements> createState() => _AbonnementsState();
}

class _AbonnementsState extends State<Abonnements> {
  Restaurant restaurant;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    restaurant = Get.find<RestaurantController>().restaurantModel.restaurants.firstWhere((resto)=>resto.id == widget.restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    print("HOME? widget.restaurant.id ${restaurant.name}");
    return HomePage(restaurant: restaurant);
  }
}
