import "dart:convert";
import "dart:math";

import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_markdown/flutter_markdown.dart";
import "package:get/get.dart";
import "package:mi_utem/models/novedades/ibanner.dart";
import "package:mi_utem/models/user/user.dart";
import "package:mi_utem/repositories/interfaces/noticias_repository.dart";
import "package:mi_utem/repositories/interfaces/permiso_ingreso_repository.dart";
import "package:mi_utem/repositories/interfaces/preferences_repository.dart";
import "package:mi_utem/services/interfaces/auth_service.dart";
import "package:mi_utem/services/interfaces/grades_service.dart";
import "package:mi_utem/services/remote_config/remote_config.dart";
import "package:mi_utem/services/review_service.dart";
import "package:mi_utem/widgets/custom_app_bar.dart";
import "package:mi_utem/widgets/custom_drawer.dart";
import "package:mi_utem/widgets/main_screen/novedades/banners_section.dart";
import "package:mi_utem/widgets/main_screen/permisos/permisos_section.dart";
import "package:mi_utem/widgets/noticias/noticias_carrusel_widget.dart";
import "package:mi_utem/widgets/pull_to_refresh.dart";
import "package:mi_utem/widgets/quick_menu_section.dart";

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
  });

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  List<IBanner> _banners = const [];
  User? _user;
  String? _alias;
  final _authService = Get.find<AuthService>();
  final _preferencesRepository = Get.find<PreferencesRepository>();

  @override
  void initState() {
    super.initState();
    _authService.saveFCMToken();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    ReviewService.addScreen("MainScreen");
    ReviewService.checkAndRequestReview(context);

    loadData();

    _preferencesRepository.getAlias().then((alias) => setState(() => _alias = alias));
    _authService.getUser().then((user) => setState(() => _user = user));
  }

  Future<void> loadData() async {
    await RemoteConfigService.update();
    await Get.find<PermisoIngresoRepository>().getPermisos(forceRefresh: true); // Forzar re-descarga de los permisos
    await Get.find<NoticiasRepository>().getNoticias(forceRefresh: true); // Forzar re-descarga de las noticias
    setState(() => _banners = RemoteConfigService.banners); // Actualizar los banners y se re-renderiza
  }

  String get _greetingText {
    List<dynamic> texts = jsonDecode(RemoteConfigService.greetings);
    return texts[Random().nextInt(texts.length)].replaceAll("%name", _alias ?? _user?.primerNombre ?? "N/N");
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: Text("Inicio")),
    drawer: CustomDrawer(),
    floatingActionButton: kDebugMode ? FloatingActionButton(
      onPressed: () => Get.find<GradesService>().lookForGradeUpdates(),
      tooltip: "Probar notificaciones de notas",
      child: Icon(Icons.notifications,
        color: Colors.white,
      ),
    ) : null,
    body: PullToRefresh(
      onRefresh: loadData,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: MarkdownBody(
                data: _greetingText,
                styleSheet: MarkdownStyleSheet(
                  p: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.normal),
                ),
              ),
            ),
            const SizedBox(height: 20),
            PermisosCovidSection(),
            const SizedBox(height: 20),
            const QuickMenuSection(),
            const SizedBox(height: 20),
            if (_banners.isNotEmpty) ...[
              BannersSection(banners: _banners),
              const SizedBox(height: 20),
            ],
            NoticiasCarruselWidget(),
          ],
        ),
      ),
    ),
  );
}
