import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class SendPendingInspectionScree extends StatelessWidget {
  const SendPendingInspectionScree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context, listen: true);
    final inspeccionService = Provider.of<InspeccionService>(context, listen: false);
    final loginService = Provider.of<LoginService>(context, listen: false);
    final allInspecciones = inspeccionProvider.allInspecciones;

    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: FutureBuilder(
        future: inspeccionProvider.cargarTodosInspecciones(loginService.userDataLogged.numeroDocumento!, loginService.selectedEmpresa.nombreBase!),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: Text('Sin inspecciones pendientes por sincronizar'),
            );
          }
          return Container(
            height: double.infinity,
            padding: EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 50),
            child: ContentCardInspectionPending(
              allInspecciones: allInspecciones,
              inspeccionService: inspeccionService,
              inspeccionProvider: inspeccionProvider,
              selectedEmpresa: loginService.selectedEmpresa
            )
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: FloatingActionButton(
      //   mini: true,
      //   onPressed: inspeccionService.isSaving
      //       ? null
      //       : () async {
      //           List<Future> promesas = [];
      //           allInspecciones.forEach((element) {
      //             promesas.add(inspeccionService.sendInspeccion(element));
      //           });
      //           await Future.wait(promesas).then((value) {
      //             print(value);
      //           });
      //         },
      //   child: Icon(Icons.upload_rounded),
      // ),
    );
  }
}

class ContentCardInspectionPending extends StatelessWidget {
  const ContentCardInspectionPending({
    Key? key,
    required this.allInspecciones,
    required this.inspeccionService,
    required this.inspeccionProvider,
    required this.selectedEmpresa
  }) : super(key: key);

  final List<ResumenPreoperacional> allInspecciones;
  final InspeccionService inspeccionService;
  final InspeccionProvider inspeccionProvider;
  final Empresa selectedEmpresa;
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: allInspecciones.length,
        itemBuilder: (_, int i) {
          return Card(
            child: inspeccionService.isSaving &&
                    inspeccionService.indexSelected == i
                ? Container(
                    padding: EdgeInsets.all(20),
                    child: Column(children: [
                      Image(
                        image: AssetImage('assets/images/loading_3.gif'),
                        // fit: BoxFit.cover,
                        height: 50,
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      LinearProgressIndicator(),
                    ]),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text('Inspección No. ${i + 1}'),
                        subtitle: Text('Realizado el ${allInspecciones[i].fechaPreoperacional}'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red,),
                            onPressed: inspeccionService.isSaving
                              ? null
                              : () async {
                                  final responseDelete = await inspeccionProvider.eliminarResumenPreoperacional(allInspecciones[i].id!);
                                  await inspeccionProvider.eliminarRespuestaPreoperacional(allInspecciones[i].id!);
                                  showSimpleNotification(
                                    Text('Inspección ${responseDelete} eliminada'),
                                    leading: Icon(Icons.check),
                                    autoDismiss: true,
                                    background: Colors.green,
                                    position: NotificationPosition.bottom
                                  );
                                },
                          ),
                          IconButton(
                            icon: Icon(Icons.picture_as_pdf_sharp, color: Colors.red,),
                            onPressed: inspeccionService.isSaving
                              ? null
                              : () async {
                                  inspeccionService.indexSelected = i;
                                  Navigator.pushNamed(context, 'pdf_offline', arguments: [allInspecciones[i]]);
                                },
                          ),
                          IconButton(
                            icon: Icon(Icons.send, color: Colors.green,),
                            onPressed: inspeccionService.isSaving
                              ? null
                              : () {
                                  inspeccionService.indexSelected = i;
                                  inspeccionService.sendInspeccion(allInspecciones[i], selectedEmpresa);
                                }
                              ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
          );
        });
  }
}
