import 'dart:convert';

import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/chat_controller.dart';
import 'package:efood_multivendor/controller/notification_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/model/body/notification_body.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/helper/user_type.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/notifications/none.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class NotificationHelper extends NotificationBase {
  Future<void> initialize() async {    
    print("LOAD_JS_NOTIFICATION");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: ${message.notification.title}/${message.notification.body}/${message.data}");
      if(message.data['type'] == 'message' && Get.currentRoute.startsWith(RouteHelper.messages)) {
        if(Get.find<AuthController>().isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1);
          if(Get.find<ChatController>().messageModel.conversation.id.toString() == message.data['conversation_id'].toString()) {
            Get.find<ChatController>().getMessages(
              1, NotificationBody(
                notificationType: NotificationType.message, adminId: message.data['sender_type'] == UserType.admin.name ? 0 : null,
                restaurantId: message.data['sender_type'] == UserType.vendor.name ? 0 : null,
                deliverymanId: message.data['sender_type'] == UserType.delivery_man.name ? 0 : null,
              ),
              null, int.parse(message.data['conversation_id'].toString()),
            );
          }else {
            showNotification(message, false);
          }
        }
      }else if(message.data['type'] == 'message' && Get.currentRoute.startsWith(RouteHelper.conversation)) {
        if(Get.find<AuthController>().isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1);
        }
        showNotification(message, false);
      }else {
        showNotification(message, false);
        if(Get.find<AuthController>().isLoggedIn()) {
          Get.find<OrderController>().getRunningOrders(1);
          Get.find<OrderController>().getHistoryOrders(1);
          Get.find<NotificationController>().getNotificationList(true);
          // if(message.data['type'] == 'message' && message.data['message'] != null && message.data['message'].isNotEmpty) {
          //   if(Get.currentRoute.contains(RouteHelper.conversation)) {
          //     Get.find<ChatController>().reloadConversationWithNotification(m.Message.fromJson(message.data['message']).conversationId);
          //   }else {
          //     Get.find<ChatController>().reloadMessageWithNotification(m.Message.fromJson(message.data['message']));
          //   }
          // }
        }
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onOpenApp: ${message.notification.title}/${message.notification.body}/${message.notification.titleLocKey}");
      try{
        if(message.data != null || message.data.isNotEmpty) {
          NotificationBody _notificationBody = convertNotification(message.data);
          if(_notificationBody.notificationType == NotificationType.order) {
            print('order call-------------');
            Get.toNamed(RouteHelper.getOrderDetailsRoute(int.parse(message.data['order_id'])));
          } else if(_notificationBody.notificationType == NotificationType.general) {
            Get.toNamed(RouteHelper.getNotificationRoute());
          } else{
            Get.toNamed(RouteHelper.getChatRoute(notificationBody: _notificationBody, conversationID: _notificationBody.conversationId));
          }
        }
      }catch (e) {}
    });
  }

  Future<void> showNotification(RemoteMessage message, bool data) async {
    if(!GetPlatform.isIOS) {
      String _title;
      String _body;
      String _orderID;
      String _image;
      NotificationBody _notificationBody = convertNotification(message.data);
      _title = message.data['title'] ?? null;
      _body = message.data['body'] ?? null;
      _orderID = message.data['order_id'] ?? null;
      _image = (message.data['image'] != null && message.data['image'].isNotEmpty)
          ? message.data['image'].startsWith('http') ? message.data['image']
          : '${AppConstants.BASE_URL}/storage/app/public/notification/${message.data['image']}' : null;
      if(!data) {
        _title = message.notification.title;
        _body = message.notification.body;
        _orderID = message.notification.titleLocKey;
        if(GetPlatform.isAndroid) {
          _image = (message.notification.android.imageUrl != null && message.notification.android.imageUrl.isNotEmpty)
              ? message.notification.android.imageUrl.startsWith('http') ? message.notification.android.imageUrl
              : '${AppConstants.BASE_URL}/storage/app/public/notification/${message.notification.android.imageUrl}' : null;
        }else if(GetPlatform.isIOS) {
          _image = (message.notification.apple.imageUrl != null && message.notification.apple.imageUrl.isNotEmpty)
              ? message.notification.apple.imageUrl.startsWith('http') ? message.notification.apple.imageUrl
              : '${AppConstants.BASE_URL}/storage/app/public/notification/${message.notification.apple.imageUrl}' : null;
        }
      }
      print("NOTIFICATIO SHOW $_body $_image");
      if(_image != null && _image.isNotEmpty) {
        try{
          await showBigPictureNotificationHiddenLargeIcon(_title, _body, _orderID, _notificationBody, _image);
        }catch(e) {
          await showBigTextNotification(_title, _body, _orderID, _notificationBody);
        }
      }else {
        await showBigTextNotification(_title, _body, _orderID, _notificationBody);
      }
    }
  }

  Future<void> showTextNotification(String title, String body, String orderID, NotificationBody notificationBody) async {
         var r = jsonEncode(notificationBody.toJson());
      print("JS showTextNotification $r");
      return showDialog<void>(context: Get.context, builder: (BuildContext context) {
        return _NotificationDialog(
          title: title,
          body: body,
          notificationBody: notificationBody,
          orderID: orderID,
        );
      });
  }

  Future<void> showBigTextNotification(String title, String body, String orderID, NotificationBody notificationBody) async {
    var r = jsonEncode(notificationBody.toJson());
    print("JS showBigTextNotification $r");
    return showDialog<void>(context: Get.context, builder: (BuildContext context) {
      return _NotificationDialog(
        title: title,
        body: body,
        notificationBody: notificationBody,
        orderID: orderID,
      );
    });
  }

  Future<void> showBigPictureNotificationHiddenLargeIcon( String title, String body, String orderID, NotificationBody notificationBody, String image,) async {
  
     var r = jsonEncode(notificationBody.toJson());
      print("JS showBigPictureNotificationHiddenLargeIcon $r");
      return showDialog<void>(context: Get.context, builder: (BuildContext context) {
        return _NotificationDialog(
          title: title,
          body: body,
          notificationBody: notificationBody,
          orderID: orderID,
          image: image,
        );
      });
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    return url;
  }

  NotificationBody convertNotification(Map<String, dynamic> data){
    if(data['type'] == 'general') {
      return NotificationBody(notificationType: NotificationType.general);
    }else if(data['type'] == 'order_status') {
      return NotificationBody(notificationType: NotificationType.order, orderId: int.parse(data['order_id']));
    }else {
      return NotificationBody(
        notificationType: NotificationType.message,
        deliverymanId: data['sender_type'] == 'delivery_man' ? 0 : null,
        adminId: data['sender_type'] == 'admin' ? 0 : null,
        restaurantId: data['sender_type'] == 'vendor' ? 0 : null,
        conversationId: int.parse(data['conversation_id'].toString()),
      );
    }
  }

}


class _NotificationDialog extends StatelessWidget {
  final String title;
  final String body;
  final String image;
  final String orderID;
  final NotificationBody notificationBody;
  _NotificationDialog({
    @required this.title,
    @required this.body,
    @required this.notificationBody,
    this.orderID = "",
    this.image = "",
  });

  @override
  Widget build(BuildContext context) {
    print("_NotificationDialog $image");
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Dimensions.RADIUS_SMALL))),
      insetPadding: EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child:  SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              if(image != null  && image.isNotEmpty)
              Container(
                height: 150, width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), color: Theme.of(context).primaryColor.withOpacity(0.20)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  child: CustomImage(
                    image:image.startsWith(RegExp(r'http(s)?://')) ? image : '${Get.find<SplashController>().configModel.baseUrls.notificationImageUrl}/${image}',
                    height: 150, width: MediaQuery.of(context).size.width, fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: robotoMedium.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Text(
                  body,
                  textAlign: TextAlign.center,
                  style: robotoRegular.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
