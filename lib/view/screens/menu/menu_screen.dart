import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/model/response/menu_model.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/view/screens/menu/widget/menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../controller/user_controller.dart';
import '../../../controller/wishlist_controller.dart';
import '../../../helper/price_converter.dart';
import '../../../util/styles.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    double _ratio = ResponsiveHelper.isDesktop(context) ? 1.1 : ResponsiveHelper.isTab(context) ? 1.1 : 1.2;

    final List<MenuModel> _menuList = [
      MenuModel(icon: Icons.account_circle, title: 'profile'.tr, route: RouteHelper.getProfileRoute()),
      if(_isLoggedIn)
        MenuModel(icon: Icons.account_circle, title: 'profile'.tr, route: RouteHelper.getProfileRoute()),
      if(_isLoggedIn)
        MenuModel(icon: Icons.favorite_outlined, title: 'favourite'.tr, route: RouteHelper.getMainRoute('favourite')),
      if(_isLoggedIn)
        MenuModel(icon: Icons.shopping_cart, title: 'my_cart'.tr, route: RouteHelper.getCartRoute()),
      if(_isLoggedIn)
        MenuModel(icon: Icons.receipt_long, title: 'my_orders'.tr, route: RouteHelper.getMainRoute('order')),
      MenuModel(icon: Icons.pin_drop, title: 'my_address'.tr, route: RouteHelper.getAddressRoute()),
      MenuModel(icon: Icons.translate, title: 'language'.tr, route: RouteHelper.getLanguageRoute('menu')),
      MenuModel(icon: Icons.confirmation_number, title: 'coupon'.tr, route: RouteHelper.getCouponRoute(fromCheckout: false)),
      MenuModel(icon: Icons.support_agent, title: 'help_support'.tr, route: RouteHelper.getSupportRoute()),
      MenuModel(icon: Icons.verified_user, title: 'privacy_policy'.tr, route: RouteHelper.getHtmlRoute('privacy-policy')),
      MenuModel(icon: Icons.contact_support, title: 'about_us'.tr, route: RouteHelper.getHtmlRoute('about-us')),
      MenuModel(icon: Icons.privacy_tip, title: 'terms_conditions'.tr, route: RouteHelper.getHtmlRoute('terms-and-condition')),
      MenuModel(icon: Icons.forum, title: 'live_chat'.tr, route: RouteHelper.getConversationRoute()),
    ];

    if(Get.find<SplashController>().configModel.refEarningStatus == 1 ){
      _menuList.add(MenuModel(icon: Icons.pin, title: 'refer'.tr, route: RouteHelper.getReferAndEarnRoute()));
    }
    if(Get.find<SplashController>().configModel.customerWalletStatus == 1 ){
      _menuList.add(MenuModel(icon: Icons.account_balance_wallet, title: 'wallet'.tr, route: RouteHelper.getWalletRoute(true)));
    }
    if(Get.find<SplashController>().configModel.loyaltyPointStatus == 1 ){
      _menuList.add(MenuModel(icon: Icons.loyalty, title: 'loyalty_points'.tr, route: RouteHelper.getWalletRoute(false)));
    }
    if(Get.find<SplashController>().configModel.toggleDmRegistration && !ResponsiveHelper.isDesktop(context)) {
      _menuList.add(MenuModel(
        icon: Icons.directions_bike, title: 'join_as_a_delivery_man'.tr,
        route: RouteHelper.getDeliverymanRegistrationRoute(),
      ));
    }
    if(Get.find<SplashController>().configModel.toggleRestaurantRegistration && !ResponsiveHelper.isDesktop(context)) {
      _menuList.add(MenuModel(
        icon: Icons.storefront, title: 'join_as_a_restaurant'.tr,
        route: RouteHelper.getRestaurantRegistrationRoute(),
      ));
    }
    _menuList.add(MenuModel(icon: _isLoggedIn ? Icons.login : Icons.logout, title: _isLoggedIn ? 'logout'.tr : 'sign_in'.tr, route: ''));

    return PointerInterceptor(
      child: Container(
        width: Dimensions.WEB_MAX_WIDTH,
        // padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          color: Theme.of(context).cardColor,
        ),
        child: _buildMenu(context,ratio: _ratio, menu: _menuList)
      ),
    );
  }
  Widget _buildMenuGrid(BuildContext context, {
    double ratio = 1.0,
    List<MenuModel> menu = const <MenuModel>[]
  }){
    return Column(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          InkWell(
            onTap: () => Get.back(),
            // onTap: () => Navigator.of(context).pop(),
            // onTap: () => SmartDialog.dismiss(tag: 'MENU'),
            child: Icon(Icons.keyboard_arrow_down_rounded, size: 30),
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

          GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : ResponsiveHelper.isTab(context) ? 6 : 4,
              childAspectRatio: (1/ratio),
              crossAxisSpacing: Dimensions.PADDING_SIZE_EXTRA_SMALL, mainAxisSpacing: Dimensions.PADDING_SIZE_EXTRA_SMALL,
            ),
            itemCount: menu.length,
            itemBuilder: (context, index) {
              return MenuButton(menu: menu[index], isProfile: index == 0, isLogout: index == menu.length-1);
            },
          ),
          SizedBox(height: ResponsiveHelper.isMobile(context) ? Dimensions.PADDING_SIZE_SMALL : 0),

        ]);
  }
  Widget _buildMenu(BuildContext context, {
    double ratio = 1.0,
    List<MenuModel> menu = const <MenuModel>[]
  }){
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.amber,
          flexibleSpace: Padding(
            padding: EdgeInsets.all(10),
            child : InkWell(
              onTap: (){
                if(!Get.find<AuthController>().isLoggedIn() || Get.find<UserController>().userInfoModel == null){
                  Get.find<WishListController>().removeWishes();
                  Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
                }else{
                  Get.offNamed(menu.first.route );
                }
              },
              child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                ProfileImageWidget(size: 100),
                SizedBox(height: 15,),
                GetBuilder<UserController>(builder: (userController) {
                  return Text(
                    !Get.find<AuthController>().isLoggedIn() || userController.userInfoModel == null ? 'guest'.tr : "${userController.userInfoModel.fName} ${userController.userInfoModel.lName}",
                    style: TextStyle(fontSize: 25,color: Colors.white),
                  );
                })
              ],
            ),)
          ),
          expandedHeight: 200,
          collapsedHeight: 200,
          actions: [IconButton(onPressed: (){
            SmartDialog.dismiss();
            // Get.back()
            // Navigator.of(context).pop();
          }, icon: Icon(Icons.close))],
                    // floating: true,
          // pinned: true,
          automaticallyImplyLeading: false,
        ),
        SliverAppBar(
          backgroundColor:Get.find<AuthController>().isLoggedIn() ? Colors.red : Colors.green,
          title: MenuButton(menu: menu.last,isLogout: true,),
          floating: false,
          pinned: true,
          automaticallyImplyLeading: false,
        ),
        SliverAppBar(
            backgroundColor: (Get.find<AuthController>().isLoggedIn() ? Colors.red : Colors.green).withOpacity(0.8),
            flexibleSpace: GetBuilder<UserController>(builder: (userController) {
              return Center(
                child : !Get.find<AuthController>().isLoggedIn() || userController.userInfoModel == null ? Text(
                  'guest_mode'.tr,
                  textAlign: TextAlign.center,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).cardColor)
                ) : InkWell(
                  child : Row(
                    crossAxisAlignment: CrossAxisAlignment.center, 
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('wallet_amount'.tr,style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).cardColor)),
                      SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                      Text(
                        PriceConverter.convertPrice(userController.userInfoModel.walletBalance),
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).cardColor),
                      ),
                    ]
                  ),
                  onTap: () {
                    Get.offNamed(RouteHelper.getWalletRoute(true));
                  })
              );
            }),
            floating: true,
            pinned: true,
            automaticallyImplyLeading: false,
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              index = index+1;
              return MenuButton(menu: menu[index]);
            },
            childCount: menu.length - 2 , // 1000 list items
          ),
        ),
      ],
    );
  }
}
