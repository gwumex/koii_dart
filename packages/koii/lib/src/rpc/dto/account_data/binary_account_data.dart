import 'package:koii/src/rpc/dto/account_data/account_data.dart';

class BinaryAccountData implements AccountData {
  const BinaryAccountData(this.data);

  final List<int> data;
}
