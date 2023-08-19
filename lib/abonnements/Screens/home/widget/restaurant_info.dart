import 'package:efood_multivendor/data/model/response/config_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/splash_controller.dart';
import '../../../constants/colors.dart';
import '../../../../data/model/response/restaurant_model.dart' as Resto;

class RestaurantInfo extends StatelessWidget {
  final Resto.Restaurant restaurant;
  final BaseUrls _baseUrls = Get.find<SplashController>().configModel.baseUrls;
  RestaurantInfo({Key key, this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 40),
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              restaurant.deliveryTime,
                              style: TextStyle(color: Colors.white),
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          restaurant.address,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          restaurant.phone,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.withOpacity(0.6),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    "${_baseUrls.restaurantImageUrl}/${restaurant.logo}",
                    width: 80,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(restaurant.phone, style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Icon(Icons.star_outline, color: kPrimaryColor),
                    Text('${restaurant.avgRating}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                    SizedBox(
                      width: 15,
                    ),
                  ],
                ),
              ],
            )
          ],
        ));
  }
}
