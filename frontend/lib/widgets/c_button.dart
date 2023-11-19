import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  const CButton({Key? key, this.onPressed, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        // backgroundColor: MaterialStatePropertyAll(Get.theme.colorScheme.primary),
        backgroundColor: MaterialStateProperty.resolveWith((states){
          if (states.contains(MaterialState.disabled)) return null;
          return Get.theme.colorScheme.primary;
        }),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: Get.theme.colorScheme.surface),
        child: child
      )
    );
  }
}
