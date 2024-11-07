import 'package:koii/src/rpc/dto/account_key.dart';

class RawAccountKey implements AccountKey {
  const RawAccountKey({
    required this.pubkey,
  });

  final String pubkey;
}
