import 'package:convert/convert.dart';

const int _bitsPerByte = 8;
const int _hexCharsPerByte = 2;

String _padTo(String what, String character, int length) =>
    what.padLeft(length, character);

List<int> encodeInt(int value, [int bitSize = 8]) {
  final String padded = _padTo(
    value.toRadixString(16),
    '0',
    _hexCharsPerByte * bitSize ~/ _bitsPerByte,
  );
  final List<int> be = hex.decode(padded);
  // Convert to LE
  return List.from(be.reversed);
}