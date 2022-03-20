import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/screens/screens.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class InspeccionScreen extends StatelessWidget {
  const InspeccionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider =
        Provider.of<InspeccionProvider>(context, listen: false);
    inspeccionProvider.listarDepartamentos();
    inspeccionProvider.listarVehiculos();

    return Scaffold(
      appBar: const CustomAppBar().createAppBar(context),
      drawer: const CustomDrawer(),
      body: InspeccionForm(),
    );
  }
}
