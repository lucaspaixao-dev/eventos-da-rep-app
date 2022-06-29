import 'package:internet_connection_checker/internet_connection_checker.dart';

Future<bool> checkInternetConnection() async =>
    await InternetConnectionChecker().hasConnection;
