import 'package:json_annotation/json_annotation.dart';

part 'tx_meta.g.dart';

@JsonSerializable(createToJson: false)
class TxMeta {
  TxMeta({
    this.err,
    required this.fee,
  });

  factory TxMeta.fromJson(Map<String, dynamic> json) => _$TxMetaFromJson(json);

  final Object? err;
  final int fee;

// TODO(KB): add other fields
}
