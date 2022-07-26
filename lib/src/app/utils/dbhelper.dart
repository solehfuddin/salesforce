import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sample/src/domain/entities/notifikasi.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static DbHelper _dbHelper;
  static Database _database;

  DbHelper._createObject();

  factory DbHelper() {
    if (_dbHelper == null) {
      _dbHelper = DbHelper._createObject();
    }

    return _dbHelper;
  }

  Future<Database> initDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "myleinz.db";

    // var db = openDatabase(path, version: 1, onCreate: (db, version) async {
    //   var batch = db.batch();
    //   _createTblNotifikasiv1(batch);
    //   batch.commit();
    // });
    var db = openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );

    return db;
  }

  void _createDb(Database database, int version) async {
    await database.execute('''
      CREATE TABLE notifikasi (
          id INTEGER PRIMARY KEY autoincrement,
          id_notifikasi TEXT,
          id_user TEXT,
          type_template TEXT,
          type_notifikasi TEXT,
          judul TEXT,
          isi TEXT,
          tanggal DATETIME,
          is_read TEXT)
    ''');
  }

  // void _createTblNotifikasiv1(Batch batch) {
  //   batch.execute("DROP TABLE IF EXIST notifikasi");
  // batch.execute(""" CREATE TABLE notifikasi (
  //   id_notifikasi INTEGER PRIMARY KEY,
  //   id_user INTEGER,
  //   type_template INTEGER,
  //   type_notifikasi INTEGER,
  //   judul TEXT,
  //   isi TEXT,
  //   tanggal DATETIME,
  //   is_read INTEGER
  // ) """);
  // }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initDb();
    }
    return _database;
  }

  Future<List<Map<String, dynamic>>> select() async {
    Database db = await this.database;
    var mapList = await db.query('notifikasi', orderBy: 'tanggal DESC');
    return mapList;
  }

  Future<List<Notifikasi>> selectById(Notifikasi notifikasi) async {
    Database db = await this.database;
    var mapList = await db.query(
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

  Future<bool> selectByRead() async {
    Database db = await this.database;
    var list = await db.query(
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

  Future<int> insert(Notifikasi notifikasi) async {
    Database db = await this.database;
    int count = await db.insert('notifikasi', notifikasi.toMap());
    return count;
  }

  Future<int> update(Notifikasi notifikasi) async {
    Database db = await this.database;
    int count = await db.update(
      'notifikasi',
      notifikasi.toMap(),
      where: 'id_notifikasi=?',
      whereArgs: [notifikasi.idNotif],
    );
    return count;
  }

  Future<int> delete(int id) async {
    Database db = await this.database;
    int count = await db
        .delete('notifikasi', where: 'id_notifikasi=?', whereArgs: [id]);
    return count;
  }

  Future<List<Notifikasi>> getNotifikasi() async {
    var notifMapList = await select();
    int count = notifMapList.length;
    List<Notifikasi> notifList = List.empty(growable: true);
    for (int i = 0; i < count; i++) {
      notifList.add(Notifikasi.fromMap(notifMapList[i]));
    }
    return notifList;
  }
}
