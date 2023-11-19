import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:unicef_aid_distributor/config/network.dart';
import 'package:unicef_aid_distributor/contracts/bindings/ERC20.g.dart';
import 'package:unicef_aid_distributor/contracts/bindings/UnicefVault.g.dart';
import 'package:unicef_aid_distributor/services/metamask_manager/metamask_manager.dart';
import 'package:unicef_aid_distributor/utils/currency.dart';
import 'package:unicef_aid_distributor/utils/extensions/decimal_extensions.dart';
import 'package:unicef_aid_distributor/utils/input_formatters.dart';
import 'package:unicef_aid_distributor/widgets/c_button.dart';
import 'package:web3dart/credentials.dart';

class DonationTab extends StatefulWidget {
  const DonationTab({super.key});

  @override
  State<DonationTab> createState() => _DonationTabState();
}

class _DonationTabState extends State<DonationTab> {
  Decimal value = Decimal.zero;
  BigInt accountAllowance = BigInt.zero;

  refreshAccountAllowance() async {
    var metamask = MetamaskManager.instance;
    var account = (await metamask.getConnectedAccounts()).first;
    var asset = await Network.instance.unicefVault.asset();
    var assetContract = ERC20(address: asset, client: Network.instance.client);
    accountAllowance = await assetContract.allowance(account, Network.instance.unicefVault.self.address);
    if (!mounted) return;
    setState(() {});
  }

  donate() async {
    var metamask = MetamaskManager.instance;
    var from = (await metamask.getConnectedAccounts()).first;
    var amount = CurrencyUtils.parseCurrency(value.toTrimmedStringAsFixed(18), 18);
    EthereumAddress to;
    Uint8List data;
    if (accountAllowance < amount){
      var asset = await Network.instance.unicefVault.asset();
      var assetContract = ERC20(address: asset, client: Network.instance.client);
      to = asset;
      data = assetContract.self.function("approve").encodeCall([Network.instance.unicefVault.self.address, amount]);
    }else{
      to = Network.instance.unicefVault.self.address;
      data = Network.instance.unicefVault.self.function("deposit").encodeCall([amount]);
    }
    var result = await metamask.sendTransaction(
      to,
      from,
      data
    );
    refreshAccountAllowance();
  }

  @override
  void initState() {
    refreshAccountAllowance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Column(
        children: [
          Text("Donation Amount", style: GoogleFonts.comfortaa(fontWeight: FontWeight.bold, fontSize: 35),),
          const SizedBox(height: 10,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    ThousandsFormatter(allowFraction: true)
                  ],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)
                    ),
                  ),
                  onChanged: (val){
                    setState(() {
                      value = Decimal.parse(val.trim().isEmpty ? "0" : val.replaceAll(",", ""));
                    });
                  },
                ),
              ),
              const SizedBox(width: 6,),
              Card(
                elevation: 10,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: const Text("\$")
                ),
              )
            ],
          ),
          const SizedBox(height: 15,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CButton(
                onPressed: value > Decimal.zero ? (){
                  donate();
                } : null,
                child: Text(
                  accountAllowance >= CurrencyUtils.parseCurrency(value.toTrimmedStringAsFixed(18), 18) ?
                    "Donate" : "Approve"
                ),
              ),
              const SizedBox(width: 5,),
              IconButton(
                onPressed: (){
                  refreshAccountAllowance();
                },
                icon: Icon(PhosphorIcons.arrowClockwise(), size: 15,),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
