import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:wifi_info_flutter/wifi_info_flutter.dart';

class User {
  late String guid;
  late int id;
  late String name;
  late double balance;
  late String endDate;
  late int daysRemain;
  late String login;
  late String password;
  double debt = 0.0;
  String tarifName = '';
  int tarifSum = 0;
  late String ip;
  late String street, house, flat;
  late bool auto, parentControl;
  late List<dynamic> tarifs = [];
  late int dayPrice;

  void load(Map user, String _guid) {
    guid = _guid;
    id = int.parse(user['id']);
    name = user['name'];
    balance = double.parse(user['extra_account']);
    login = user['login'];
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
    //print(user['allowed_tarifs']);
    tarifs.addAll(user['allowed_tarifs']);
    dayPrice = user['days_price'];
  }
}

class Abonent {
  List<String> guids = [];
  String lastApiMessage = '';
  bool lastApiErrorStatus = false;
  String device = '';
  List<User> users = [];
  int updatedUsers = 0;
  List<Map<String, dynamic>> messages = [];

  Future<void> clearAuthorize() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setStringList('guids', []);
  }

  Future<void> loadSavedData(String token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    guids = preferences.getStringList('guids') ?? [];
    //device = preferences.getString('deviceId') ?? '';
    device = token;
    print('[loadSavedData] guids: $guids');
    guids.forEach((guid) {
      if (preferences.containsKey(guid))
        fillAbonentWith(jsonDecode(preferences.getString(guid) ?? ''), guid);
    });
    (preferences.getStringList('messages') ?? []).forEach((codedMessage) {
      messages.add(jsonDecode(codedMessage));
      //print(messages.last);
    });
  }

  Future<void> saveGuidsList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setStringList('guids', guids);
    print('[saveGuidsList] guids: $guids');
  }

  Future<void> saveUser(Map user, String guid) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(guid, jsonEncode(user));
  }

  void fillAbonentWith(Map user, String guid) {
    print('[fillAbonentWith]');
    User _user = User();
    _user.load(user, guid);
    if (users.any((user) => user.guid == guid)) {
      //print('[fillAbonentWith] users contains guid: $guid');
      int index = users.indexWhere((user) => user.guid == guid);
      users[index] = _user;
      //print('[fillAbonentWith] users[$index] = ${_user.guid}');
    } else {
      print('[fillAbonentWith] users.add guid: $guid');
      users.add(_user);
    }
    //print('[fillAbonentWith] Loaded ${users.indexOf(_user) + 1} of ${users.length} users');
  }

  //Messages methods
  Future<void> saveMessage({required Map<String, dynamic> message}) async {
    print('[saveMessage]');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> messagesJSON = [];
    messagesJSON.addAll(preferences.getStringList('messages') ?? []);
    print('loaded ${messagesJSON.length} messages');
    messagesJSON.add(jsonEncode(message));
    preferences.setStringList('messages', messagesJSON);
    print('stored ${messagesJSON.length} messages');
  }

  //Network API methods
  Future<void> authorize(
      {required String mode,
      required String number,
      required int uid,
      required String token}) async {
    //final WifiInfo _wifiInfo = WifiInfo();
    http.Response _response;
    Map<String, String> _headers = {'token': '$token'};
    Map _body = {'number': '$number', 'uid': '$uid'};
    String _url = 'https://evpanet.com/api/apk/login/user';
    try {
      print('[authorize]');
      print('[post] ${Uri.parse(_url)}, headers: $_headers, body: $_body');
      _response =
          await http.post(Uri.parse(_url), headers: _headers, body: _body);
      if (_response.statusCode == 201) {
        var answer = jsonDecode(_response.body);
        print('[answer] (${_response.statusCode}) $answer');
        if (answer.runtimeType
            .toString()
            .startsWith('_InternalLinkedHashMap')) {
          if (Map.from(answer).containsKey('message')) {
            lastApiMessage = Map.from(answer)['message']['guids'].toString();
            //print(mode);
            print('current abonent guids: $guids');
            if (mode == 'new') {
              //print('is new');
              guids = List.from(answer['message']['guids']);
            }
            if (mode == 'add') {
              //print('is add');
              guids.addAll(List.from(answer['message']['guids']));
              guids = guids.toSet().toList();
            }
          }
          if (Map.from(answer).containsKey('error'))
            lastApiErrorStatus = Map.from(answer)['error'];
        }
      } else {
        guids = [];
        var answer = jsonDecode(_response.body);
        //print('[answer] (${_response.statusCode}) $answer');
        if (answer.runtimeType
            .toString()
            .startsWith('_InternalLinkedHashMap')) {
          if (Map.from(answer).containsKey('message'))
            lastApiMessage = Map.from(answer)['message'];
          if (Map.from(answer).containsKey('error'))
            lastApiErrorStatus = Map.from(answer)['error'];
        }
      }
    } on SocketException catch (error) {
      guids = [];
      lastApiErrorStatus = true;
      lastApiMessage = error.toString();
      print(error);
    } on HandshakeException {
      print('HandshakeException');
      //_wifiInfo.getWifiIP().then((value) => print(value));
      guids = [];
      lastApiErrorStatus = true;
      lastApiMessage = 'Ошибка на стороне сервера. Повторите попытку позже.';
    }
  }

  Future<void> getDataForGuidsFromServer(String token) async {
    lastApiErrorStatus = true;
    updatedUsers = 0;
    http.Response _response;
    Map<String, String> _headers = {'token': token};
    String url = '';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    guids = preferences.getStringList('guids') ?? [];
    print(
        '[getDataForGuidsFromServer] Start get data from server for guids: [$guids]');
    for (var guid in guids) {
      url = 'https://evpanet.com/api/apk/user/info/$guid';
      try {
        //print('[get] ${Uri.parse(url)}, headers: $_headers');
        _response = await http.get(Uri.parse(url), headers: _headers);
        updatedUsers += 1;
        if (_response.statusCode == 201) {
          var answer = jsonDecode(_response.body);
          //print(answer);
          if (answer.runtimeType
              .toString()
              .startsWith('_InternalLinkedHashMap')) {
            if (Map.from(answer).containsKey('message')) {
              lastApiMessage =
                  Map.from(answer)['message']['userinfo'].toString();
              fillAbonentWith(Map.from(answer)['message']['userinfo'], guid);
              saveUser(Map.from(answer)['message']['userinfo'], guid);
              print(
                  '[getDataForGuidsFromServer] updated from server for $guid');
            }
            if (Map.from(answer).containsKey('error'))
              lastApiErrorStatus = Map.from(answer)['error'];
          }
        } else {
          guids = [];
          var answer = jsonDecode(_response.body);
          if (answer.runtimeType
              .toString()
              .startsWith('_InternalLinkedHashMap')) {
            if (Map.from(answer).containsKey('message'))
              lastApiMessage = Map.from(answer)['message'];
            if (Map.from(answer).containsKey('error'))
              lastApiErrorStatus = Map.from(answer)['error'];
          }
        }
      } on SocketException catch (error) {
        lastApiErrorStatus = true;
        lastApiMessage = error.toString();
      } on HandshakeException {
        lastApiErrorStatus = true;
        lastApiMessage = 'Ошибка на стороне сервера. Повторите попытку позже.';
      }
    }
  }

  Future<void> changeSwitchParameters(
      {required String type, required String guid}) async {
    http.Response _response;
    Map<String, String> _headers = {'token': device};
    Map _body = {'guid': guid};
    String url = type == 'auto'
        ? 'https://evpanet.com/api/apk/user/auto_activation/'
        : 'https://evpanet.com/api/apk/user/parent_control/';
    print(
        '[changeSwitchParameters] Start change $type parameter on server for uid: []');
    try {
      print('[put] ${Uri.parse(url)}, headers: $_headers, body: $_body');
      _response = await http
          .put(Uri.parse(url), headers: _headers, body: _body)
          .timeout(Duration(seconds: 3));
      if (_response.statusCode == 201) {
        var answer = jsonDecode(_response.body);
        print(answer);
        if (answer.runtimeType
            .toString()
            .startsWith('_InternalLinkedHashMap')) {
          if (Map.from(answer).containsKey('message')) {
            lastApiMessage = Map.from(answer)['message']['value'].toString();
            if (type == 'auto')
              this.users.firstWhere((user) => user.guid == guid).auto =
                  !this.users.firstWhere((user) => user.guid == guid).auto;
            if (type == 'parent')
              this.users.firstWhere((user) => user.guid == guid).parentControl =
                  !this
                      .users
                      .firstWhere((user) => user.guid == guid)
                      .parentControl;
            //saveUser(Map.from(answer)['message']['userinfo'], guid);
          }
          if (Map.from(answer).containsKey('error'))
            lastApiErrorStatus = Map.from(answer)['error'];
        }
      } else {
        var answer = jsonDecode(_response.body);
        if (answer.runtimeType
            .toString()
            .startsWith('_InternalLinkedHashMap')) {
          if (Map.from(answer).containsKey('message'))
            lastApiMessage = Map.from(answer)['message'];
          if (Map.from(answer).containsKey('error'))
            lastApiErrorStatus = Map.from(answer)['error'];
        }
      }
    } on SocketException catch (error) {
      lastApiErrorStatus = true;
      lastApiMessage = error.toString();
    } on HandshakeException {
      lastApiErrorStatus = true;
      lastApiMessage = 'Ошибка на стороне сервера. Повторите попытку позже.';
    } on TimeoutException catch (_) {
      lastApiErrorStatus = true;
      Fluttertoast.showToast(msg: 'Отсутствует связь с сервером');
    }
  }

  Future<void> changeTarif(
      {required String tarifId, required String guid}) async {
    http.Response _response;
    Map<String, String> _headers = {'token': device};
    Map _body = {'tarif': tarifId, 'guid': guid};
    String url = 'https://evpanet.com/api/apk/user/tarif';
    print('[changeTarif] Start change tarif ($tarifId) of ($guid) on server');
    try {
      print('[patch] ${Uri.parse(url)}, headers: $_headers, body: $_body');
      _response = await http
          .patch(Uri.parse(url), headers: _headers, body: _body)
          .timeout(Duration(seconds: 3));
      if (_response.statusCode == 201) {
        var answer = jsonDecode(_response.body);
        print(answer);
        if (answer.runtimeType
            .toString()
            .startsWith('_InternalLinkedHashMap')) {
          if (Map.from(answer).containsKey('message')) {
            lastApiMessage = Map.from(answer)['message']['tarif_id'].toString();
          }
          if (Map.from(answer).containsKey('error'))
            lastApiErrorStatus = Map.from(answer)['error'];
        }
      } else {
        var answer = jsonDecode(_response.body);
        if (answer.runtimeType
            .toString()
            .startsWith('_InternalLinkedHashMap')) {
          if (Map.from(answer).containsKey('message'))
            lastApiMessage = Map.from(answer)['message'];
          if (Map.from(answer).containsKey('error'))
            lastApiErrorStatus = Map.from(answer)['error'];
        }
      }
    } on SocketException catch (error) {
      lastApiErrorStatus = true;
      lastApiMessage = error.toString();
    } on HandshakeException {
      lastApiErrorStatus = true;
      lastApiMessage = 'Ошибка на стороне сервера. Повторите попытку позже.';
    } on TimeoutException catch (_) {
      lastApiErrorStatus = true;
      Fluttertoast.showToast(msg: 'Отсутствует связь с сервером');
    }
  }

  Future<void> addDays({required int days, required String guid}) async {
    http.Response _response;
    Map<String, String> _headers = {'token': device};
    Map _body = {'days': days.toString(), 'guid': guid};
    String url = 'https://evpanet.com/api/apk/user/days/';
    print('[addDays] Start to add days ($days) to ($guid) on server');
    try {
      print('[put] ${Uri.parse(url)}, headers: $_headers, body: $_body');
      _response = await http
          .put(Uri.parse(url), headers: _headers, body: _body)
          .timeout(Duration(seconds: 3));
      if (_response.statusCode == 201) {
        var answer = jsonDecode(_response.body);
        print(answer);
        if (answer.runtimeType
            .toString()
            .startsWith('_InternalLinkedHashMap')) {
          if (Map.from(answer).containsKey('message')) {
            lastApiMessage = Map.from(answer)['message']['tarif_id'].toString();
          }
          if (Map.from(answer).containsKey('error'))
            lastApiErrorStatus = Map.from(answer)['error'];
        }
      } else {
        var answer = jsonDecode(_response.body);
        if (answer.runtimeType
            .toString()
            .startsWith('_InternalLinkedHashMap')) {
          if (Map.from(answer).containsKey('message'))
            lastApiMessage = Map.from(answer)['message'];
          if (Map.from(answer).containsKey('error'))
            lastApiErrorStatus = Map.from(answer)['error'];
        }
      }
    } on SocketException catch (error) {
      lastApiErrorStatus = true;
      lastApiMessage = error.toString();
    } on HandshakeException {
      lastApiErrorStatus = true;
      lastApiMessage = 'Ошибка на стороне сервера. Повторите попытку позже.';
    } on TimeoutException catch (_) {
      lastApiErrorStatus = true;
      Fluttertoast.showToast(msg: 'Отсутствует связь с сервером');
    }
  }

  Future<void> postMessageToProvider(
      {required String message, required String guid}) async {
    http.Response _response;
    Map<String, String> _headers = {'token': device};
    Map _body = {'message': message, 'guid': guid};
    String url = 'https://evpanet.com/api/apk/support/request';
    print(
        '[postMessageToProvider] Start to send ($message) from ($guid) to server');
    try {
      print('[post] ${Uri.parse(url)}, headers: $_headers, body: $_body');
      _response = await http
          .post(Uri.parse(url), headers: _headers, body: _body)
          .timeout(Duration(seconds: 5));
      if (_response.statusCode == 201) {
        var answer = jsonDecode(_response.body);
        print(answer);
        if (answer.runtimeType
            .toString()
            .startsWith('_InternalLinkedHashMap')) {
          if (Map.from(answer).containsKey('message')) {
            lastApiMessage = Map.from(answer)['message'];
          }
          if (Map.from(answer).containsKey('error'))
            lastApiErrorStatus = Map.from(answer)['error'];
        }
      } else {
        var answer = jsonDecode(_response.body);
        if (answer.runtimeType
            .toString()
            .startsWith('_InternalLinkedHashMap')) {
          if (Map.from(answer).containsKey('message'))
            lastApiMessage = Map.from(answer)['message'];
          if (Map.from(answer).containsKey('error'))
            lastApiErrorStatus = Map.from(answer)['error'];
        }
      }
    } on SocketException catch (error) {
      lastApiErrorStatus = true;
      lastApiMessage = error.toString();
    } on HandshakeException {
      lastApiErrorStatus = true;
      lastApiMessage = 'Ошибка на стороне сервера. Повторите попытку позже.';
    } on TimeoutException catch (_) {
      lastApiErrorStatus = true;
      Fluttertoast.showToast(msg: 'Отсутствует связь с сервером');
    }
  }

  Future<void> postGetPaymentNo(String token, {required String guid}) async {
    http.Response _response;
    Map<String, String> _headers = {'token': token};
    Map _body = {'guid': guid};
    String url = 'https://evpanet.com/api/apk/payment';
    print('[postPayment] Start to send payment from ($guid) to server');
    try {
      print('[post] ${Uri.parse(url)}, headers: $_headers, body: $_body');
      _response = await http
          .post(Uri.parse(url), headers: _headers, body: _body)
          .timeout(Duration(seconds: 5));
      if (_response.statusCode == 201) {
        var answer = jsonDecode(_response.body);
        print('[postPayment] $answer');
        if (answer.runtimeType
            .toString()
            .startsWith('_InternalLinkedHashMap')) {
          if (Map.from(answer).containsKey('message')) {
            lastApiMessage = answer['message']['payment_id'].toString();
          }
          if (Map.from(answer).containsKey('error'))
            lastApiErrorStatus = Map.from(answer)['error'];
        }
      } else {
        var answer = jsonDecode(_response.body);
        if (answer.runtimeType
            .toString()
            .startsWith('_InternalLinkedHashMap')) {
          if (Map.from(answer).containsKey('message'))
            lastApiMessage = Map.from(answer)['message'];
          if (Map.from(answer).containsKey('error'))
            lastApiErrorStatus = Map.from(answer)['error'];
        }
      }
    } on SocketException catch (error) {
      lastApiErrorStatus = true;
      lastApiMessage = error.toString();
    } on HandshakeException {
      lastApiErrorStatus = true;
      lastApiMessage = 'Ошибка на стороне сервера. Повторите попытку позже.';
    } on TimeoutException catch (_) {
      lastApiErrorStatus = true;
      Fluttertoast.showToast(msg: 'Отсутствует связь с сервером');
    }
  }

  Future<String> builtInPayment(String url) async {
    http.Response _response = await http.get(Uri.parse(url));
    var answer = jsonDecode(_response.body);
    if (answer is Map) {
      if (answer.containsKey('RetVal')) {
        if (answer['RetVal'] == 101) {}
      }
    }

    return _response.body;
  }
}




