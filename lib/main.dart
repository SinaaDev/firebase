import 'package:fire/screens/auth_screen.dart';
import 'package:fire/screens/home_screen.dart';
import 'package:fire/screens/signin_screen.dart';
import 'package:fire/screens/verify_email_screen.dart';
import 'package:fire/upload_file.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';

const channel = AndroidNotificationChannel(
  'high_importance_channel',
  'high importance notifications',
  description: 'this channel used for important notifications!',
  importance: Importance.high,
  playSound: true
);

final flutterLocalNotificationsPanel = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final messaging = FirebaseMessaging.instance;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  flutterLocalNotificationsPanel
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  ?.createNotificationChannel(channel);
await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  alert: true,
  badge: true,
  sound: true,
)

  
  ;

  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    carPlay: false,
    announcement: false,
    criticalAlert: false,
    provisional: false,
  );

  debugPrint('User granted permission: ${settings.authorizationStatus}');

  FirebaseMessaging.onMessage.listen(
    (message) {
      debugPrint('Got a message while in foreground !');
      debugPrint('message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
            'message also contained a notification: ${message.notification}');
      }
    },
  );

  runApp(MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Something went wrong'),
              );
            } else if (snapshot.hasData) {
              return VerifyEmailScreen();
            } else {
              return AuthScreen();
            }
          }),
    );
  }
}
