import 'dart:async';
import 'dart:math';
import 'package:bibit_test_apps/helper/alarm_helper.dart';
import 'package:bibit_test_apps/main.dart';
import 'package:bibit_test_apps/models/alarm_models.dart';
import 'package:bibit_test_apps/presentations/main_page/widget/digital_clock_widget.dart';
import 'package:bibit_test_apps/utils/loader.dart';
import 'package:bibit_test_apps/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'clock_widget.dart';

class AlarmPage extends StatefulWidget {
  AlarmPage({Key? key}) : super(key: key);
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  String formattedDate = DateFormat('EEE, d MMM').format(DateTime.now());
  String? _alarmTimeString;
  String? _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  DateTime? _alarmTime;

  AlarmHelper _alarmHelper = AlarmHelper();

  Future<List<Alarm>>? _alarms;

  List<Alarm>? _currentAlarms;

  Random? _rnd = Random();

  @override
  void initState() {
    super.initState();
    _alarmTime = DateTime.now();
    _alarmHelper.initializeDatabase().then((value) {
      print('== Initial Database ==');
      loadAlarms();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DigitalClockWidget(),
                _dateWidget(),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Align(
              alignment: Alignment.center,
              child: ClockPage(
                size: MediaQuery.of(context).size.height / 4,
              ),
            ),
            _alarmText(),
            FutureBuilder<List<Alarm>>(
              future: _alarms,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _currentAlarms = snapshot.data;
                  return ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: snapshot.data!.map<Widget>((alarm) {
                      var alarmTime =
                          DateFormat('hh:mm aa').format(alarm.alarmDateTime!);

                      return Container(
                        margin: EdgeInsets.only(bottom: 32),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue[200],
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              alarm.title!,
                              style: notoSerifDefaultWhite,
                            ),
                            Text(
                              'Alarm',
                              style: notoSerifDefaultWhite,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  alarmTime,
                                  style: notoSerif24WhiteBold,
                                ),
                                IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.white,
                                    onPressed: () {
                                      deleteAlarm(alarm.uniqueId!);
                                    }),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).followedBy([
                      if (_currentAlarms!.length < 5)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: FlatButton(
                            padding: EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            onPressed: () {
                              _alarmTimeString =
                                  DateFormat('HH:mm').format(DateTime.now());
                              showModalBottomSheet(
                                useRootNavigator: true,
                                context: context,
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                ),
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, setModalState) {
                                      return Container(
                                        height: MediaQuery.of(context)
                                                .copyWith()
                                                .size
                                                .height /
                                            3.5,
                                        padding: EdgeInsets.all(32),
                                        child: Column(
                                          children: [
                                            FlatButton(
                                              onPressed: () async {
                                                var selectedTime =
                                                    await showTimePicker(
                                                  context: context,
                                                  initialTime: TimeOfDay.now(),
                                                );
                                                if (selectedTime != null) {
                                                  final now = DateTime.now();
                                                  var selectedDateTime =
                                                      DateTime(
                                                          now.year,
                                                          now.month,
                                                          now.day,
                                                          selectedTime.hour,
                                                          selectedTime.minute);
                                                  _alarmTime = selectedDateTime;
                                                  setModalState(() {
                                                    _alarmTimeString =
                                                        DateFormat('HH:mm')
                                                            .format(
                                                                selectedDateTime);
                                                  });
                                                }
                                              },
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: 500,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Set Clock :',
                                                          style: TextStyle(
                                                              fontSize: 32),
                                                        ),
                                                        Text(_alarmTimeString!,
                                                            style:
                                                                notoSerif32BlackBold),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 16,
                                                  ),
                                                  Container(
                                                    width: 500,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Alarm Title :',
                                                          style:
                                                              notoSerif14BlackBold,
                                                        ),
                                                        Text(
                                                          'Alarm Title',
                                                          style:
                                                              notoSerif14BlackBold,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 16,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            _buttonSaveWidget(),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            child: _addAlarmWidget(),
                          ),
                        )
                      else
                        Container(),
                    ]).toList(),
                  );
                }
                return Loader();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateWidget() {
    return Text(
      formattedDate,
      style: notoSerif20White,
    );
  }

  Widget _alarmText() {
    return Text(
      'Alarm',
      style: notoSerif24WhiteBold,
    );
  }

  Widget _addAlarmWidget() {
    return Column(
      children: <Widget>[
        Icon(
          Icons.add_alarm_outlined,
          size: 32,
          color: Colors.blue[200],
        ),
        SizedBox(height: 8),
        Text(
          'Add Alarm',
          style: notoSerifDefaultBlack,
        ),
      ],
    );
  }

  Widget _buttonSaveWidget() {
    return InkWell(
      child: Container(
        width: 100,
        decoration: BoxDecoration(
            color: Colors.blue[200], borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.alarm,
                color: Colors.white,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                'Save',
                style: notoSerifDefaultWhite,
              ),
            ],
          ),
        ),
      ),
      onTap: onSaveAlarm,
    );
  }

  void loadAlarms() {
    _alarms = _alarmHelper.getAlarms() as Future<List<Alarm>>?;
    if (mounted) setState(() {});
  }

  void deleteAlarm(String id) {
    _alarmHelper.delete(id);
    _alarmHelper.deleteCompare(id);
    loadAlarms();
  }

  void scheduleAlarm(DateTime scheduledNotificationDateTime, Alarm alarmInfo,
      String uniqueId) async {
    print(uniqueId);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_notif',
      'Channel for Alarm notification',
      icon: 'bibitlogo',
      largeIcon: DrawableResourceAndroidBitmap('bibitlogo'),
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        sound: 'a_long_cold_sting.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(
        0,
        'Test Bibit Alarm',
        alarmInfo.title,
        scheduledNotificationDateTime,
        platformChannelSpecifics,
        payload: uniqueId);
  }

  void onSaveAlarm() {
    DateTime scheduleAlarmDateTime;
    if (_alarmTime!.isAfter(DateTime.now()))
      scheduleAlarmDateTime = _alarmTime!;
    else
      scheduleAlarmDateTime = _alarmTime!.add(Duration(days: 1));

    final DateFormat formatter = DateFormat('HH:mm');
    final String formatted = formatter.format(scheduleAlarmDateTime);
    print(formatted);
    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => _chars!.codeUnitAt(_rnd!.nextInt(_chars!.length))));
    var value = getRandomString(5);
    var alarmInfo = Alarm(
        alarmDateTime: scheduleAlarmDateTime,
        title: 'Alarm Title',
        dateTime: formatted,
        uniqueId: value,
        statusAlarm: 'false');

    _alarmHelper.insertAlarm(alarmInfo);

    scheduleAlarm(scheduleAlarmDateTime, alarmInfo, value);
    Navigator.pop(context);
    loadAlarms();
  }
}
// ignore_for_file:deprecated_member_use, prefer_const_literals_to_create_immutables, curly_braces_in_flow_control_structures, unused_field, prefer_const_constructors_in_immutables, prefer_final_fields, prefer_const_constructors, unnecessary_cast, avoid_function_literals_in_foreach_calls, prefer_is_empty, avoid_print, unnecessary_const, sized_box_for_whitespace
