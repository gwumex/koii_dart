import 'package:koii/src/rpc/dto/parsed_account_key.dart';
import 'package:koii/src/rpc/dto/raw_account_key.dart';

/// A commonly used object that stores a single [pubkey]
abstract class AccountKey {
  factory AccountKey.fromJson(dynamic json) {
    if (json is String) {
      return RawAccountKey(pubkey: json);
    } else {
      return ParsedAccountKey.fromJson(json as Map<String, dynamic>);
    }
  }

  abstract final String pubkey;
}
