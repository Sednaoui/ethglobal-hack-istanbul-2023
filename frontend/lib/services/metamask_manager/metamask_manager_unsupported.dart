import 'dart:typed_data';

import 'package:unicef_aid_distributor/services/metamask_manager/metamask_manager.dart';
import 'package:web3dart/web3dart.dart';

MetamaskManager getMetamaskManager() =>
    throw UnsupportedError('Cannot create a metamask manager');

class MetamaskManagerUnsupported extends MetamaskManager {

  @override
  Future<List<EthereumAddress>> getConnectedAccounts() {
    throw UnimplementedError();
  }

  @override
  Future<bool> connect() async {
    throw UnimplementedError();
  }

  @override
  Future<bool> isConnected() {
    throw UnimplementedError();
  }

  @override
  Future<String?> personalSign(String message) {
    throw UnimplementedError();
  }

  @override
  Future<String?> signTypedData(Map<String, dynamic> message) {
    throw UnimplementedError();
  }

  @override
  Future<String?> sendTransaction(EthereumAddress to, EthereumAddress from, Uint8List data) async {
    throw UnimplementedError();
  }

}