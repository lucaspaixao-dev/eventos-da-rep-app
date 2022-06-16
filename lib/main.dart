import 'dart:io';

import 'package:eventos_da_rep/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/home/home.dart';
import 'screens/login/login.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
    print("Usuário não deu permissão para notificações");
  }

  if (Platform.isAndroid) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }

  runApp(const MyApp());
}

void _startPushNotificationsHandler() async {
  FirebaseMessaging.onMessage.listen((event) {
    print("Mensagem recebida: ${event.data}");

    if (event.notification != null) {
      print(
        "Mensagem com notificação: ${event.notification!.title}, ${event.notification!.body}",
      );
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackground);
}

Future<void> _firebaseMessagingBackground(RemoteMessage message) async {
  print("Mensagem em background: ${message.data}");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
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