//все вспомогательные классы с их методами здесь

/*
* Описание принципов работы нового API.
*
* Основной адрес нового API: https://evpanet.com/api/apk/
* ***************************************************************
* Авторизация:
*   URL: https://evpanet.com/api/apk/login/user
*   Method: POST
*   Header:
*     - key = token
*     - value = токен от гугла
*   Body:
*     - number = номер телефона в формате +7....
*     - uid = ID абонента
*   Response:
*     - формат: JSON
*     - данные: массив GUID
* ***************************************************************
* Получение данных абонента:
*   URL: https://evpanet.com/api/apk/user/info/<GUID>
*   Method: GET
*   Header:
*     - key = token
*     - value = токен от гугла
*   Response:
*     - формат: JSON
*     - данные: данные об абоненте, и доступные тарифные планы
* ***************************************************************
* Изменение флагов автоактивации и родительского контроля:
*   URLS:
*     - https://evpanet.com/api/apk/user/parent_control/  для родительского контроля
*     - https://evpanet.com/api/apk/user/auto_activation/ для автоактивации
*   Method: PUT
*   Header:
*     - key = token
*     - value = токен от гугла
*   Body:
*     - формат = JSON {"guid":"<GUID>"}
*   Response:
*     - формат: JSON
*     - данные: текущее состояние флага (1 или 0)
*
* ***************************************************************
* Добавление ремонта или коментария к ремонту
*   URL: https://evpanet.com/api/apk/support/request
*   Method: POST
*   Header:
*     - key = token
*     - value = токен от гугла
*   Body:
*     - message = сообщение от абонента
*     - guid
*   Response:
*     - формат: JSON
*     - ответ: есть ли ошибка и текст, или сообщения или ошибки
**
* ***************************************************************
* Изменение пакета или активация нового
*   URL: https://evpanet.com/api/apk/user/tarif
*   Method: PATCH
*   Header:
*     - key = token
*     - value = токен от гугла
*   Body:
*     - формат = JSON {"tarif":"<tarifid>","guid":"<GUID>"}
*   Response:
*     - формат: JSON
*     - данные:
*         "packet_secs",
*         "tarif_id",
*         "tarif_sum",
*         "tarif_name"
* ***************************************************************
* Добавление дней
*   URL: https://evpanet.com/api/apk/user/days/
*   Method: PUT
*   Header:
*     - key = token
*     - value = токен от гугла
*   Body:
*     - формат = JSON {"guid":"<GUID>","days":<DAYS>}
*   Response:
*     - формат: JSON
*     - данные:
*         "days": <days>,
*         "packet_secs": <packet_secs>,
*         "extra_account": <extra_account>
*
* ***************************************************************
* */
