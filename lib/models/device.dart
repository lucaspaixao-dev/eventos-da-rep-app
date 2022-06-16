class Device {
  final String brand;
  final String model;
  final String token;

  Device({
    required this.brand,
    required this.model,
    required this.token,
  });

  factory Device.fromJson(dynamic json) {
    return Device(
      brand: json['brand'] as String,
      model: json['model'] as String,
      token: json['token'] as String,
    );
  }
}
