import 'package:json_annotation/json_annotation.dart';
import 'package:koii/src/rpc/dto/account_key.dart';
import 'package:koii/src/rpc/dto/instruction.dart';
import 'package:koii/src/rpc/dto/message.dart';
import 'package:koii/src/rpc/dto/parsed_message/header.dart';

export 'header.dart';
export 'parsed_instruction.dart';
export 'parsed_spl_token_instruction.dart';
export 'parsed_system_instruction.dart';
export 'spl_token_transfer_checked_info.dart';
export 'spl_token_transfer_info.dart';

part 'parsed_message.g.dart';

/// A parsed message that is part of a [Transaction] object.
@JsonSerializable(createToJson: false)
class ParsedMessage implements Message {
  ParsedMessage({
    required this.accountKeys,
    required this.recentBlockhash,
    required this.instructions,
    required this.header,
  });

  factory ParsedMessage.fromJson(Map<String, dynamic> json) =>
      _$ParsedMessageFromJson(json);

  final List<AccountKey> accountKeys;
  final Header? header;
  final String recentBlockhash;
  final List<Instruction> instructions;
}
