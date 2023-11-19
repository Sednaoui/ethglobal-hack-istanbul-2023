import 'package:unicef_aid_distributor/contracts/bindings/UnicefVault.g.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;


class Network {
  int chainId;
  Web3Client client;
  UnicefVault unicefVault;
  static Network? _instance;

  Network(this.chainId, this.client, this.unicefVault);

  static Network get instance {
    if (_instance == null){
      var client = Web3Client("https://sepolia.infura.io/v3/3023ab01a95a40ba8387ae74932e2aaf", http.Client());
      _instance = Network(
        11155111,
        client,
        UnicefVault(address: EthereumAddress.fromHex("0xb49e977B198C4d8e6591Fc41f997C2d6a8adcF37"), client: client),
      );
    }
    return _instance!;
  }
}