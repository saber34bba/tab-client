import 'dart:async';
import 'dart:math';

import 'package:efood_multivendor/controller/banner_controller.dart';
import 'package:efood_multivendor/view/screens/home/widget/banner_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../helper/responsive_helper.dart';
import 'splash_controller.dart';

class InfosController extends GetxController implements GetxService {
  Timer _ttl = Timer(Duration.zero, () {});
  bool hide = false;
  InfosController(Duration ttlToHide) {
    _ttl = Timer(ttlToHide, () {
      hide = true;
      update();
    });
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      // Popups
      var b = Get.find<BannerController>();
      await b.getBannerList(true);
      if (b.banners.popups.isNotEmpty) {
        var popup = b.banners.popups.elementAt(b.banners.popups.length == 1
            ? 0
            : ((Random().nextInt(2 ^ 32) + 1) % b.banners.popups.length));
        var _popupData;
        String _popupImage =
            Get.find<SplashController>().configModel.baseUrls.bannerImageUrl +
                "/" +
                popup.image;
        if (popup.food != null) {
          _popupData = popup.food;
        } else if (popup.restaurant != null) {
          _popupData = popup.restaurant;
        } else {
          _popupData = popup.link;
        }
        var show = ()=> showDialog(
          barrierDismissible: true,
          barrierColor: Colors.black38,
          barrierLabel: "popup-alert",
          context: Get.context,
          builder: (context) {
            double p = ResponsiveHelper.isDesktop(Get.context)
                ? (MediaQuery.of(context).size.width * 0.05)
                : 10;
            double w = MediaQuery.of(context).size.width - 2*p;
            double h = MediaQuery.of(context).size.height - 2*p;
            return AlertDialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              insetPadding: EdgeInsets.all(p),
              content: Container(
                width: w,
                height: h,
                child: Stack(
                  children: [
                    Positioned.fill(child: BannerView.banner(
                      context: context,
                      item: _popupData,
                      image: _popupImage,
                      pop: true,
                      backgroundColor: Colors.transparent,
                    ),),
                    Positioned(
                        right: 5,
                        top: 5,
                        child: InkWell(
                          onTap: () => Get.back(),
                          child: Container(
                            child: Icon(Icons.close),
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.white),
                          ),
                        ))
                  ],
                ),
              ),
            );
          },
        );
        show();
      }
    });
  }
}
