import 'package:efood_multivendor/abonnements/main.dart';
import 'package:efood_multivendor/data/model/response/restaurant_model.dart';
import 'package:flutter/material.dart';


class SubscriptionsScreen extends StatefulWidget {
  final Restaurant restaurant;
  SubscriptionsScreen({@required this.restaurant});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("widget.restaurant.id ${widget.restaurant.toJson()}");
    return Abonnements(restaurantId:widget.restaurant.id);
  }
}