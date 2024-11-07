import 'dart:typed_data';

import 'package:borsh_annotation/borsh_annotation.dart';
import 'package:koii/anchor.dart';
import 'package:koii/dto.dart';

part 'basic1.g.dart';

class Basic1DataAccount implements AnchorAccount {
  const Basic1DataAccount._({
    required this.discriminator,
    required this.data,
  });

  factory Basic1DataAccount._fromBinary(
    List<int> bytes,
  ) {
    final accountData = _AccountData.fromBorsh(bytes.sublist(8));
    return Basic1DataAccount._(
      discriminator: bytes.sublist(0, 8),
      data: accountData.data,
    );
  }

  factory Basic1DataAccount.fromAccountData(AccountData accountData) {
    if (accountData is BinaryAccountData) {
      return Basic1DataAccount._fromBinary(accountData.data);
    } else {
      throw const FormatException('invalid account data found');
    }
  }

  @override
  final List<int> discriminator;

  final int data;
}

@Struct(createToBorsh: false)
class _AccountData {
  _AccountData({required this.data});

  factory _AccountData.fromBorsh(List<int> data) =>
      __AccountDataFromBorsh(data);

  @u64
  final int data;
}

@Struct(createFromBorsh: false)
class Basic1Arguments extends BorshStruct {
  const Basic1Arguments({required this.data});

  @override
  List<int> toBorsh() => _Basic1ArgumentsToBorsh(this);

  @u64
  final int data;
}
