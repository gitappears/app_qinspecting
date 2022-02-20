import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors
              .white, // set the Color of the drawer transparent; we'll paint above it with the shape
        ),
        child: Drawer(
            child: ListView(
          children: <Widget>[
            ListTile(
              leading: const Icon(
                Icons.account_box,
                color: Colors.green,
              ),
              title: const Text(
                'Perfil',
                style: TextStyle(color: Colors.green),
              ),
              onTap: () => Navigator.popAndPushNamed(context, 'profile'),
            ),
            ListTile(
                leading: const Icon(Icons.home, color: Colors.green),
                title: const Text(
                  'Inicio',
                  style: TextStyle(color: Colors.green),
                ),
                onTap: () => Navigator.pushReplacementNamed(context, 'home')),
            ListTile(
                leading: const Icon(Icons.fact_check, color: Colors.green),
                title: const Text(
                  'Inspección',
                  style: TextStyle(color: Colors.green),
                ),
                onTap: () =>
                    Navigator.pushReplacementNamed(context, 'inspeccion')),
            ListTile(
              leading: Icon(Icons.send, color: Colors.green),
              title: Text('Enviar inspecciones',
                  style: TextStyle(color: Colors.green)),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, 'send_pending'),
            ),
            ListTile(
                leading: Icon(Icons.gesture, color: Colors.green),
                title: Text('Firma', style: TextStyle(color: Colors.green)),
                onTap: () =>
                    Navigator.pushReplacementNamed(context, 'signature')),
            ListTile(
                leading: Icon(Icons.settings, color: Colors.green),
                title: Text('Configuración',
                    style: TextStyle(color: Colors.green)),
                onTap: () =>
                    Navigator.pushReplacementNamed(context, 'settings')),
          ],
        )));
  }
}
