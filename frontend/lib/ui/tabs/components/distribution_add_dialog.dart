import 'package:bot_toast/bot_toast.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicef_aid_distributor/utils/currency.dart';
import 'package:unicef_aid_distributor/utils/extensions/decimal_extensions.dart';
import 'package:unicef_aid_distributor/widgets/c_button.dart';
import 'package:web3dart/web3dart.dart';

class DistributionAddDialog extends StatelessWidget {
  final Function(EthereumAddress address, BigInt amount) onAdd;
  DistributionAddDialog({super.key, required this.onAdd});

  String address = "";
  String amount = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add recipient"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: const InputDecoration(
                label: Text("Address"),
                hintText: "eg. 0x12cad"
            ),
            onChanged: (val) => address = val,
          ),
          TextFormField(
            decoration: const InputDecoration(
              label: Text("Amount"),
              hintText: "eg. 145"
            ),
            onChanged: (val) => amount = val,
          ),
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
            onAdd.call(
              EthereumAddress.fromHex(address),
              CurrencyUtils.parseCurrency(Decimal.parse(amount).toTrimmedStringAsFixed(18), 18)
            );
            Get.back();
          },
          child: const Text("Add"),
        )
      ],
    );
  }
}
