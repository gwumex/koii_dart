import 'package:json_annotation/json_annotation.dart';
import 'package:koii/src/subscription_client/abstract_message.dart';

part 'subscribed_message.g.dart';

@JsonSerializable(createToJson: false)
class SubscribedMessage implements SubscriptionMessage {
  const SubscribedMessage({
    required this.result,
    required this.id,
  });

  factory SubscribedMessage.fromJson(Map<String, dynamic> json) =>
      _$SubscribedMessageFromJson(json);

  final int result;
  final int id;
}
