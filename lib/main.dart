import 'dart:io';

import 'package:eventos_da_rep/config/environment.dart';
import 'package:eventos_da_rep/screens/login/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/home/home.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp();

  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }

  FirebaseMessaging messaging = FirebaseService().getMessaging();
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    _startPushNotificationsHandler();
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    _startPushNotificationsHandler();
  } else {
    debugPrint("The user has not authorized notification");
  }

  const String env = String.fromEnvironment(
    'ENV',
    defaultValue: Environment.prod,
  );

  Environment().initConfig(env);

  _initStripe();
  runApp(const MyApp());
}

void _initStripe() {
  final String stripePublishableKey =
      Environment().config!.stripePublishableKey;

  Stripe.publishableKey = stripePublishableKey;
  Stripe.merchantIdentifier = "Eventos da REP";
}

void _startPushNotificationsHandler() async {
  FirebaseMessaging.onMessage.listen((event) {
    debugPrint("Received message: ${event.data}");

    if (event.notification != null) {
      debugPrint(
        "Message with notification: ${event.notification!.title}, ${event.notification!.body}",
      );
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackground);
}

Future<void> _firebaseMessagingBackground(RemoteMessage message) async {
  debugPrint("Background message: ${message.data}");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: MaterialApp(
          title: 'Eventos da Rep',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const Controller(),
        ),
      );
}

class Controller extends StatelessWidget {
  const Controller({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseService firebaseService = FirebaseService();

    return StreamBuilder(
      stream: firebaseService.getFirebaseAuthInstance().authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          return const Home();
        } else {
          return const Login();
        }
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
}
