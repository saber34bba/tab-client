
import 'package:efood_multivendor/data/model/body/notification_body.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

abstract class NotificationBase {
  static NotificationBase instance;
  @mustCallSuper
  NotificationBase(){
    if(instance ==  null){
      instance = this;
    }
  }
  Future<void> initialize();
  Future<void> showNotification(RemoteMessage message, bool data);
  Future<void> showTextNotification(String title, String body, String orderID, NotificationBody notificationBody, );
  Future<void> showBigTextNotification(String title, String body, String orderID, NotificationBody notificationBody, );
  Future<void> showBigPictureNotificationHiddenLargeIcon( String title, String body, String orderID, NotificationBody notificationBody, String image,);
  NotificationBody convertNotification(Map<String, dynamic> data);
}

class NotificationHelper extends NotificationBase{
  @override
  NotificationBody convertNotification(Map<String, dynamic> data) {
    // TODO: implement convertNotification
    throw UnimplementedError();
  }

  @override
  Future<void> initialize() {
    print("LOAD_??_NOTIFICATION");
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  Future<void> showBigPictureNotificationHiddenLargeIcon(String title, String body, String orderID, NotificationBody notificationBody, String image) {
    // TODO: implement showBigPictureNotificationHiddenLargeIcon
    throw UnimplementedError();
  }

  @override
  Future<void> showBigTextNotification(String title, String body, String orderID, NotificationBody notificationBody) {
    // TODO: implement showBigTextNotification
    throw UnimplementedError();
  }

  @override
  Future<void> showNotification(RemoteMessage message, bool data) {
    // TODO: implement showNotification
    throw UnimplementedError();
  }

  @override
  Future<void> showTextNotification(String title, String body, String orderID, NotificationBody notificationBody) {
    // TODO: implement showTextNotification
    throw UnimplementedError();
  }

}
