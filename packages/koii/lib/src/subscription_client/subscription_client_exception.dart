import 'package:koii/src/subscription_client/subscribe_error.dart';

class SubscriptionClientException implements Exception {
  const SubscriptionClientException(this.error);

  final SubscribeError error;

  @override
  String toString() => '${error.code}: ${error.message}';
}
