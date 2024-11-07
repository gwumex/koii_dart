import 'package:koii/src/crypto/ed25519_hd_keypair.dart';
import 'package:koii/src/encoder/buffer.dart';
import 'package:koii/src/helpers.dart';
import 'package:koii/src/programs/associated_token_account_program/associated_token_account_program.dart';
import 'package:koii/src/programs/token_program/token_program.dart';

/// Represents a SPL token program
class SplToken {
  SplToken({
    required this.mint,
    required this.supply,
    required this.decimals,
    this.owner,
  });

  /// Compute and derive the associated token address of [owner]
  Future<String> computeAssociatedAddress({
    required String owner,
  }) =>
      findProgramAddress(
        seeds: [
          Buffer.fromBase58(owner),
          Buffer.fromBase58(TokenProgram.programId),
          Buffer.fromBase58(mint),
        ],
        programId: AssociatedTokenAccountProgram.programId,
      );

  final int decimals;
  final BigInt supply;
  final String mint;
  final Ed25519HDKeyPair? owner;
}
