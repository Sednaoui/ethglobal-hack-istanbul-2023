import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_web3/flutter_web3.dart';
import 'package:unicef_aid_distributor/services/metamask_manager/metamask_manager.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

MetamaskManager getMetamaskManager() => MetamaskManagerWeb.instance();

class MetamaskManagerWeb extends MetamaskManager {
  bool _supported = false;
  static MetamaskManagerWeb? _instance;

  MetamaskManagerWeb._();

  static MetamaskManagerWeb instance(){
    if (_instance == null){
      _instance = MetamaskManagerWeb._();
      _instance!._supported = Ethereum.isSupported;
    }
    return _instance!;
  }

  @override
  Future<bool> connect() async {
    if (!_supported) return false;
    var accounts = await ethereum!.requestAccount();
    return accounts.isNotEmpty;
  }

  @override
  Future<bool> isConnected() async {
    if (!_supported) return false;
    return ethereum!.isConnected() && (await ethereum!.getAccounts()).isNotEmpty;
  }

  @override
  Future<List<EthereumAddress>> getConnectedAccounts() async {
    if (!_supported) return [];
    var accounts = await ethereum!.getAccounts();
    return accounts.map((e) => EthereumAddress.fromHex(e)).toList();
  }

  @override
  Future<String?> personalSign(String message) async {
    var accounts = await getConnectedAccounts();
    if (accounts.isEmpty) return null;
    var signature = await ethereum!.request("personal_sign", [message, accounts.first.hexEip55]);
    return signature;
  }

  @override
  Future<String?> signTypedData(Map<String, dynamic> message) async {
    var accounts = await getConnectedAccounts();
    if (accounts.isEmpty) return null;
    var signature = await ethereum!.request("eth_signTypedData_v4", [accounts.first.hexEip55, jsonEncode(message)]);
    return signature;
  }

  @override
  Future<String?> sendTransaction(EthereumAddress to, EthereumAddress from, Uint8List data) async {
    var signature = await ethereum!.request("eth_sendTransaction", [TransactionRequest(
      from: from.hex,
      to: to.hex,
      data: bytesToHex(data, include0x: true);
    )]);
    return signature;
  }
}