import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mi_utem/models/horario.dart';
import 'package:mi_utem/services/config_service.dart';
import 'package:mi_utem/services/horarios_service.dart';
import 'package:mi_utem/services/review_service.dart';
import 'package:mi_utem/widgets/bloque_dias_card.dart';
import 'package:mi_utem/widgets/bloque_periodo_card.dart';
import 'package:mi_utem/widgets/bloque_ramo_card.dart';
import 'package:mi_utem/widgets/custom_app_bar.dart';
import 'package:mi_utem/widgets/custom_error_widget.dart';
import 'package:mi_utem/widgets/loading_indicator.dart';
import 'package:mi_utem/widgets/pull_to_refresh.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math_64.dart';

class HorarioScreen extends StatefulWidget {
  HorarioScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HorarioScreenState();
}

class _HorarioScreenState extends State<HorarioScreen> {
  final double _classBlockWidth = 290.0;
  final double _classBlockHeight = 180.0;
  final double _dayBlockHeight = 50.0;
  final double _dayBlockWidth = 320.0;
  final double _periodBlockHeight = 200.0;
  final double _periodBlockWidth = 65.0;
  final bool _dayActive = true;
  final bool _periodActive = true;

  Future<Horario>? _horarioFuture;
  Horario? _horario;
  TransformationController? _controller;
  RemoteConfig? _remoteConfig;
  ScreenshotController _screenshotController = ScreenshotController();

  CustomAppBar get _appBar => CustomAppBar(
        title: Text("Horario"),
        actions: [
          if (_horario != null)
            IconButton(
              onPressed: () {
                _screenshotController
                    .capture(delay: const Duration(milliseconds: 10))
                    .then((Uint8List? image) async {
                  if (image != null) {
                    final directory = await getApplicationDocumentsDirectory();
                    final imagePath =
                        await File('${directory.path}/horario.png').create();
                    await imagePath.writeAsBytes(image);

                    /// Share Plugin
                    await Share.shareFiles([imagePath.path]);
                  }
                }).catchError((onError) {
                  print(onError);
                });
              },
              icon: Icon(Icons.share),
            )
        ],
      );

  @override
  void initState() {
    super.initState();
    _remoteConfig = ConfigService.config;

    double zoom = _remoteConfig!.getDouble(ConfigService.HORARIO_ZOOM);
    _controller = TransformationController();
    _controller!.value = Matrix4.identity();
    _controller!.value.setDiagonal(Vector4(zoom, zoom, zoom, 1));

    ReviewService.addScreen("HorarioScreen");
    FirebaseAnalytics().setCurrentScreen(screenName: 'HorarioScreen');
    _horarioFuture = _getHorario();
    _getHorarioActualizado();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  Future<Horario> _getHorario() async {
    Horario horario = await HorarioService.getHorario();
    setState(() {
      _horario = horario;
    });
    return horario;
  }

  Future<Horario> _getHorarioActualizado() async {
    Horario horarioActualizado = await HorarioService.getHorario(true);
    setState(() {
      _horario = horarioActualizado;
    });
    return horarioActualizado;
  }

  List<TableRow> _getChildren(Horario horario) {
    List<TableRow> filas = [];

    // Container vacio para la esquina superior izquierda
    List<Widget> filaWidgets = [
      Container(
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          border: Border(
            right: BorderSide(
              color: Color(0xFFBDBDBD),
              style: BorderStyle.solid,
              width: 1,
            ),
          ),
        ),
        height: _dayBlockHeight,
        width: _periodBlockWidth,
      )
    ];

    // Primera fila de los días
    if (horario.dias != null) {
      for (dynamic dia in horario.dias!) {
        log('dia: $dia');
        filaWidgets.add(BloqueDiasCard(
          day: dia,
          height: _dayBlockHeight,
          width: _dayBlockWidth,
          active: _dayActive,
        ));
      }
    }
    filas.add(TableRow(children: filaWidgets));

    // Se llena el resto
    for (num i = 0; i < horario.horarioEnlazado.length; i++) {
      filaWidgets = [];
      if ((i % 2) == 0) {
        List<BloqueHorario> periodo = horario.horarioEnlazado[i as int];
        for (num j = 0; j < periodo.length; j++) {
          BloqueHorario bloque = horario.horarioEnlazado[i][j as int];
          if (j == 0) {
            filaWidgets.add(BloquePeriodoCard(
              inicio: horario.horasInicio[i ~/ 2],
              intermedio: horario.horasIntermedio[i ~/ 2],
              fin: horario.horasTermino[i ~/ 2],
              height: _periodBlockHeight,
              width: _periodBlockWidth,
              active: _periodActive,
            ));
          }

          print("bloque ${bloque.codigo} ${bloque.asignatura}");

          filaWidgets.add(BloqueRamoCard(
            height: _classBlockHeight,
            width: _classBlockWidth,
            bloque: bloque,
          ));
        }
        filas.add(TableRow(children: filaWidgets));
      }
    }

    return filas;
  }

  Future<void> _onRefresh() async {
    await _getHorario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar,
      body: FutureBuilder(
        future: _horarioFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            DioError? dioError;

            if (snapshot.error is DioError) {
              dioError = snapshot.error as DioError?;
            }

            if (dioError != null && dioError.response!.statusCode == 404) {
              return CustomErrorWidget(
                emoji: "🤔",
                texto: "Parece que no se encontró el horario",
                error: snapshot.error,
              );
            }
            return CustomErrorWidget(
              texto: "Ocurrió un error al obtener el horario",
              error: snapshot.error,
            );
          } else {
            if (snapshot.hasData) {
              Horario? horario = _horario;
              return PullToRefresh(
                onRefresh: () async {
                  await _onRefresh();
                },
                child: InteractiveViewer(
                  transformationController: _controller,
                  maxScale: 1,
                  minScale: 0.1,
                  alignPanAxis: false,
                  clipBehavior: Clip.none,
                  constrained: false,
                  onInteractionUpdate: (interaction) {
                    if (interaction.scale >= 0.8) {
                      print("HEY");
                    }
                  },
                  child: Screenshot(
                    controller: _screenshotController,
                    child: SafeArea(
                      child: Table(
                        defaultColumnWidth: FixedColumnWidth(_classBlockWidth),
                        columnWidths: {
                          0: FixedColumnWidth(_periodBlockWidth),
                        },
                        children: _getChildren(horario!),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: LoadingIndicator(),
                      ),
                    ),
                  ],
                ),
              );
            }
          }
        },
      ),
    );
  }
}
