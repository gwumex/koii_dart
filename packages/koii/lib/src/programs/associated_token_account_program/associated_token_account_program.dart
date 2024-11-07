import 'package:koii/src/encoder/message.dart';
import 'package:koii/src/programs/associated_token_account_program/associated_token_account_instruction.dart';

class AssociatedTokenAccountProgram extends Message {
  /// The [associated token account] program.
  ///
  /// The account will be associated to [mint] and have the associated token account [address].
  ///
  /// It will be owned by [owner] and funded by [funder].
  ///
  /// The [address] can be derived using [SplToken.computeAssociatedAddress].
  /// It is required here just to match the spl token program closely in terms of
  /// its API.
  ///
  /// If the [address] does not match the derived address, this method will fail.
  ///
  /// [associated token account]: https://spl.koii.com/associated-token-account
  AssociatedTokenAccountProgram({
    required String funder,
    required String address,
    required String owner,
    required String mint,
  }) : super(
          instructions: [
            AssociatedTokenAccountInstruction(
              funder: funder,
              address: address,
              owner: owner,
              mint: mint,
            )
          ],
        );

  static const programId = 'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL';
}
