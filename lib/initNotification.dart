import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class InitNotification {
  final firebasemessaging=FirebaseMessaging.instance;

var androidChannel=const AndroidNotificationChannel(
  "high_importance_channel",
  "High Importance Notification",
  description: "",
  playSound: true,
  showBadge: true,
  importance: Importance.defaultImportance
);



final _flutterlocalnotification=FlutterLocalNotificationsPlugin();


  Future<void> init()async{
await firebasemessaging.requestPermission();
final token=await firebasemessaging.getToken();
print("--wwwww--$token");
initpush();
initLocalNotification();
//FirebaseMessaging.onBackgroundMessage(handleback)
  } 

  Future initpush(){
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
     alert: true,
     badge: true,
     sound: true,
     
    );

    FirebaseMessaging.instance.getInitialMessage().then(handlemessage);
        FirebaseMessaging.onMessageOpenedApp.listen(handlemessage);

  }

  handlemessage(RemoteMessage message){
      print("---mes$message");
  }


  initLocalNotification()async{
    
    //const Ios= IOSInitializationSettings();
    const android=AndroidInitializationSettings("@drawable/notification_icon");
    const sett=InitializationSettings(android: android); //,iOS: Ios); 
   await _flutterlocalnotification.initialize(
    sett,
 /*   onSelectNotification: (pyload){

    }*/
    
   );
final platform=_flutterlocalnotification.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
platform.createNotificationChannel(androidChannel);
  }
}