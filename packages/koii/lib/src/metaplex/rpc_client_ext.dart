import 'package:koii/src/encoder/buffer.dart';
import 'package:koii/src/helpers.dart';
import 'package:koii/src/metaplex/metaplex.dart';
import 'package:koii/src/rpc/client.dart';
import 'package:koii/src/rpc/dto/account_data/binary_account_data.dart';
import 'package:koii/src/rpc/dto/encoding.dart';

extension GetMetaplexMetadata on RpcClient {
  Future<Metadata?> getMetadata({
    required String mint,
  }) async {
    final programAddress = await findProgramAddress(
      seeds: [
        'metadata'.codeUnits,
        Buffer.fromBase58(metaplexMetadataProgramId),
        Buffer.fromBase58(mint),
      ],
      programId: metaplexMetadataProgramId,
    );
    final account = await getAccountInfo(
      programAddress,
      encoding: Encoding.base64,
    );
    if (account == null) {
      return null;
    }

    final data = account.data;

    if (data is BinaryAccountData) {
      return Metadata.fromBinary(data.data);
    } else {
      return null;
    }
  }
}
