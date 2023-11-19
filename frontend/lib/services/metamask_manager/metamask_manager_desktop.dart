import 'dart:typed_data';

import 'package:unicef_aid_distributor/services/metamask_manager/metamask_manager.dart';
import 'package:web3dart/web3dart.dart';

MetamaskManager getMetamaskManager() => MetamaskManagerDesktop.instance();

class MetamaskManagerDesktop extends MetamaskManager {
  bool _supported = false;
  static MetamaskManagerDesktop? _instance;

  MetamaskManagerDesktop._();

  static MetamaskManagerDesktop instance(){
    if (_instance == null){
      _instance = MetamaskManagerDesktop._();
      _instance!._supported = false;
    }
    return _instance!;
  }

  @override
  Future<bool> connect() async {
    return false;
  }

  @override
  Future<bool> isConnected() async {
    return false;
  }

  @override
  Future<List<EthereumAddress>> getConnectedAccounts() async {
    return [];
  }

  @override
  Future<String?> personalSign(String message) async {
    return null;
  }

  @override
  Future<String?> signTypedData(Map<String, dynamic> message) async {
    return null;
  }

  @override
  Future<String?> sendTransaction(EthereumAddress to, EthereumAddress from, Uint8List data) async {
    return null;
  }
}