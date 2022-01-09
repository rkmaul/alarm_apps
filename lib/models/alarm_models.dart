class Alarm {
  int? id;
  String? title;
  DateTime? alarmDateTime;
  String? dateTime;
  String? uniqueId;
  String? statusAlarm;

  Alarm(
      {this.id,
      this.title,
      this.alarmDateTime,
      this.dateTime,
      this.uniqueId,
      this.statusAlarm});

  factory Alarm.fromMap(Map<String, dynamic> json) => Alarm(
        id: json["id"],
        title: json["title"],
        alarmDateTime: DateTime.parse(json["alarmDateTime"]),
        dateTime: json['dateTime'],
        uniqueId: json['uniqueId'],
        statusAlarm: json["statusAlarm"],
      );
  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "alarmDateTime": alarmDateTime?.toIso8601String(),
        "dateTime": dateTime,
        "uniqueId": uniqueId,
        "statusAlarm": statusAlarm,
      };
}
