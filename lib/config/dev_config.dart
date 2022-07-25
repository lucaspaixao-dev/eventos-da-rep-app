import 'dart:io';

import 'base_config.dart';

class DevConfig implements BaseConfig {
  @override
  String get apiHost =>
      Platform.isAndroid ? "http://10.0.2.2:8080" : "http://localhost:8080";

  @override
  String get stripePublishableKey =>
      "pk_test_51LGNtsA6S1gOJhLnWgKUPft69BWKzy4zznzRFP6xZJC9QvLksfkybA6J1UGJWUMQLfk6DzURUv7WqnGOVUqsTE1T00h3igqbkj";
}
