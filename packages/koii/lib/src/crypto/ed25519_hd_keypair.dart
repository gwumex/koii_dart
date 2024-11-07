import 'dart:math';

import 'package:bip39/bip39.dart' as bip39;
import 'package:cryptography/cryptography.dart'
    show Ed25519, KeyPair, KeyPairType, SimpleKeyPairData, SimplePublicKey;
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:koii/src/base58/encode.dart';
import 'package:koii/src/encoder/message.dart';
import 'package:koii/src/encoder/signature.dart';
import 'package:koii/src/encoder/signed_tx.dart';

/// Signs koii transactions using the ed25519 elliptic curve
class Ed25519HDKeyPair extends KeyPair {
  Ed25519HDKeyPair._({
    required List<int> privateKey,
    required List<int> publicKey,
  })  : _privateKey = privateKey,
        _publicKey = publicKey,
        // We pre-compute this in order to avoid doing it
        // over and over because it's needed often.
        address = base58encode(publicKey);

  /// Construct a new [Ed25519HDKeyPair] from a [seed] and a derivation path [hdPath].
  static Future<Ed25519HDKeyPair> fromSeedWithHdPath({
    required List<int> seed,
    required String hdPath,
  }) async {
    final KeyData _keyData = await ED25519_HD_KEY.derivePath(hdPath, seed);

    return Ed25519HDKeyPair._(
      privateKey: _keyData.key,
      publicKey: await ED25519_HD_KEY.getPublicKey(_keyData.key, false),
    );
  }

  static Future<Ed25519HDKeyPair> fromPrivateKeyBytes({
    required List<int> privateKey,
  }) async =>
      Ed25519HDKeyPair._(
        privateKey: privateKey,
        publicKey: await ED25519_HD_KEY.getPublicKey(privateKey, false),
      );

  /// Generate a new random [Ed25519HDKeyPair]
  static Future<Ed25519HDKeyPair> random() async {
    final random = (int _) => _random.nextInt(256);
    // Create the seed
    final List<int> seedBytes = List<int>.generate(32, random);
    // final PublicKey publicKey = await keyPair.extractPublicKey();
    // Finally, create a new wallet
    return Ed25519HDKeyPair.fromSeedWithHdPath(
      seed: seedBytes,
      hdPath: "m/44'/501'/0'/0'",
    );
  }

  /// Creates and initializes the [account]th KoiiWallet and the
  /// [change]th account for the given bip39 [mnemonic] string of
  /// 12 words.
  ///
  /// Omitting [account] or [change] means they will be `null`
  /// with the following rules of the meaning of `null` in this context.
  ///
  /// If either [account] or [change] is `null`, and the other
  /// is not, then it will be taken to be zero.
  ///
  /// If [account] and [change] are both `null`, then we derive
  /// the address that would be returned by using
  ///
  ///     koii-keygen pubkey prompt://
  ///
  /// and passing the [mnemonic] seed phrase
  static Future<Ed25519HDKeyPair> fromMnemonic(
    String mnemonic, {
    int account = 0,
    int change = 0,
  }) async {
    final List<int> seed = bip39.mnemonicToSeed(mnemonic);
    return Ed25519HDKeyPair.fromSeedWithHdPath(
      seed: seed,
      hdPath: _getHDPath(account, change),
    );
  }

  /// Sign a koii program message
  Future<SignedTx> signMessage({
    required Message message,
    // FIXME: should be string (no knowledge of these structures is needed here)
    required String recentBlockhash,
  }) async {
    final compiledMessage = message.compile(
      recentBlockhash: recentBlockhash,
      feePayer: address,
    );
    final signature = await sign(compiledMessage.data);

    return SignedTx(
      signatures: [signature],
      messageBytes: compiledMessage.data,
    );
  }

  @override
  Future<SimpleKeyPairData> extract() async => SimpleKeyPairData(
        _privateKey,
        publicKey: await extractPublicKey(),
        type: KeyPairType.ed25519,
      );

  @override
  Future<SimplePublicKey> extractPublicKey() => Future<SimplePublicKey>.value(
        SimplePublicKey(_publicKey, type: KeyPairType.ed25519),
      );

  /// Returns a Future that resolves to the result of signing
  /// [data] with the private key held internally by a given
  /// instance
  Future<Signature> sign(Iterable<int> data) async => Signature.from(
        await _ed25519.sign(data.toList(growable: false), keyPair: this),
      );

  /// Build a derivation path with [account] and [change]
  static String _getHDPath(int account, int change) =>
      "m/44'/501'/$account'/$change'";

  /// The address or public key of this wallet
  static final _ed25519 = Ed25519();

  final List<int> _privateKey;
  final List<int> _publicKey;
  final String address;
}

final _random = Random.secure();
