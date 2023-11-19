import 'package:bot_toast/bot_toast.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:unicef_aid_distributor/config/network.dart';
import 'package:unicef_aid_distributor/contracts/bindings/ERC20.g.dart';
import 'package:unicef_aid_distributor/services/metamask_manager/metamask_manager.dart';
import 'package:unicef_aid_distributor/ui/tabs/components/distribution_add_dialog.dart';
import 'package:unicef_aid_distributor/utils/currency.dart';
import 'package:unicef_aid_distributor/utils/extensions/decimal_extensions.dart';
import 'package:unicef_aid_distributor/widgets/c_button.dart';
import 'package:web3dart/credentials.dart';

class DistributeTab extends StatefulWidget {
  const DistributeTab({super.key});

  @override
  State<DistributeTab> createState() => _DistributeTabState();
}

class _DistributeTabState extends State<DistributeTab> {
  bool loading = true;
  BigInt balance = BigInt.zero;
  List<_Distribution> distributions = [];

  void refreshBalance() async {
    setState(() {
      loading = true;
    });
    balance = await Network.instance.unicefVault.balanceOf(Network.instance.unicefVault.self.address);
    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  void distribute() async {
    var cancelLoad = BotToast.showLoading();
    var metamask = MetamaskManager.instance;
    var data = Network.instance.unicefVault.self.function("batchDistribute").encodeCall([distributions.map((e) => [e.receiver, e.amount]).toList()]);
    var from = (await metamask.getConnectedAccounts()).first;
    var result = await metamask.sendTransaction(
      Network.instance.unicefVault.self.address,
      from,
      data
    );
    cancelLoad();
    if (!mounted) return;
    setState(() {
      distributions.clear();
    });
  }

  @override
  void initState() {
    refreshBalance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (loading){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    var balanceFormatted = CurrencyUtils.formatUnits(balance, 18);
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Distribute", style: GoogleFonts.comfortaa(fontWeight: FontWeight.bold, fontSize: 35),),
              const SizedBox(width: 5,),
              IconButton(
                onPressed: (){
                  refreshBalance();
                },
                icon: Icon(PhosphorIcons.arrowClockwise(), size: 15,),
              ),
            ],
          ),
          Text("Balance: $balanceFormatted", style: GoogleFonts.comfortaa(fontWeight: FontWeight.bold, fontSize: 12),),
          const SizedBox(height: 15,),
          for (var distribution in distributions.toList())
            _DistributionEntry(
              distribution: distribution,
              onDelete: (){
                setState(() {
                  distributions.remove(distribution);
                });
              },
            ),
          const SizedBox(height: 25,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CButton(
                onPressed: (){
                  Get.dialog(DistributionAddDialog(
                    onAdd: (address, amount){
                      setState(() {
                        distributions.add(_Distribution(address, amount));
                      });
                    },
                  ));
                },
                child: const Text("Add"),
              ),
              const SizedBox(width: 10,),
              CButton(
                onPressed: distributions.isNotEmpty ? (){
                  distribute();
                } : null,
                child: const Text("Distribute"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DistributionEntry extends StatelessWidget {
  final _Distribution distribution;
  final VoidCallback onDelete;
  const _DistributionEntry({super.key, required this.distribution, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    var amountFormatted = CurrencyUtils.formatUnits(distribution.amount, 18);
    return ListTile(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
      ),
      tileColor: Get.theme.cardColor,
      title: Text(distribution.receiver.hexEip55),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(amountFormatted, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
          const SizedBox(width: 10,),
          IconButton(
            onPressed: (){
              onDelete.call();
            },
            icon: Icon(
              PhosphorIcons.trash(),
              size: 20,
            ),
          )
        ],
      ),
    );
  }
}


class _Distribution {
  EthereumAddress receiver;
  BigInt amount;
  _Distribution(this.receiver, this.amount);
}

