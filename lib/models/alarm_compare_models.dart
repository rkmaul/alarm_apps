class AlarmCompare {
  int? idCompare;
  String? titleCompare;
  String? uniqueIdCompare;

  AlarmCompare({this.idCompare, this.titleCompare, this.uniqueIdCompare});

  factory AlarmCompare.fromMap(Map<String, dynamic> json) => AlarmCompare(
      idCompare: json["idCompare"],
      titleCompare: json["titleCompare"],
      uniqueIdCompare: json['uniqueIdCompare']);

  Map<String, dynamic> toMap() => {
        "idCompare": idCompare,
        "titleCompare": titleCompare,
        "uniqueIdCompare": uniqueIdCompare
      };
}
