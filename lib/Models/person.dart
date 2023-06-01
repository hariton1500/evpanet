import 'dart:convert';

class Person {
  String? guid;
  int id = -1;
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

  Person({required String guid}) {
    guid = guid;
  }
  
  load(Map<String, dynamic> user) {
    id = int.parse(user['id']);
    name = user['name'];
    balance = double.parse(user['extra_account']);
    password = user['clear_pass'];
    daysRemain = (int.parse(user['packet_secs']) / 60 / 60 / 24).round();
    endDate = user['packet_end'] ?? '00.00.0000 00:00';
    debt = double.parse(user['debt'] ?? 0.0);
    tarifName = user['tarif_name'];
    tarifSum = int.parse(user['tarif_sum'].toString());
    ip = user['real_ip'];
    street = user['street'];
    house = user['house'];
    flat = user['flat'];
    auto = user['auto_activation'] == '1';
    parentControl = user['flag_parent_control'] == '1';
    tarifs = List.from(user['allowed_tarifs']);
    dayPrice = user['days_price'];
  }


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
