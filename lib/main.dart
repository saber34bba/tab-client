// @dart=2.9
import 'dart:async';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/controller/localization_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/theme_controller.dart';
import 'package:efood_multivendor/controller/wishlist_controller.dart';
import 'package:efood_multivendor/data/model/body/notification_body.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/theme/dark_theme.dart';
import 'package:efood_multivendor/theme/light_theme.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:efood_multivendor/util/messages.dart';
import 'package:efood_multivendor/view/screens/subscriptions/SubscriptionModelView.dart';
import 'package:efood_multivendor/view/screens/subscriptions/subscriptionPresenter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'helper/get_di.dart' as di;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'util/notifications/notifications.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
Future<void> main() async {
   FlutterError.onError = (details) {
    FlutterError.presentError(details);
   print("wwwwwwww ${details.exception}");  // the uncaught exception
    print("ttt ${details.stack}");
  };

 if (kIsWeb) {
    // initialiaze the facebook javascript SDK
   await FacebookAuth.i.webAndDesktopInitialize(
      appId: "569761838631307",
      cookie: true,
      xfbml: true,
      version: "v14.0",
    );
  }
  if (ResponsiveHelper.isMobilePhone()) {
    HttpOverrides.global = new MyHttpOverrides();
  }
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
   //InitNotification().init();

   FirebaseMessaging.instance.requestPermission().then((value) async {
 FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.instance.getToken().then((value) {
    print("FIREBASE TOKEN $value");
  },);

  //added
FirebaseMessaging messaging = FirebaseMessaging.instance;
NotificationSettings settings = await messaging.requestPermission(
  alert: true,
  announcement: false,
  badge: true,
  carPlay: false,
  criticalAlert: false,
  provisional: false,
  sound: true,
);
if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('-----------------------User granted permission');
    // TODO: handle the received notifications
  } else {
    print('*-----------------*********User declined or has not accepted permission');
  }
   });
   
   

  Map<String, Map<String, String>> _languages = await di.init();


  NotificationBody _body;
  NotificationHelper notificationHelper = NotificationHelper();
  try
  {
      final RemoteMessage remoteMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessage != null) {
        _body = notificationHelper.convertNotification(remoteMessage.data);
      }
      await notificationHelper.initialize();
    // }
  } catch (e)
  {
    showCustomSnackBar(e);

  }

  // if (ResponsiveHelper.isWeb()) {
  //   FacebookAuth.i.webInitialize(
  //     appId: "452131619626499",
  //     cookie: true,
  //     xfbml: true,
  //     version: "v9.0",
  //   );
  // }
  runApp(MyApp(languages: _languages, body: _body));
}

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
 
}


class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>> languages;
  final NotificationBody body;
  MyApp({@required this.languages, @required this.body});

  void _route() {
    Get.find<SplashController>().getConfigData().then((bool isSuccess) async {
      if (isSuccess) {
        if (Get.find<AuthController>().isLoggedIn()) {
          Get.find<AuthController>().updateToken();
          await Get.find<WishListController>().getWishList();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (GetPlatform.isWeb) {
      Get.find<SplashController>().initSharedData();
      if (Get.find<LocationController>().getUserAddress() != null &&
          (Get.find<LocationController>().getUserAddress().zoneIds == null ||
              Get.find<LocationController>().getUserAddress().zoneData ==
                  null)) {
        Get.find<AuthController>().clearSharedAddress();
      }
      Get.find<CartController>().getCartData();
      _route();
    }

    return MultiProvider(
       providers: [
        
      ChangeNotifierProvider<SubscriptionsModelView>(
                create: (_) => SubscriptionsModelView()),
                   ChangeNotifierProvider<SubscriptionPresenter>(
                create: (_) => SubscriptionPresenter()),
          ],

      child: GetBuilder<ThemeController>(builder: (themeController) {
        return GetBuilder<LocalizationController>(builder: (localizeController) {
          return GetBuilder<SplashController>(builder: (splashController) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: (GetPlatform.isWeb && splashController.configModel == null)
                  ? SizedBox()
                  : GetMaterialApp(
                    
                    localizationsDelegates: [
                      CountryLocalizations.delegate
                    ],
                      title: AppConstants.APP_NAME,
                      debugShowCheckedModeBanner: false,
                      navigatorKey: Get.key,
                      scrollBehavior: MaterialScrollBehavior().copyWith(
                        dragDevices: {
                          PointerDeviceKind.mouse,
                          PointerDeviceKind.touch
                        },
                      ),
                      theme: themeController.darkTheme ? dark : light,
                      locale: localizeController.locale,
                      translations: Messages(languages: languages),
                      fallbackLocale: Locale(
                          AppConstants.languages[0].languageCode,
                          AppConstants.languages[0].countryCode),
                      initialRoute: GetPlatform.isWeb
                          ? RouteHelper.getInitialRoute()
                          : RouteHelper.getSplashRoute(body),
                      getPages: RouteHelper.routes,
                      defaultTransition: Transition.topLevel,
                      transitionDuration: Duration(milliseconds: 500),
                      navigatorObservers: [FlutterSmartDialog.observer],
                      builder: FlutterSmartDialog.init(
                        builder: (context, child) => Stack(
                          children: [
                            // main app
                            Positioned.fill(
                              top: 0,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: child, // if precipitation
                            ),
                            GetBuilder<LocationController>(
                              builder: (locationController) => Positioned.fill(
                                top: 0,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: locationController.hasPrecipitation
                                    ? Stack(
                                        children: locationController
                                            .precipitationType
                                            .where((element) => element == LocationAnimation.RAIN || element == LocationAnimation.SNOW)
                                            .map<IgnorePointer>((type) {
                                              return type ==
                                                      LocationAnimation.NONE
                                                  ? null
                                                  : IgnorePointer(
                                                      ignoring: true,
                                                      ignoringSemantics: true,
                                                      key: Key("LocationAnimation."+type.name),
                                                      child: Lottie.asset(
                                                        type ==
                                                                LocationAnimation
                                                                    .ORAGE
                                                            ? 'assets/lottie/lightning.json'
                                                            : (type ==
                                                                    LocationAnimation
                                                                        .RAIN
                                                                ? 'assets/lottie/rain.zip'
                                                                : (type ==
                                                                        LocationAnimation
                                                                            .SNOW
                                                                    ? 'assets/lottie/snow.json'
                                                                    : (type ==
                                                                            LocationAnimation
                                                                                .BROUILLARD
                                                                        ? 'assets/lottie/fog.zip'
                                                                        : 'assets/lottie/rain.zip'))),
                                                        fit: BoxFit.cover,
                                                        width:
                                                            MediaQuery.of(context)
                                                                .size
                                                                .width,
                                                        height:
                                                            MediaQuery.of(context)
                                                                .size
                                                                .height,
                                                      ),
                                                    );
                                            })
                                            .whereType<IgnorePointer>()
                                            .toList())
                                    : SizedBox.shrink(),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
            );
          });
        });
      }),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
