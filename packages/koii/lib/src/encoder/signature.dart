import 'package:cryptography/cryptography.dart' as crypto;
import 'package:koii/src/base58/encode.dart';
import 'package:koii/src/common/byte_array.dart';

class Signature extends ByteArray {
  Signature.from(crypto.Signature signature) : _data = signature.bytes;

  final ByteArray _data;

  String toBase58() => base58encode(_data.toList(growable: false));

  @override
  Iterator<int> get iterator => _data.iterator;
}
