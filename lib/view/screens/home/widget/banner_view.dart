import 'package:carousel_slider/carousel_slider.dart';
import 'package:efood_multivendor/controller/banner_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/theme_controller.dart';
import 'package:efood_multivendor/data/model/response/basic_campaign_model.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/data/model/response/restaurant_model.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/product_bottom_sheet.dart';
import 'package:efood_multivendor/view/screens/restaurant/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BannerView extends StatelessWidget {
  static Widget banner({BuildContext context, dynamic item, String image, bool pop = false, Color backgroundColor}) =>
      InkWell(
        onTap: () {
          if(pop){
            Get.back();
          }
          if (item is Product) {
            Product _product = item;
            ResponsiveHelper.isMobile(context)
                ? showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (con) => ProductBottomSheet(product: _product),
                  )
                : showDialog(
                    context: context,
                    builder: (con) =>
                        Dialog(child: ProductBottomSheet(product: _product)),
                  );
          } else if (item is Restaurant) {
            Restaurant _restaurant = item;
            Get.toNamed(
              RouteHelper.getRestaurantRoute(_restaurant.id),
              arguments: RestaurantScreen(restaurant: _restaurant),
            );
          } else if (item is BasicCampaignModel) {
            BasicCampaignModel _campaign = item;
            Get.toNamed(RouteHelper.getBasicCampaignRoute(_campaign));
          } else if (item is String ) {
            canLaunchUrlString("$item").then((value) => launchUrlString("$item"));
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).cardColor,
            borderRadius: backgroundColor == null ?  BorderRadius.circular(Dimensions.RADIUS_SMALL) : BorderRadius.circular(0),
            boxShadow: backgroundColor == null ? [
              BoxShadow(
                  color: Colors.grey[Get.isDarkMode ? 800 : 200],
                  spreadRadius: 1,
                  blurRadius: 5)
            ] : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
            child: GetBuilder<SplashController>(
              builder: (splashController) {
                return CustomImage(
                  image: image,
                  fit: BoxFit.contain,
                  backgroundColor: backgroundColor,
                );
              },
            ),
          ),
        ),
      );
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BannerController>(builder: (bannerController) {
      return (bannerController.bannerImageList != null &&
              bannerController.bannerImageList.length == 0)
          ? SizedBox()
          : Container(
              width: MediaQuery.of(context).size.width,
              height: ResponsiveHelper.isDesktop(context)
                  ? 500
                  : ((MediaQuery.of(context).size.width +
                          2 * Dimensions.PADDING_SIZE_DEFAULT +
                          26) *
                      0.3),
              padding: EdgeInsets.only(top: Dimensions.PADDING_SIZE_DEFAULT),
              child: bannerController.bannerImageList != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: CarouselSlider.builder(
                            options: CarouselOptions(
                              autoPlay: true,
                              enlargeCenterPage: true,
                              aspectRatio: 10 / 3,
                              disableCenter: true,
                              autoPlayInterval: Duration(seconds: 7),
                              onPageChanged: (index, reason) {
                                bannerController.setCurrentIndex(index, true);
                              },
                            ),
                            itemCount:
                                bannerController.bannerImageList.length == 0
                                    ? 1
                                    : bannerController.bannerImageList.length,
                            itemBuilder: (context, index, _) {
                              String _baseUrl =
                                  bannerController.bannerDataList[index]
                                          is BasicCampaignModel
                                      ? Get.find<SplashController>()
                                          .configModel
                                          .baseUrls
                                          .campaignImageUrl
                                      : Get.find<SplashController>()
                                          .configModel
                                          .baseUrls
                                          .bannerImageUrl;
                              return banner(
                                  context: context,
                                  item: bannerController.bannerDataList[index],
                                  image:
                                      '$_baseUrl/${bannerController.bannerImageList[index]}');
                            },
                          ),
                        ),
                        SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: bannerController.bannerImageList.map((bnr) {
                            int index =
                                bannerController.bannerImageList.indexOf(bnr);
                            return TabPageSelectorIndicator(
                              backgroundColor:
                                  index == bannerController.currentIndex
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.5),
                              borderColor: Theme.of(context).backgroundColor,
                              size: index == bannerController.currentIndex
                                  ? 10
                                  : 7,
                            );
                          }).toList(),
                        ),
                      ],
                    )
                  : Shimmer(
                      duration: Duration(seconds: 2),
                      enabled: bannerController.bannerImageList == null,
                      child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(Dimensions.RADIUS_SMALL),
                            color: Colors.grey[
                                Get.find<ThemeController>().darkTheme
                                    ? 700
                                    : 300],
                          )),
                    ),
            );
    });
  }
}
