import 'package:json_annotation/json_annotation.dart';
import 'package:koii/src/rpc/dto/account_key.dart';
import 'package:koii/src/rpc/dto/instruction.dart';
import 'package:koii/src/rpc/dto/message.dart';
import 'package:koii/src/rpc/dto/parsed_message/header.dart';

part 'raw_message.g.dart';

@JsonSerializable(createToJson: false)
class RawMessage implements Message {
  const RawMessage({
    required this.accountKeys,
    required this.header,
    required this.recentBlockhash,
    required this.instructions,
  });

  factory RawMessage.fromJson(Map<String, dynamic> json) =>
      _$RawMessageFromJson(json);

  final List<AccountKey> accountKeys;
  final Header? header;
  final String recentBlockhash;
  final List<Instruction> instructions;
}
