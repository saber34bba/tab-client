import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/location_controller.dart';
import '../../util/images.dart';

class CartWidget extends StatelessWidget {
  final Color color;
  final double size;
  final bool fromRestaurant;
  CartWidget(
      {@required this.color, @required this.size, this.fromRestaurant = false});

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      GetBuilder<CartController>(builder: (cartController) {
        return Center(
          child: Image.asset(
            cartController.cartList.length > 0
                ? Images.shopping_cart_checkout
                : Images.shopping_cart,
            color: color,
            width: IconTheme.of(context).size * 1.3,
          ),
        );
      }),

      Positioned(
        top: 24,
        left: 19,
              child : Container(
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Opacity(
                  opacity: 1,
                  child: SizedBox(
                    height: 18,
                    width: 18,
                    child: GetBuilder<LocationController>(builder:(controller) => controller.hasPrecipitation ? Image.asset(controller.wheaterIcon) : SizedBox.shrink(),),
                  )
                )
              )
            ),
      GetBuilder<CartController>(builder: (cartController) {
        return cartController.cartList.length > 0
            ? Positioned(
                top: 7,
                right: 7,
                child: Container(
                  height: (size < 20 ? 10 : size / 2) + 5,
                  width: (size < 20 ? 10 : size / 2) + 5,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fromRestaurant
                        ? Theme.of(context).cardColor
                        : Theme.of(context).primaryColor,
                    border: Border.all(
                        width: size < 20 ? 0.7 : 1,
                        color: fromRestaurant
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).cardColor),
                  ),
                  child: FittedBox(
                    child: Padding(
                      padding: EdgeInsets.all(2),
                      child: Text(
                        cartController.cartList.length.toString(),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                        style: robotoRegular.copyWith(
                          // fontSize: size < 20 ? size / 2.8 : size / 2,
                          color: fromRestaurant
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).cardColor,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : SizedBox();
      }),
    ]);
  }
}
