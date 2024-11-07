import 'package:koii/src/encoder/message.dart';
import 'package:koii/src/programs/memo_program/memo_instruction.dart';

export 'package:koii/src/programs/memo_program/memo_instruction.dart';

/// The memo program from the SPL
class MemoProgram extends Message {
  /// Construct a [memo program][memo program] with [signers] and [memo].
  ///
  /// [memo program]: https://spl.koii.com/memo
  ///
  /// Please note that there's a limit on the length of the [memo] string, which
  /// otherwise is an arbitrary string of utf-8 data.
  ///
  /// The limit as [specified in this document][memo limit] is 566 bytes.
  ///
  /// [memo limit](https://spl.koii.com/memo#compute-limits)
  MemoProgram({
    required List<String> signers,
    required String memo,
  }) : super(
          instructions: [
            MemoInstruction(
              signers: signers,
              memo: memo,
            )
          ],
        );

  static const programId = 'MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr';
}
