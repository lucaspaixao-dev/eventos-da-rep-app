import 'package:eventos_da_rep/providers/auth_provider.dart';
import 'package:eventos_da_rep/screens/event_chat/event_chat.dart';
import 'package:eventos_da_rep/screens/event_details/event_details.dart';
import 'package:eventos_da_rep/screens/event_details/event_details_bloc.dart';
import 'package:eventos_da_rep/services/firebase_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:provider/provider.dart';

import 'controller.dart';

class EventosDaRepApp extends StatefulWidget {
  const EventosDaRepApp({Key? key}) : super(key: key);

  @override
  State<EventosDaRepApp> createState() => _EventosDaRepAppState();
}

class _EventosDaRepAppState extends State<EventosDaRepApp> {
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey(debugLabel: "Main Navigator");

  @override
  void initState() {
    super.initState();
    _initPushNotifications();
    _removeBadgerConter();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProvider();
    final eventDetailsBloc = EventDetailsBloc();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        Provider<EventDetailsBloc>(
          create: (context) => eventDetailsBloc,
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Eventos da REP',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const Controller(),
      ),
    );
  }

  void _initPushNotifications() async {
    FirebaseMessaging messaging = FirebaseService().getMessaging();
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _startPushNotificationsHandler();
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      _startPushNotificationsHandler();
    } else {
      debugPrint("The user has not authorized notification");
    }
  }

  Future<void> _firebaseMessagingBackground(RemoteMessage message) async {
    debugPrint("Background message: ${message.data}");
  }

  void _startPushNotificationsHandler() {
    FirebaseMessaging.onMessage.listen((event) {});
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackground);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data["screen"] != null) {
        final route = message.data["screen"] as String;
        final eventId = message.data["event_id"] as String;

        late Widget screen;

        switch (route) {
          case "event_chat":
            screen = EventChat(
              eventId: eventId,
              eventName: message.data["event_name"],
              userId: null,
            );
            break;
          default:
            screen = EventDetails(eventId: eventId);
        }

        if (navigatorKey.currentState != null) {
          Navigator.push(
            navigatorKey.currentState!.context,
            MaterialPageRoute(builder: (context) => screen),
          );
        }
      }
    });
  }

  void _removeBadgerConter() async {
    FlutterAppBadger.isAppBadgeSupported().then(
      (_) => FlutterAppBadger.removeBadge(),
    );
  }
}
