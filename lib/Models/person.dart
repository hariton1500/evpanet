import 'dart:convert';

class Person {
  String? guid;
  int? id;
  String name = '';
  double balance = 0.0;
  String endDate = '';
  int daysRemain = 0;
  String password = '';
  double debt = 0.0;
  String tarifName = '';
  int tarifSum = 0;
  String ip = '';
  String street = '', house = '', flat = '';
  bool auto = false, parentControl = false;
  List<dynamic> tarifs = [];
  int dayPrice = 0;

  Person.fromJson(Map<String, dynamic> json) {
    guid = json['guid'] ?? '';
    id = json['id'] ?? -1;
    name = json['name'] ?? '';
    balance = json[''] ?? 0.0;
    endDate = json['endDate'] ?? '';
    daysRemain = json['daysRemain'] ?? 0;
    password = json['password'] ?? '';
    debt = json['debt'] ?? 0.0;
    tarifName = json['tarifName'] ?? '';
    tarifSum = json['tarifSum'] ?? 0;
    ip = json['ip'] ?? '';
    street = json['street'] ?? '';
    house = json['house'] ?? '';
    flat = json['flat'] ?? '';
    auto = json['auto'] ?? false;
    parentControl = json['parentControl'] ?? false;
    tarifs = json['tarifs'] ?? [];
    dayPrice = json['dayPrice'] ?? 0;
  }

  String toJson() {
    return json.encode({
      'guid': guid,
      'id': id,
      'name': name,
      'balance': balance,
      'endDate': endDate,
      'daysRemain': daysRemain,
      'password': password,
      'debt': debt,
      'tarifName': tarifName,
      'tarifSum': tarifSum,
      'ip': ip,
      'street': street,
      'house': house,
      'flat': flat,
      'auto': auto,
      'parentControl': parentControl,
      'tarifs': tarifs,
      'dayPrice': dayPrice,
    });
  }
}
