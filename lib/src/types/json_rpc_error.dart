import 'package:json_annotation/json_annotation.dart';

part 'json_rpc_error.g.dart';

@JsonSerializable(createToJson: false)
class JsonRpcError extends Error {
  JsonRpcError(this.message, this.code, this.data);

  factory JsonRpcError.fromJson(Map<String, dynamic> json) =>
      _$JsonRpcErrorFromJson(json);

  final String message;
  final int code;

  // FIXME: data can be structured
  final dynamic data;

  @override
  String toString() => 'jsonrpc-2.0 error ($code): $message\n\t$data';
}