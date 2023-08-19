library notifications;

export './none.dart' // Stub implementation
    if (dart.library.io) './push.dart' // dart:io implementation
    if (dart.library.html) './js.dart' show myBackgroundMessageHandler, myMessageHandler, NotificationHelper ; // dart:html implementation;