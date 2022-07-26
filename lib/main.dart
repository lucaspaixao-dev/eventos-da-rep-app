import 'dart:io';

import 'package:eventos_da_rep/config/environment.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'eventos_da_rep_app.dart';
import 'http_override.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp();

  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }

  const String env = String.fromEnvironment(
    'ENV',
    defaultValue: Environment.prod,
  );

  Environment().initConfig(env);
  _initStripe();

  runApp(const EventosDaRepApp());
}

void _initStripe() {
  final String stripePublishableKey =
      Environment().config!.stripePublishableKey;

  Stripe.publishableKey = stripePublishableKey;
  Stripe.merchantIdentifier = "Eventos da REP";
}
