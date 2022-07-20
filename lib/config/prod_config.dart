import 'base_config.dart';

class ProdConfig implements BaseConfig {
  @override
  String get apiHost => "https://eventos-da-rep-api.herokuapp.com";

  @override
  String get stripePublishableKey =>
      "pk_live_51LGNtsA6S1gOJhLnQceuPRLOsIgp5rNNcfXYglT3gMmUY9PK88hKiFDn4D0VJkJoX7cK6a9BR11FhjcAAfhACfxs00xiThPYyt";
}
