[![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)

Cryptoplease Dart Packages

This is a collection of packages necessary to build koii enabled applications in dart or flutter.

Currently it is composed of 2 packages,

- The Borsh serialization package which is itself divided in two packages [borsh](https://github.com/cryptoplease/cryptoplease-dart/tree/master/packages/borsh) and [borsh_annotation](https://github.com/cryptoplease/cryptoplease-dart/tree/master/packages/borsh_annotation). The former is a code generator that generates borsh serialization and deserialization for a Dart class. And the latter is an annotation used to annotate these classes.
- The [koii](https://github.com/cryptoplease/cryptoplease-dart/tree/master/packages/koii) library. This is the implementation of the koii [transaction codec](https://docs.koii.com/developing/programming-model/transactions) and the [JSON RPC api](https://docs.koii.com/developing/clients/jsonrpc-api).
