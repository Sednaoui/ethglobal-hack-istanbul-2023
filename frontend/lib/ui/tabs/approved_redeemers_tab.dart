import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:unicef_aid_distributor/config/network.dart';
import 'package:unicef_aid_distributor/services/metamask_manager/metamask_manager.dart';
import 'package:unicef_aid_distributor/ui/tabs/components/redeemer_add_dialog.dart';
import 'package:unicef_aid_distributor/widgets/c_button.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

class ApprovedRedeemersTab extends StatefulWidget {
  const ApprovedRedeemersTab({super.key});

  @override
  State<ApprovedRedeemersTab> createState() => _ApprovedRedeemersTabState();
}

class _ApprovedRedeemersTabState extends State<ApprovedRedeemersTab> {
  bool loading = true;
  Set<_Redeemer> approvedRedeemers = {};

  void refreshApprovedRedeemers() async {
    setState(() {
      loading = true;
    });
    List<FilterEvent> events = await Network.instance.client.getLogs(FilterOptions(
        fromBlock: const BlockNum.exact(4721396),
        toBlock: const BlockNum.current(),
        address: Network.instance.unicefVault.self.address,
        topics: [
          ["0xf236450fb69890ddf057cae7305afeae8ed1d676d79e7958cdc31fd2e33df2c3"],
          [],
        ]
    ));
    approvedRedeemers.clear();
    final contractEvent = Network.instance.unicefVault.self.event('MaxRedeemChanged');
    for (var event in events){
      final decoded = contractEvent.decodeResults(
        event.topics!,
        event.data!,
      );
      approvedRedeemers.add(_Redeemer(decoded[0], decoded[1]));
    }
    setState(() {
      loading = false;
    });
  }

  void addRedeemer(String name, EthereumAddress redeemer, BigInt maxAmount) async {
    var metamask = MetamaskManager.instance;
    var data = Network.instance.unicefVault.self.function("setMaxDailyRedeemAmount").encodeCall([redeemer, maxAmount]);
    var from = (await metamask.getConnectedAccounts()).first;
    if (name.trim().isNotEmpty){
      Hive.box<String>("redeemers:names").put(redeemer.hex, name);
    }
    var result = await metamask.sendTransaction(
      Network.instance.unicefVault.self.address,
      from,
      data
    );
    refreshApprovedRedeemers();
  }

  @override
  void initState() {
    refreshApprovedRedeemers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (loading){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, top: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Approved Redeemers", style: GoogleFonts.comfortaa(fontWeight: FontWeight.bold, fontSize: 35),),
                const SizedBox(width: 5,),
                IconButton(
                  onPressed: (){
                    refreshApprovedRedeemers();
                  },
                  icon: Icon(PhosphorIcons.arrowClockwise(), size: 15,),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            for (var redeemer in approvedRedeemers.toList())
              _ApprovedRedeemerEntry(redeemer: redeemer,),
            const SizedBox(height: 25,),
            CButton(
              onPressed: (){
                Get.dialog(RedeemerAddDialog(
                  onAdd: addRedeemer
                ));
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }
}


class _ApprovedRedeemerEntry extends StatelessWidget {
  final _Redeemer redeemer;
  const _ApprovedRedeemerEntry({super.key, required this.redeemer});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      tileColor: Get.theme.cardColor,
      title: Text(redeemer.name ?? redeemer.address.hexEip55),
      subtitle: redeemer.name == null ? null : Text(redeemer.address.hexEip55),
      trailing: Text(redeemer.amount.toString()),
    );
  }
}

class _Redeemer {
  EthereumAddress address;
  BigInt amount;
  String? name;
  _Redeemer(this.address, this.amount){
    name = Hive.box<String>("redeemers:names").get(address.hex);
  }
}