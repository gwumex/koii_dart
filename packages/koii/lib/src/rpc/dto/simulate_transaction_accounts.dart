import 'package:json_annotation/json_annotation.dart';
import 'package:koii/src/rpc/dto/encoding.dart';

part 'simulate_transaction_accounts.g.dart';

/// Accounts for a transaction simulation
@JsonSerializable(includeIfNull: false)
class SimulateTransactionAccounts {
  const SimulateTransactionAccounts({
    this.accountEncoding,
    this.addresses,
  });

  factory SimulateTransactionAccounts.fromJson(Map<String, dynamic> json) =>
      _$SimulateTransactionAccountsFromJson(json);

  final Encoding? accountEncoding;

  /// An array of accounts to return, as base-58 encoded strings
  final List<String>? addresses;

  Map<String, dynamic> toJson() => _$SimulateTransactionAccountsToJson(this);
}
