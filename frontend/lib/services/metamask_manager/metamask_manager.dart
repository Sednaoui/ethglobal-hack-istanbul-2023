import 'dart:typed_data';

import 'package:web3dart/web3dart.dart';

import 'metamask_manager_unsupported.dart'
if (dart.library.io) 'metamask_manager_debug.dart'
if (dart.library.html) 'metamask_manager_web.dart';

abstract class MetamaskManager {
  static MetamaskManager? _instance;

  static MetamaskManager get instance {
    _instance ??= getMetamaskManager();
    return _instance!;
  }

  Future<bool> connect();

  Future<bool> isConnected();

  Future<List<EthereumAddress>> getConnectedAccounts();

  Future<String?> personalSign(String message);

  Future<String?> signTypedData(Map<String, dynamic> message);

  Future<String?> sendTransaction(EthereumAddress to, EthereumAddress from, Uint8List data);
}