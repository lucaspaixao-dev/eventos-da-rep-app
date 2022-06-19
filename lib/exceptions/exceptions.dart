class ApiException implements Exception {
  String cause;
  ApiException(this.cause);
}

class InternetException extends ApiException {
  @override
  // ignore: overridden_fields
  String cause;
  InternetException(this.cause) : super(cause);
}
