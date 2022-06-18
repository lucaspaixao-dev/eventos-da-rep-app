import 'base_config.dart';

class ProdConfig implements BaseConfig {
  @override
  String get apiHost => "https://eventos-da-rep-api.herokuapp.com";
}
