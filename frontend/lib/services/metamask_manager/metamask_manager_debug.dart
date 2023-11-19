import 'dart:typed_data';

import 'package:unicef_aid_distributor/config/network.dart';
import 'package:unicef_aid_distributor/services/metamask_manager/metamask_manager.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

MetamaskManager getMetamaskManager() => MetamaskManagerDebug.instance();

class MetamaskManagerDebug extends MetamaskManager {
  // final EthPrivateKey _privateKey = EthPrivateKey.fromHex("0xc12846094d4a27da3b951610e980b08f7bef50ef4ceeba9e308c8b4ebe2821e4"); // minter
  final EthPrivateKey _privateKey = EthPrivateKey.fromHex("0x6954bbbf3b4b4687114cfed6bf4eeafa57707cc542608afb3fcea9981ef9f070"); // owner
  bool _supported = true;
  EthereumAddress? account;
  static MetamaskManagerDebug? _instance;

  MetamaskManagerDebug._();

  static MetamaskManagerDebug instance(){
    if (_instance == null){
      _instance = MetamaskManagerDebug._();
      _instance!._supported = true;
    }
    return _instance!;
  }

  @override
  Future<bool> connect() async {
    account = _privateKey.address;
    return true;
  }

  @override
  Future<bool> isConnected() async {
    if (account != null) return true;
    return false;
  }

  @override
  Future<List<EthereumAddress>> getConnectedAccounts() async {
    if (account != null) return [account!];
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
    print(to);
    print(from);
    var result = await Network.instance.client.sendTransaction(
      _privateKey,
      Transaction(
        to: to,
        from: from,
        data: data,
        gasPrice: EtherAmount.fromInt(EtherUnit.gwei, 2),
        maxGas: 200000
      ),
      chainId: Network.instance.chainId
    );
    return result;
  }
}