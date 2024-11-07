import 'dart:convert';

import 'package:koii/src/common/byte_array.dart';
import 'package:koii/src/encoder/buffer.dart';
import 'package:koii/src/encoder/compact_array.dart';
import 'package:koii/src/encoder/signature.dart';

/// Represents a signed transaction that consists of the transaction
/// message and an array of signatures. The array of signatures must
/// be populated following the koii convention for the set of addresses
/// that they belong to within the message.
class SignedTx extends ByteArray {
  SignedTx({
    this.signatures = const Iterable<Signature>.empty(),
    required this.messageBytes,
  });

  final Iterable<Signature> signatures;
  final ByteArray messageBytes;

  String encode() => base64.encode(toList(growable: false));

  @override
  Iterator<int> get iterator => _data.iterator;

  late final ByteArray _data = Buffer.fromConcatenatedByteArrays([
    CompactArray.fromIterable(signatures),
    messageBytes,
  ]);
}
