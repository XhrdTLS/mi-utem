
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mi_utem/widgets/acerca/club/acerca_app.dart';
import 'package:mi_utem/widgets/acerca/club/acerca_club.dart';
import 'package:mi_utem/widgets/acerca/club/acerca_club_desarrolladores.dart';
import 'package:mi_utem/widgets/acerca/dialog/acerca_aplicacion_content.dart';
import 'package:mi_utem/widgets/custom_app_bar.dart';

class AcercaScreen extends StatelessWidget {
  const AcercaScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.grey[200],
    appBar: CustomAppBar(
      title: const Text("Acerca de Mi UTEM"),
    ),
    body: SafeArea(child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const AcercaClub(),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              child: AcercaAplicacionContent(),
            ),
            const AcercaClubDesarrolladores(),
            kDebugMode ? const AcercaApp() : const SizedBox(),
          ],
        ),
      ),
    )),
  );
}
