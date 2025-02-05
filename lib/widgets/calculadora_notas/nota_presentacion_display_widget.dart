import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mi_utem/controllers/calculator_controller.dart';
import 'package:mi_utem/themes/theme.dart';
import 'package:mi_utem/utils/utils.dart';

class NotaPresentacionDisplayWidget extends StatelessWidget {
  const NotaPresentacionDisplayWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final _calculatorController = Get.find<CalculatorController>();
    return Row(
      children: [
        const Text("Pres.",
          style: TextStyle(fontSize: 16),
        ),
        Container(
          width: 80,
          margin: const EdgeInsets.only(left: 15),
          child: Obx(() => TextField(
            controller: TextEditingController(text: formatoNota(_calculatorController.calculatedPresentationGrade) ?? ""),
            textAlign: TextAlign.center,
            enabled: false,
            decoration: InputDecoration(
              hintText: "Nota",
              disabledBorder: MainTheme.theme.inputDecorationTheme.border!.copyWith(
                borderSide: const BorderSide(
                  color: Colors.transparent,
                ),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          )),
        ),
      ],
    );
  }
}
