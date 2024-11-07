import 'package:koii/dto.dart';
import 'package:koii/koii.dart';
import 'package:test/test.dart';

import 'config.dart';

void main() {
  late final KoiiClient koiiClient;
  late final Wallet source;
  late final Wallet destination;
  late SplToken token;

  setUpAll(() async {
    source = await Ed25519HDKeyPair.random();
    koiiClient = createTestKoiiClient();
    destination = await Ed25519HDKeyPair.random();
    // Add tokens to the sender
    await koiiClient.requestAirdrop(
      lamports: 100 * lamportsPerSol,
      address: source.address,
    );
    token = await koiiClient.initializeMint(
      owner: source,
      decimals: 2,
    );
    final associatedAccount = await koiiClient.createAssociatedTokenAccount(
      mint: token.mint,
      funder: source,
    );
    await koiiClient.transferMint(
      destination: associatedAccount.pubkey,
      amount: _tokenMintAmount,
      mint: token.mint,
      owner: source,
    );
  });

  test('Get wallet lamports', () async {
    expect(
      await koiiClient.rpcClient.getBalance(source.address),
      greaterThan(0),
    );
  });

  test('Transfer SOL', () async {
    final signature = await koiiClient.transferLamports(
      destination: destination.address,
      lamports: lamportsPerSol,
      source: source,
    );
    expect(signature, isNotNull);
    expect(
      await koiiClient.rpcClient.getBalance(destination.address),
      equals(lamportsPerSol),
    );
  });

  test('Transfer SOL with memo', () async {
    const memoText = 'Memo test string...';

    final signature = await koiiClient.transferLamports(
      destination: destination.address,
      lamports: _lamportsTransferAmount,
      memo: memoText,
      source: source,
    );
    expect(signature, isNotNull);

    // FIXME: check that it actual is this type
    final result = await koiiClient.rpcClient.getTransaction(
      signature.toString(),
      encoding: Encoding.jsonParsed,
    );

    expect(result, isNotNull);
    expect(result?.transaction, isNotNull);
    final transaction = result!.transaction;
    expect(transaction.message, isNotNull);
    final txMessage = transaction.message;
    expect(txMessage.instructions, isNotNull);
    final instructions = txMessage.instructions;
    expect(instructions.length, equals(2));
    expect(instructions[0], const TypeMatcher<ParsedInstructionSystem>());
    final parsedInstructionSystem = instructions[0] as ParsedInstructionSystem;
    expect(
        parsedInstructionSystem.parsed, isA<ParsedSystemTransferInstruction>());
    final parsedTransferInstruction =
        parsedInstructionSystem.parsed as ParsedSystemTransferInstruction;
    expect(parsedTransferInstruction.info.lamports,
        equals(_lamportsTransferAmount));
    expect(instructions[1], const TypeMatcher<ParsedInstructionMemo>());
    final memoInstruction = instructions[1] as ParsedInstructionMemo;
    expect(memoInstruction.memo, equals(memoText));
  });

  test(
    'Get a token balance',
    () async {
      final wallet = await Ed25519HDKeyPair.random();
      expect(
        koiiClient.hasAssociatedTokenAccount(
          mint: token.mint,
          owner: wallet.address,
        ),
        completion(equals(false)),
      );

      final signature = await koiiClient.requestAirdrop(
        lamports: lamportsPerSol,
        commitment: Commitment.finalized,
        address: wallet.address,
      );
      expect(signature, isNotNull);
      expect(
        await koiiClient.rpcClient.getBalance(wallet.address),
        equals(lamportsPerSol),
      );

      await koiiClient.createAssociatedTokenAccount(
        mint: token.mint,
        funder: wallet,
      );
      final hasAssociatedTokenAccount =
          await koiiClient.hasAssociatedTokenAccount(
        mint: token.mint,
        owner: wallet.address,
      );

      expect(hasAssociatedTokenAccount, equals(true));

      final tokenBalance = await koiiClient.getTokenBalance(
        mint: token.mint,
        owner: wallet.address,
      );
      expect(tokenBalance.decimals, equals(token.decimals));
      expect(tokenBalance.amount, equals('0'));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'Fails SPL transfer if recipient has no associated token account',
    () async {
      final wallet = await Ed25519HDKeyPair.random();
      expect(
        koiiClient.transferSplToken(
          destination: wallet.address,
          amount: 100,
          mint: token.mint,
          source: source,
        ),
        throwsA(isA<NoAssociatedTokenAccountException>()),
      );
    },
  );

  test(
    'Transfer SPL tokens successfully',
    () async {
      final wallet = await Ed25519HDKeyPair.random();
      await koiiClient.createAssociatedTokenAccount(
        mint: token.mint,
        funder: source,
        owner: wallet.address,
      );
      final signature = await koiiClient.transferSplToken(
        destination: wallet.address,
        amount: 40,
        mint: token.mint,
        source: source,
      );
      expect(signature, isNotNull);

      final tokenBalance = await koiiClient.getTokenBalance(
        mint: token.mint,
        owner: wallet.address,
      );
      expect(tokenBalance.amount, equals('40'));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'Transfer SPL tokens with memo',
    () async {
      final wallet = await Ed25519HDKeyPair.random();
      // Create the associated account for the recipient
      await koiiClient.createAssociatedTokenAccount(
        mint: token.mint,
        funder: source,
        owner: wallet.address,
      );
      const memoText = 'Memo test string...';

      final signature = await koiiClient.transferSplToken(
        mint: token.mint,
        destination: wallet.address,
        amount: 40,
        memo: memoText,
        source: source,
      );
      expect(signature, isNotNull);

      // FIXME: check that this is of the correct type
      final result = await koiiClient.rpcClient.getTransaction(
        signature.toString(),
        encoding: Encoding.jsonParsed,
      );

      expect(result, isNotNull);
      expect(result?.transaction, isNotNull);
      final transaction = result!.transaction;
      expect(transaction.message, isNotNull);
      final txMessage = transaction.message;
      expect(txMessage.instructions, isNotNull);
      final instructions = txMessage.instructions;
      expect(instructions.length, equals(2));
      expect(instructions[0], const TypeMatcher<ParsedInstructionSplToken>());
      expect(instructions[1], const TypeMatcher<ParsedInstructionMemo>());
      final memoInstruction = instructions[1] as ParsedInstructionMemo;
      expect(memoInstruction.memo, equals(memoText));
      final splTokenInstruction = instructions[0] as ParsedInstructionSplToken;
      expect(
          splTokenInstruction.parsed, isA<ParsedSplTokenTransferInstruction>());
      final parsedSplTokenInstruction =
          splTokenInstruction.parsed as ParsedSplTokenTransferInstruction;
      expect(parsedSplTokenInstruction.type, equals('transfer'));
      expect(parsedSplTokenInstruction.info, isA<SplTokenTransferInfo>());
      expect(parsedSplTokenInstruction.info.amount, '40');
      final tokenBalance = await koiiClient.getTokenBalance(
        mint: token.mint,
        owner: wallet.address,
      );
      expect(tokenBalance.amount, equals('40'));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

const _tokenMintAmount = 1000;
const _lamportsTransferAmount = 5 * lamportsPerSol;
