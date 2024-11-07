import 'package:koii/dto.dart' hide Instruction;
import 'package:koii/encoder.dart';
import 'package:koii/koii.dart';
import 'package:test/test.dart';

import 'config.dart';

void main() {
  group('KoiiClient for SPL tokens', () {
    late final String newTokenMint;
    late final Ed25519HDKeyPair owner;
    late final KoiiClient koiiClient;

    setUpAll(() async {
      koiiClient = createTestKoiiClient();
      owner = await Ed25519HDKeyPair.random();
      await koiiClient.requestAirdrop(
        lamports: 100 * lamportsPerSol,
        address: owner.address,
      );
    });

    test('Create a new mint', () async {
      final token = await koiiClient.initializeMint(
        owner: owner,
        decimals: 2,
      );

      expect(token.supply, equals(BigInt.zero));
      expect(token.decimals, equals(2));

      newTokenMint = token.mint;
    });

    test(
      'Create an account with',
      () async {
        final creator = await Ed25519HDKeyPair.random();
        final account = await Ed25519HDKeyPair.random();
        await koiiClient.requestAirdrop(
          lamports: 100 * lamportsPerSol,
          address: creator.address,
        );
        await koiiClient.createTokenAccount(
          account: account,
          creator: creator,
          mint: newTokenMint,
        );
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test('Create an associated token account', () async {
      var accounts = await koiiClient.rpcClient.getTokenAccountsByOwner(
        owner.address,
        TokenAccountsFilter.byMint(newTokenMint),
      );
      expect(accounts, isNot(null));
      expect(accounts.length, equals(0));

      final newAccount = await koiiClient.createAssociatedTokenAccount(
        funder: owner,
        mint: newTokenMint,
      );

      accounts = await koiiClient.rpcClient.getTokenAccountsByOwner(
        owner.address,
        TokenAccountsFilter.byMint(newTokenMint),
        encoding: Encoding.jsonParsed,
      );
      expect(accounts, isNot(null));
      expect(accounts.length, equals(1));
      expect(
        accounts.where((a) => a.pubkey == newAccount.pubkey),
        isNot(null),
      );
    });

    test('Mint the newly created token and account', () async {
      final accounts = await koiiClient.rpcClient.getTokenAccountsByOwner(
        owner.address,
        TokenAccountsFilter.byMint(newTokenMint),
        encoding: Encoding.jsonParsed,
      );
      await koiiClient.transferMint(
        destination: accounts.first.pubkey,
        amount: _totalSupply,
        mint: newTokenMint,
        owner: owner,
      );

      final token = await koiiClient.createReadWriteToken(
        owner: owner,
        mint: newTokenMint,
      );

      expect(token.supply, equals(BigInt.from(_totalSupply)));
      expect(token.decimals, equals(2));
    });

    test('Get spl_token supply', () async {
      final TokenAmount tokenSupply =
          await koiiClient.rpcClient.getTokenSupply(newTokenMint);

      expect(int.parse(tokenSupply.amount), equals(_totalSupply));
    });

    test(
      'Transfer tokens succeeds when associated accounts exist',
      () async {
        final recipient = await Ed25519HDKeyPair.random();
        // The account does not exist, so create it
        final account = await koiiClient.createAssociatedTokenAccount(
          owner: recipient.address,
          funder: owner,
          mint: newTokenMint,
        );
        expect(account, isA<ProgramAccount>());
        // Send to the newly created account
        final signature = await koiiClient.transferSplToken(
          source: owner,
          destination: recipient.address,
          amount: 100,
          mint: newTokenMint,
        );

        expect(signature, isNot(null));
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'Transfer tokens succeeds with fee payer',
      () async {
        final recipient = await Ed25519HDKeyPair.random();
        final feePayer = await Ed25519HDKeyPair.random();
        // Add some tokens to pay for fees
        await koiiClient.requestAirdrop(
          lamports: 100 * lamportsPerSol,
          address: feePayer.address,
        );

        // The account does not exist, so create it
        final account = await koiiClient.createAssociatedTokenAccount(
          owner: recipient.address,
          funder: owner,
          mint: newTokenMint,
        );
        // A sender must have the appropriate associated account, in case they
        // don't it's an error and we should throw an exception.
        final sourceAssociatedTokenAddress =
            await koiiClient.getAssociatedTokenAccount(
          mint: newTokenMint,
          owner: owner.address,
        );
        // A recipient needs an associated account as well
        final destinationAssociatedTokenAddress =
            await koiiClient.getAssociatedTokenAccount(
          mint: newTokenMint,
          owner: recipient.address,
        );
        expect(sourceAssociatedTokenAddress, isNotNull);
        expect(destinationAssociatedTokenAddress, isNotNull);

        expect(account, isA<ProgramAccount>());
        // Send to the newly created account
        final message = TokenProgram.transfer(
          source: sourceAssociatedTokenAddress!.pubkey,
          destination: destinationAssociatedTokenAddress!.pubkey,
          amount: 100,
          owner: owner.address,
        );

        final signature = await koiiClient.rpcClient.signAndSendTransaction(
          message,
          [feePayer, owner],
        );
        await koiiClient.waitForSignatureStatus(
          signature,
          status: ConfirmationStatus.finalized,
        );

        expect(signature, isNot(null));
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
        'Fails to transfer tokens if the recipient has no associated token account',
        () async {
      final recipient = await Ed25519HDKeyPair.random();
      // Send to the newly created account
      expect(
        koiiClient.transferSplToken(
          source: owner,
          destination: recipient.address,
          amount: 100,
          mint: newTokenMint,
        ),
        throwsA(isA<NoAssociatedTokenAccountException>()),
      );
    });

    test(
      'Fails to transfer tokens if the sender has no associated token account',
      () async {
        final sender = await Ed25519HDKeyPair.random();
        // Send to the newly created account
        expect(
          koiiClient.transferSplToken(
            source: sender,
            destination: owner.address,
            amount: 100,
            mint: newTokenMint,
          ),
          throwsA(isA<NoAssociatedTokenAccountException>()),
        );
      },
    );

    test(
      'Send transfer instruction in an existing transaction',
      () async {
        final destination = await Ed25519HDKeyPair.random();
        final token = await koiiClient.createReadonlyToken(
          mint: newTokenMint,
        );
        final associatedSourceAddress =
            await token.computeAssociatedAddress(owner: owner.address);
        final destinationAccount = await koiiClient.createTokenAccount(
          account: destination,
          creator: owner,
          mint: token.mint,
        );

        final instructions = <Instruction>[
          SystemInstruction.transfer(
            source: owner.address,
            destination: destination.address,
            lamports: lamportsPerSol,
          ),
          TokenInstruction.transfer(
            source: associatedSourceAddress,
            destination: destinationAccount.owner,
            owner: owner.address,
            amount: 10,
          ),
          MemoInstruction(
            memo: 'Nice, it works with many more instructions too',
            signers: [owner.address],
          ),
        ];
        final message = Message(instructions: instructions);

        final signature =
            await koiiClient.rpcClient.signAndSendTransaction(message, [owner]);
        await koiiClient.waitForSignatureStatus(
          signature,
          status: ConfirmationStatus.finalized,
        );
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });
}

const _totalSupply = 1000000000000;
