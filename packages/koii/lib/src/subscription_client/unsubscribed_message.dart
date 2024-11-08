import 'package:json_annotation/json_annotation.dart';
import 'package:koii/src/subscription_client/abstract_message.dart';

part 'unsubscribed_message.g.dart';

@JsonSerializable(createToJson: false)
class UnsubscribedMessage implements SubscriptionMessage {
  const UnsubscribedMessage({
    required this.result,
    required this.id,
  });

  factory UnsubscribedMessage.fromJson(Map<String, dynamic> json) =>
      _$UnsubscribedMessageFromJson(json);

  final int result;
  final int id;
}
