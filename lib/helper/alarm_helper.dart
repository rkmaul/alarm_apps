import 'package:bibit_test_apps/models/alarm_compare_models.dart';
import 'package:bibit_test_apps/models/alarm_models.dart';
import 'package:sqflite/sqflite.dart';

const String? tableAlarm = 'alarm';
const String? columnId = 'id';
const String? columnTitle = 'title';
const String? columnDateTime = 'alarmDateTime';
const String? dateTimeColumn = 'dateTime';
const String? uniqueIdColumn = 'uniqueId';
const String? statusAlarmColumn = 'statusAlarm';

const String tableAlarmCompare = 'alarmCompare';
const String columnIdCompare = 'idCompare';
const String columnTitleCompare = 'titleCompare';
const String uniqueIdColumnCompare = 'uniqueIdCompare';

class AlarmHelper {
  static Database? _database;
  static Database? _databaseCompare;
  static AlarmHelper? _alarmHelper;

  AlarmHelper._createInstance();
  factory AlarmHelper() {
    if (_alarmHelper == null) {
      _alarmHelper = AlarmHelper._createInstance();
    }
    return _alarmHelper!;
  }
  Future<Database> get databaseCompare async {
    print('Database Compare');
    if (_databaseCompare == null) {
      _databaseCompare = await initializeDatabaseCompare();
    }
    return _databaseCompare!;
  }

  Future<Database> get database async {
    print('Database');
    if (_database == null) {
      _database = await initializeDatabase();
      _databaseCompare = await initializeDatabaseCompare();
    }
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    var dir = await getDatabasesPath();
    var path = dir + "alarm.db";

    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          create table $tableAlarm ( 
          $columnId integer primary key autoincrement, 
          $columnTitle text not null,
          $columnDateTime text not null,
          $dateTimeColumn text not null,
          $uniqueIdColumn text not null,
          $statusAlarmColumn text not null)
        ''');
      },
    );
    return database;
  }

  Future<Database> initializeDatabaseCompare() async {
    var dir = await getDatabasesPath();
    var path = dir + "alarmCompare.db";

    var databaseCompare = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          create table $tableAlarmCompare ( 
          $columnIdCompare integer primary key autoincrement, 
          $columnTitleCompare text not null,
          $uniqueIdColumnCompare text not null)
        ''');
      },
    );
    return databaseCompare;
  }

  void insertAlarm(Alarm alarmInfo) async {
    var db = await this.database;
    var result = await db.insert(tableAlarm!, alarmInfo.toMap());
    print('result : $result');
  }

  void insertAlarmCompare(AlarmCompare alarmInfoCompare) async {
    var db = await this.databaseCompare;
    var result = await db.insert(tableAlarmCompare, alarmInfoCompare.toMap());
    print('resultCompare : $result');
  }

  Future<List<Alarm>> getAlarms() async {
    List<Alarm> _alarms = [];

    var db = await this.database;
    var result = await db.query(tableAlarm!);
    result.forEach((element) {
      var alarmInfo = Alarm.fromMap(element);
      _alarms.add(alarmInfo);
    });

    return _alarms;
  }

  Future<List<AlarmCompare>> getAlarmsCompare() async {
    List<AlarmCompare> _alarmsCompare = [];
    List<Alarm> _alarms = [];

    //Alarm compare codes
    var dbCompare = await this.databaseCompare;
    var resultCompare = await dbCompare.query(tableAlarmCompare);
    resultCompare.forEach((element) {
      var alarmInfoCompare = AlarmCompare.fromMap(element);
      _alarmsCompare.add(alarmInfoCompare);
    });

    //Alarm codes
    var db = await this.database;
    var result = await db.query(tableAlarm!);
    result.forEach((element) {
      var alarmInfo = Alarm.fromMap(element);
      _alarms.add(alarmInfo);
    });

    return _alarmsCompare;
  }

  Future<int> delete(String id) async {
    var db = await this.database;
    var result = await db
        .delete(tableAlarm!, where: '$uniqueIdColumn = ?', whereArgs: [id]);
    print('result deleted : $result');
    return result;
  }

  Future<int> deleteCompare(String id) async {
    var db = await this.databaseCompare;
    var result = await db.delete(tableAlarmCompare,
        where: '$uniqueIdColumnCompare = ?', whereArgs: [id]);
    print('result deletedCompare : $result');
    return result;
  }
}
// ignore_for_file: unused_field, prefer_conditional_assignment, prefer_const_constructors_in_immutables, prefer_final_fields, prefer_const_constructors, unnecessary_cast, avoid_function_literals_in_foreach_calls, prefer_is_empty, avoid_print, unnecessary_const, sized_box_for_whitespace,  unnecessary_this, curly_braces_in_flow_control_structures
