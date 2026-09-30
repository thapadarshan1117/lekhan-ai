import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

class  Response {
  final int statusCode;
  final String? statusMessage;
  final dynamic data;

  Response(
      {required this.statusCode,
      this.statusMessage,
      this.data = const <String, dynamic>{}});

  @override
  String toString() {
    return 'statusCode=$statusCode\nstatusMessage=$statusMessage\n data=$data';
  }
}

extension ResponseExtension on Response {
  Right<AppException, Response> get toRight => Right(this);
}
