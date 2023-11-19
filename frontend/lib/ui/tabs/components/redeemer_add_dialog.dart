import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicef_aid_distributor/widgets/c_button.dart';
import 'package:web3dart/credentials.dart';

class RedeemerAddDialog extends StatelessWidget {
  final Function(String name, EthereumAddress address, BigInt amount) onAdd;
  RedeemerAddDialog({super.key, required this.onAdd});

  String name = "";
  String address = "";
  String amount = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add new approved redeemer"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              label: Text("Name"),
              hintText: "eg. Walmart"
            ),
            onChanged: (val) => name = val,
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    label: Text("Address"),
                    hintText: "eg. 0x12cad"
                  ),
                  onChanged: (val) => address = val,
                )
              ),
              const SizedBox(width: 10,),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    label: Text("Redeem amount / day"),
                    hintText: "eg. 145"
                  ),
                  onChanged: (val) => amount = val,
                )
              ),
            ],
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: (){
            Get.back();
          },
          child: const Text("Cancel"),
        ),
        CButton(
          onPressed: () async {
            var cancelLoad = BotToast.showLoading();
            await onAdd.call(name.trim(), EthereumAddress.fromHex(address.trim()), BigInt.parse(amount.trim()));
            cancelLoad();
            Get.back();
          },
          child: const Text("Confirm"),
        )
      ],
    );
  }
}
