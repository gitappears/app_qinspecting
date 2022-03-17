import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class InspeccionRemolqueScreen extends StatelessWidget {
  const InspeccionRemolqueScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    final inspeccionService = Provider.of<InspeccionService>(context);
    final loginService = Provider.of<LoginService>(context);
    final uiProvider = Provider.of<UiProvider>(context);

    if (inspeccionProvider.isSaving) return Loading();
    return Scaffold(
      appBar: AppBar(),
      body: ItemsInspeccionarRemolque(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () async {
          inspeccionProvider.updateSaving(true);
          final idEncabezado = await inspeccionProvider
              .saveInspecicon(inspeccionService.resumePreoperacional);
          List<Future> respuestas = [];

          inspeccionProvider.itemsInspeccion.forEach((categoria) {
            categoria.items.forEach((item) {
              if (item.respuesta != null) {
                item.fkPreoperacional = idEncabezado;
                item.base = loginService.selectedEmpresa.nombreBase;
                respuestas
                    .add(inspeccionProvider.saveRespuestaInspeccion(item));
              }
            });
          });
          inspeccionProvider.itemsInspeccionRemolque.forEach((categoria) {
            categoria.items.forEach((item) {
              if (item.respuesta != null) {
                item.fkPreoperacional = idEncabezado;
                item.base = loginService.selectedEmpresa.nombreBase;
                respuestas
                    .add(inspeccionProvider.saveRespuestaInspeccion(item));
              }
            });
          });

          await Future.wait(respuestas);
          inspeccionProvider.updateSaving(false);
          uiProvider.selectedMenuOpt = 0;
          // show a notification at top of screen.
          showSimpleNotification(Text('Inspección realizada'),
              leading: Icon(Icons.check),
              autoDismiss: true,
              background: Colors.green,
              position: NotificationPosition.bottom);

          Navigator.pushReplacementNamed(context, 'home');
        },
      ),
    );
  }
}
