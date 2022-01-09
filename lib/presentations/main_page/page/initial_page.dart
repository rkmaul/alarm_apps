import 'package:bibit_test_apps/helper/alarm_helper.dart';
import 'package:bibit_test_apps/main.dart';
import 'package:bibit_test_apps/models/alarm_compare_models.dart';
import 'package:bibit_test_apps/models/alarm_models.dart';
import 'package:bibit_test_apps/presentations/main_page/widget/alarm_widget.dart';
import 'package:bibit_test_apps/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class InitialPage extends StatefulWidget {
  InitialPage({Key? key}) : super(key: key);
  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  AlarmHelper _alarmHelper = AlarmHelper();

  TooltipBehavior? _tooltip;

  List<ChartData>? _chartData = [];
  List<Alarm>? _alarms = [];
  List<AlarmCompare>? _alarmsCompare = [];
  List<double>? _timeOpenNotification = [];

  @override
  void initState() {
    super.initState();
    _setup();
    _tooltip = TooltipBehavior(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AlarmPage(),
    );
  }

  loadAlarmsCompare(String uniqueId) async {
    Future<List<Alarm>>? _alarmsAsync;
    Future<List<AlarmCompare>>? _alarmsCompareAsync;

    double? totalMinutesCompare;
    double? totalMinutes;

    List<double>? listTotalMinutes = [];
    List<double>? listTotalMinutesCompare = [];

    _alarmsCompareAsync =
        _alarmHelper.getAlarmsCompare() as Future<List<AlarmCompare>>?;
    _alarmsCompare = await _alarmsCompareAsync;

    _alarmsAsync = _alarmHelper.getAlarms() as Future<List<Alarm>>?;
    _alarms = await _alarmsAsync;

    int i;
    int x;

    _alarmsCompare!.forEach((element) {
      List<String> parts = element.titleCompare.toString().split(':');
      totalMinutesCompare =
          (int.parse(parts[0].padLeft(2, '0')).toDouble() * 60) +
              int.parse(parts[1].padLeft(2, '0')).toDouble();
      print(totalMinutesCompare);
      listTotalMinutesCompare.add(totalMinutesCompare!);
    });

    // ignore: unnecessary_null_comparison
    if (_alarms!.length != 0 && _alarms != null) {
      _alarms!.forEach((element) {
        List<String> parts = element.dateTime.toString().split(':');
        totalMinutes = (int.parse(parts[0].padLeft(2, '0')).toDouble() * 60) +
            int.parse(parts[1].padLeft(2, '0')).toDouble();
        print(totalMinutes);
        listTotalMinutes.add(totalMinutes!);
      });
    }

    for (i = 0; i < listTotalMinutes.length; i++) {
      _timeOpenNotification!
          .add(listTotalMinutesCompare[i] - listTotalMinutes[i]);
    }

    for (x = 0; x < _timeOpenNotification!.length; x++) {
      _chartData!.add(
        ChartData(_alarms![x].dateTime!, _timeOpenNotification![x]),
      );
    }

    WidgetsBinding.instance!
        .addPostFrameCallback((_) => _showStartDialog(uniqueId));
  }

  void insertDateTimeNow(
    String uniqueId,
  ) {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('HH:mm');
    final String formatted = formatter.format(now);

    var alarmInfoCompare =
        AlarmCompare(titleCompare: formatted, uniqueIdCompare: uniqueId);
    _alarmHelper.insertAlarmCompare(alarmInfoCompare);
    loadAlarmsCompare(uniqueId);
  }

  var initializationSettingsAndroid =
      const AndroidInitializationSettings('bibitlogo');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int? id, String? title, String? body, String? payload) async {
        print(id);
      });

  _setup() async {
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (
      String? payload,
    ) async {
      if (payload != null) {
        _alarmHelper
            .initializeDatabaseCompare()
            .then((value) => insertDateTimeNow(payload));
        debugPrint('notification payload: $payload');
        // insertDateTimeNow(payload);
      }
    });
  }

  Future<void> _showStartDialog(String payload) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Open Alarm Chart',
            style: const TextStyle(
                fontFamily: 'notoserif',
                fontWeight: FontWeight.w300,
                color: Colors.white,
                fontSize: 20),
          ),
          content: Builder(builder: (context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis:
                          NumericAxis(minimum: 0, maximum: 10, interval: 1),
                      tooltipBehavior: _tooltip,
                      series: <ChartSeries<ChartData, String>>[
                        ColumnSeries<ChartData, String>(
                            dataSource: _chartData!,
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y,
                            name: 'Open Notif Time',
                            color: const Color.fromRGBO(8, 142, 255, 1))
                      ])
                ],
              )),
            );
          }),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Clear Data',
                style: notoSerifDefaultBlack,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Done',
                style: notoSerifDefaultBlack,
              ),
              onPressed: () {
                _timeOpenNotification!.clear();
                _alarms!.clear();
                _alarmsCompare!.clear();
                _chartData!.clear();
                print(_timeOpenNotification);
                print(_alarms);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);

  final String x;
  final double y;
}
// ignore_for_file: unused_field, prefer_const_constructors_in_immutables, prefer_final_fields, prefer_const_constructors, unnecessary_cast, avoid_function_literals_in_foreach_calls, prefer_is_empty, avoid_print, unnecessary_const, sized_box_for_whitespace
