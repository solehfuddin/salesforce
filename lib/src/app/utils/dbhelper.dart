import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sample/src/domain/entities/notifikasi.dart';
import 'package:sqflite/sqflite.dart';

final String tableNotif = "notifikasi";
final String colId = "_id";
final String colIdNotif = "id_notifikasi";
final String colIdUser = "id_user";
final String colTypeTemplate = "type_template";
final String colTypeNotif = "type_notifikasi";
final String colJudul = "judul";
final String colIsi = "isi";
final String colTgl = "tanggal";
final String colIsRead = "is_read";

class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();
  static Database? db;

  Future<Database> get database async {
    if (db == null) {
      // initialize database from _createDatabase result.
      db = await createDb();
    }
    return db!;
  }

  Future<Database> createDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "myleinz.db";
    db = await openDatabase(path, version: 1, onCreate: _createDb);
    return db!;
  }

  void _createDb(Database database, int version) async {
    await database.execute('''
      CREATE TABLE notifikasi (
          $colId INTEGER PRIMARY KEY autoincrement,
          $colIdNotif TEXT,
          $colIdUser TEXT,
          $colTypeTemplate TEXT,
          $colTypeNotif TEXT,
          $colJudul TEXT,
          $colIsi TEXT,
          $colTgl DATETIME,
          $colIsRead TEXT)
    ''');
  }

  Future<List<Map<String, dynamic>>> searchData() async {
    return await db!.query('$tableNotif', orderBy: '$colTgl DESC');
  }

  Future<List<Notifikasi>> getAllNotifikasi() async {
    List<Notifikasi> listNotif = List.empty(growable: true);
    var notifMapList = await searchData();
    int count = notifMapList.length;

    for (int i = 0; i < count; i++)
    {
      listNotif.add(Notifikasi.fromMap(notifMapList[i]));
    }

    return listNotif;
  }

  Future<bool> selectByRead() async {
    var list = await db!.query(
      'notifikasi',
      where: 'is_read=?',
      whereArgs: ["0"], 
    );
    int count = list.length;

    if (count > 0){
      return true;
    }
    else
    {
      return false;
    }
  }

  Future<List<Notifikasi>> selectById(Notifikasi notifikasi) async {
    var mapList = await db!.query(
      'notifikasi',
      where: 'id_notifikasi=?',
      whereArgs: [notifikasi.idNotif],
      limit: 1,
    );
    int count = mapList.length;
    List<Notifikasi> notifList = List.empty(growable: true);
    for (int i = 0; i < count; i++) {
      notifList.add(Notifikasi.fromMap(mapList[i]));
    }
    return notifList;
  }


  Future<int> insert(Notifikasi notifikasi) async {
    int count = await db!.insert('notifikasi', notifikasi.toMap());
    return count;
  }

  Future<int> update(Notifikasi notifikasi) async {
    int count = await db!.update(
      'notifikasi',
      notifikasi.toMap(),
      where: 'id_notifikasi=?',
      whereArgs: [notifikasi.idNotif],
    );
    return count;
  }

  Future<int> delete(int id) async {
    int count = await db!.delete('notifikasi', where: 'id_notifikasi=?', whereArgs: [id]);
    return count;
  }
}