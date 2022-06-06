import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:app_qinspecting/models/models.dart';

class DBProvider {
  static Database? _database;
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDB();

    return _database;
  }

  Future<Database?> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDirectory.path, 'qinspecting.db');

    // Se crea la base de datos
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE ResumenPreoperacional(Id INTEGER PRIMARY KEY AUTOINCREMENT, placa TEXT, fechaPreoperacional TEXT, ciudaGpsPreope TEXT, kilometrajePreope NUMERIC, cantTanqueoGalones NUMERIC, urlFotoKm TEXT, usuarioPreoperacional NUMERIC, guiaPreoperacional TEXT, urlFotoGuia TEXT, idVehiculoPreo NUMERIC, idRemolquePreo NUMERIC, remolquePlaca TEXT, idCiudadPreop NUMERIC, ciudad TEXT, respuestas TEXT, base TEXT);
      ''');
      await db.execute('''
        CREATE TABLE RespuestasPreoperacional(Id INTEGER PRIMARY KEY AUTOINCREMENT, idCategoria INTEGER, idItem INTEGER, item TEXT, respuesta TEXT, adjunto TEXT, observaciones TEXT, base TEXT, fk_preoperacional INTEGER, CONSTRAINT fk_preoperacional FOREIGN KEY (Id) REFERENCES ResumenPreoperacional(Id) ON DELETE CASCADE) ;
      ''');
      await db.execute('''
        CREATE TABLE Empresas(idEmpresa INTEGER PRIMARY KEY, nombreBase TEXT, autCreateCap NUMERIC, numeroDocumento TEXT, password TEXT, apellidos TEXT, nombres TEXT, numeroCelular TEXT, email TEXT, nombreCargo TEXT, urlFoto TEXT, idRol NUMERIC, tieneFirma NUMERIC, razonSocial TEXT, nombreQi TEXT, urlQi TEXT, rutaLogo TEXT);
      ''');
      await db.execute('''
        CREATE TABLE personal(id INTEGER PRIMARY KEY AUTOINCREMENT, empresa TEXT UNIQUE, numeroDocumento TEXT, password TEXT, lugarExpDocumento NUMERIC, nombreCiudad TEXT, fkIdDepartamento NUMERIC, departamento TEXT, fechaNacimiento TEXT, genero TEXT, rh TEXT, arl TEXT, eps TEXT, afp TEXT, numeroCelular TEXT, direccion TEXT, apellidos TEXT, nombres TEXT, email TEXT, urlFoto TEXT, idCargo NUMERIC, nombreCargo TEXT, estadoPersonal NUMERIC, idTipoDocumento NUMERIC, nombreTipoDocumento TEXT, rolId NUMERIC, rolNombre TEXT, rolDescripcion TEXT, idFirma NUMERIC);
      ''');
      await db.execute('''
        CREATE TABLE TipoDocumentos(value INTEGER PRIMARY KEY, label TEXT);
      ''');
      await db.execute('''
        CREATE TABLE Departamentos(value INTEGER PRIMARY KEY, label TEXT);
      ''');
      await db.execute('''
        CREATE TABLE Ciudades(value INTEGER PRIMARY KEY, label TEXT, id_departamento INTEGER, CONSTRAINT fk_departamento FOREIGN KEY (id_departamento) REFERENCES Departamentos(Dpt_Id));
      ''');
      await db.execute('''
        CREATE TABLE Vehiculos(idVehiculo INTEGER PRIMARY KEY AUTOINCREMENT, placa TEXT, idTpVehiculo INTEGER, modelo INTEGER, nombreMarca TEXT, color TEXT, licenciaTransito NUMERIC);
      ''');
      await db.execute('''
        CREATE TABLE Remolques(idRemolque INTEGER PRIMARY KEY AUTOINCREMENT, placa TEXT, idTpVehiculo INTEGER, modelo INTEGER, nombreMarca TEXT, color TEXT, numeroMatricula NUMERIC, numeroEjes INTEGER);
      ''');
      await db.execute('''
        CREATE TABLE ItemsInspeccion(id TEXT PRIMARY KEY, placa TEXT, tipoVehiculo INTEGER, idCategoria INTEGER, categoria TEXT, idItem, item TEXT);
      ''');
    });
  }

  // Forma corta
  Future<int?> nuevaEmpresa(Empresa nuevaEmpresa) async {
    final db = await database;
    final res = await db?.insert('Empresas', nuevaEmpresa.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<Empresa?> getEmpresaById(int id) async {
    final db = await database;
    final res =
        await db?.query('Empresas', where: 'idEmpresa = ?', whereArgs: [id]);
    return res!.isNotEmpty ? Empresa.fromMap(res.first) : null;
  }

  Future<List<Empresa>?> getAllEmpresas() async {
    final db = await database;
    final res = await db?.query('Empresas');

    return res!.isNotEmpty ? res.map((s) => Empresa.fromMap(s)).toList() : [];
  }

  Future<List<Empresa>?> getAllEmpresasByUsuario(int usuario) async {
    final db = await database;
    final res = await db
        ?.query('Empresas', where: 'numeroDocumento = ?', whereArgs: [usuario]);

    return res!.isNotEmpty ? res.map((s) => Empresa.fromMap(s)).toList() : [];
  }

  Future<int?> deleteEmpresa(int id) async {
    final db = await database;
    final res =
        await db?.delete('Empresas', where: 'idEmpresa= ?', whereArgs: [id]);

    return res;
  }

  Future<int?> deleteAllEmpresas() async {
    final db = await database;
    final res = await db?.delete('Empresas');

    return res;
  }

  // CONSULTAS PARA USER DATA
  Future<int?> nuevoUser(UserData nuevoUser) async {
    final db = await database;
    final res = await db?.insert('personal', nuevoUser.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<UserData?> getUserById(String id) async {
    final db = await database;
    final res = await db?.query('personal', where: 'numeroDocumento = ?', whereArgs: [id]);
    return res!.isNotEmpty ? UserData.fromMap(res.first) : null;
  }

  Future<int?> updateUser(UserData nuevoDatosUsuario) async {
    final db = await database;
    final res = await db?.update('personal', nuevoDatosUsuario.toMap(), where: 'numeroDocumento= ?', whereArgs: [nuevoDatosUsuario.id]);
    return res;
  }

  Future<int?> nuevoTipoDocumento(TipoDocumentos nuevoTipoDoc) async {
    final db = await database;
    final res = await db?.insert('TipoDocumentos', nuevoTipoDoc.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<List<TipoDocumentos>?> getAllTipoDocs() async {
    final db = await database;
    final res = await db?.query('TipoDocumentos');

    return res!.isNotEmpty
        ? res.map((s) => TipoDocumentos.fromMap(s)).toList()
        : [];
  }

  // CONSULTAS PARA MODULO INSPECCIONES
  Future<int?> nuevoDepartamento(Departamentos nuevoDepartamento) async {
    final db = await database;
    final res = await db?.insert('Departamentos', nuevoDepartamento.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<Departamentos?> getDepartamentoById(int id) async {
    final db = await database;
    final res =
        await db?.query('Departamentos', where: 'value = ?', whereArgs: [id]);
    return res!.isNotEmpty ? Departamentos.fromMap(res.first) : null;
  }

  Future<List<Departamentos>?> getAllDepartamentos() async {
    final db = await database;
    final res = await db?.query('Departamentos');

    return res!.isNotEmpty
        ? res.map((s) => Departamentos.fromMap(s)).toList()
        : [];
  }

  Future<int?> nuevaCiudad(Ciudades nuevaCiudad) async {
    final db = await database;
    final res = await db?.insert('Ciudades', nuevaCiudad.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<Ciudades?> getCiudadById(int id) async {
    final db = await database;
    final res = await db?.query('Ciudades', where: 'value = ?', whereArgs: [id]);
    return res!.isNotEmpty ? Ciudades.fromMap(res.first) : null;
  }

  Future<List<Ciudades>?> getCiudadesByIdDepartamento(int id) async {
    final db = await database;
    print(id);
    final res = await db?.query('Ciudades', where: 'id_departamento = ?', whereArgs: [id]);
    return res!.isNotEmpty ? res.map((s) => Ciudades.fromMap(s)).toList() : [];
  }

  Future<int?> nuevoVehiculo(Vehiculo nuevoVehiculo) async {
    final db = await database;
    final res = await db?.insert('Vehiculos', nuevoVehiculo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<int?> nuevoRemolque(Remolque nuevoRemolque) async {
    final db = await database;
    final res = await db?.insert('Remolques', nuevoRemolque.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<Vehiculo?> getVehiculoByPlate(String placa) async {
    final db = await database;
    final res =
        await db?.query('Vehiculos', where: 'placa = ?', whereArgs: [placa]);
    return res!.isNotEmpty ? Vehiculo.fromMap(res.first) : null;
  }

  Future<Remolque?> getRemolqueByPlate(String placa) async {
    final db = await database;
    final res =
        await db?.query('Remolques', where: 'placa = ?', whereArgs: [placa]);
    return res!.isNotEmpty ? Remolque.fromMap(res.first) : null;
  }

  Future<List<Vehiculo>?> getAllVehiculos() async {
    final db = await database;
    final res = await db?.query('Vehiculos');

    return res!.isNotEmpty ? res.map((s) => Vehiculo.fromMap(s)).toList() : [];
  }

  Future<List<Remolque>?> getAllRemolques() async {
    final db = await database;
    final res = await db?.query('Remolques');

    return res!.isNotEmpty ? res.map((s) => Remolque.fromMap(s)).toList() : [];
  }

  Future<int?> nuevoItem(ItemInspeccion nuevoVehiculo) async {
    final db = await database;

    final res = await db?.insert('ItemsInspeccion', nuevoVehiculo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<ItemInspeccion?> getItemById(String id) async {
    final db = await database;
    final res = await db
        ?.query('ItemsInspeccion', where: 'idItem = ?', whereArgs: [id]);
    return res!.isNotEmpty ? ItemInspeccion.fromMap(res.first) : null;
  }

  Future<List<ItemInspeccion>?> getAllItems() async {
    final db = await database;
    final res = await db?.query('ItemsInspeccion');

    return res!.isNotEmpty
        ? res.map((s) => ItemInspeccion.fromMap(s)).toList()
        : [];
  }

  Future<List<ItemsVehiculo>?> getItemsInspectionByPlaca(String placa) async {
    final db = await database;
    final res = await db?.rawQuery('''
      SELECT idCategoria, categoria, ('['|| GROUP_CONCAT( ( '{"idItem":"'|| idItem || '"'|| ',"item":"'|| item|| '"}' ) )|| ']' ) AS items FROM ItemsInspeccion WHERE placa='${placa}' GROUP BY idCategoria
    ''');
    List<Map<String, dynamic>> lsitItems = [];

    res?.forEach((categoria) {
      var json = jsonDecode(categoria['items'].toString());

      Map<String, dynamic> tempData = {
        "idCategoria": categoria['idCategoria'],
        "categoria": categoria['categoria'],
        "items": json,
      };
      lsitItems.add(tempData);
    });
    return res!.isNotEmpty
        ? lsitItems.map((s) => ItemsVehiculo.fromMap(s)).toList()
        : [];
  }

  Future<int?> nuevoInspeccion(ResumenPreoperacional nuevoInspeccion) async {
    final db = await database;
    Map<String, dynamic> resumenSave = {
      "placa": nuevoInspeccion.placa,
      "fechaPreoperacional": nuevoInspeccion.fechaPreoperacional,
      "ciudaGpsPreope": nuevoInspeccion.ciudaGpsPreope ?? nuevoInspeccion.idCiudadPreop,
      "kilometrajePreope": nuevoInspeccion.kilometrajePreope,
      "cantTanqueoGalones": nuevoInspeccion.cantTanqueoGalones,
      "urlFotoKm": nuevoInspeccion.urlFotoKm,
      "usuarioPreoperacional": nuevoInspeccion.usuarioPreoperacional,
      "guiaPreoperacional": nuevoInspeccion.guiaPreoperacional,
      "urlFotoGuia": nuevoInspeccion.urlFotoGuia,
      "idVehiculoPreo": nuevoInspeccion.idVehiculoPreo,
      "idRemolquePreo": nuevoInspeccion.idRemolquePreo,
      "remolquePlaca": nuevoInspeccion.remolquePlaca,
      "idCiudadPreop": nuevoInspeccion.idCiudadPreop,
      "ciudad": nuevoInspeccion.ciudad,
      "respuestas": nuevoInspeccion.respuestas,
      "base": nuevoInspeccion.base,
    };
    final res = await db?.insert('ResumenPreoperacional', resumenSave);
    return res;
  }

  Future<int?> nuevoRespuestaInspeccion(Item nuevaRespuesta) async {
    final db = await database;
    final res =
        await db?.insert('RespuestasPreoperacional', nuevaRespuesta.toMap());
    return res;
  }

  Future<int?> deleteResumenPreoperacional(int idResumen) async {
    final db = await database;
    final res = await db?.delete('ResumenPreoperacional',
        where: 'Id = ?', whereArgs: [idResumen]);
    return res;
  }

  Future<int?> deleteRespuestaPreoperacional(int idResumen) async {
    final db = await database;
    final res = await db?.delete('RespuestasPreoperacional',
        where: 'fk_preoperacional = ?', whereArgs: [idResumen]);
    return res;
  }

  Future<List<ResumenPreoperacional>?> getAllInspections(String idUsuario) async {
    final db = await database;
    final res = await db?.query('ResumenPreoperacional', whereArgs: [idUsuario], where: 'Pers_NumeroDoc = ?');

    return res!.isNotEmpty
        ? res.map((s) => ResumenPreoperacional.fromMap(s)).toList()
        : [];
  }

  Future<List<Item>?> getAllRespuestasByIdResumen(int fk_preoperacional) async {
    final db = await database;
    final res = await db?.query('RespuestasPreoperacional',
        where: 'fk_preoperacional = ?', whereArgs: [fk_preoperacional]);

    return res!.isNotEmpty ? res.map((s) => Item.fromMap(s)).toList() : [];
  }
}
