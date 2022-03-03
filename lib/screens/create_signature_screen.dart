import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';

import 'package:app_qinspecting/screens/loading_screen.dart';
import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';

class CreateSignatureScreen extends StatefulWidget {
  const CreateSignatureScreen({Key? key}) : super(key: key);

  @override
  State<CreateSignatureScreen> createState() => _CreateSignatureScreenState();
}

class _CreateSignatureScreenState extends State<CreateSignatureScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final inspeccionService = Provider.of<InspeccionService>(context);
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    final loginService = Provider.of<LoginService>(context);
    if (inspeccionService.isSaving) return LoadingScreen();
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            //SIGNATURE CANVAS
            Signature(
              controller: _controller,
              height: screenSize.height * 0.83,
              backgroundColor: Colors.grey[200]!,
            ),
            //OK AND CLEAR BUTTONS
            Container(
              decoration: const BoxDecoration(color: Colors.grey),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  //SHOW EXPORTED IMAGE IN NEW ROUTE
                  IconButton(
                    icon: const Icon(Icons.check),
                    color: Colors.black,
                    onPressed: () async {
                      if (_controller.isNotEmpty) {
                        inspeccionService.isSaving = true;
                        final Uint8List? data = await _controller.toPngBytes();
                        if (data != null) {
                          // File('my_firma.png').writeAsBytes(data);

                          final dir = await getExternalStorageDirectory();
                          final myImagePath =
                              '${dir!.path}/${loginService.userDataLogged.usuarioUser}.png';
                          File imageFile = File(myImagePath);
                          if (!await imageFile.exists()) {
                            imageFile.create(recursive: true);
                          }
                          imageFile.writeAsBytesSync(data);
                          // Se envia la foto de la firma al servidor
                          Map<String, dynamic>? responseUploadFirma =
                              await inspeccionService.uploadImage(
                                  path: myImagePath,
                                  company: 'qinspecting',
                                  folder: 'firmas');

                          Map dataFirmaSave = {
                            "base": loginService.selectedEmpresa!.nombreBase,
                            "Firma_Id": null,
                            "Firma_acep_Ptd": "SI",
                            "Firma_Firma": responseUploadFirma!['path'],
                            "Pers_NumeroDoc":
                                loginService.userDataLogged.usuarioUser
                          };
                          Map responseSaveFirma = await inspeccionService
                              .insertSignature(dataFirmaSave);
                          // show a notification at top of screen.
                          inspeccionService.isSaving = false;
                          inspeccionProvider.updateTerminos('NO');
                          inspeccionService.updateTabIndex(0);
                          showSimpleNotification(
                              Text(responseSaveFirma['message']!),
                              leading: Icon(Icons.check),
                              autoDismiss: true,
                              background: Colors.green,
                              position: NotificationPosition.bottom);
                          Navigator.pop(context);
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.undo),
                    color: Colors.black,
                    onPressed: () {
                      setState(() => _controller.undo());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.redo),
                    color: Colors.black,
                    onPressed: () {
                      setState(() => _controller.redo());
                    },
                  ),
                  //CLEAR CANVAS
                  IconButton(
                    icon: const Icon(Icons.clear),
                    color: Colors.black,
                    onPressed: () {
                      setState(() => _controller.clear());
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}