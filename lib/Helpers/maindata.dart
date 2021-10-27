import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  List<Map<String, dynamic>> messages = [];

  Future<void> clearAuthorize() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setStringList('guids', []);
  }

  Future<void> loadSavedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    guids = preferences.getStringList('guids') ?? [];
    device = preferences.getString('deviceId') ?? '';
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

  Future<void> saveData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setStringList('guids', guids);
    //preferences.setString('users', jsonEncode(users));
    print('[saveData] guids: $guids');
    //print('[saveData] users: ${jsonEncode(users.first)}');
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
      print('[fillAbonentWith] users contains guid: $guid');
      int index = users.indexWhere((user) => user.guid == guid);
      users[index] = _user;
      print('[fillAbonentWith] users[$index] = ${_user.guid}');
    } else {
      print('[fillAbonentWith] users.add guid: $guid');
      users.add(_user);
    }
    print(
        '[fillAbonentWith] Loaded ${users.indexOf(_user) + 1} of ${users.length} users');
  }

  //Messages methods
  Future<void> saveMessage({required Map<String, dynamic> message}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> messagesJSON = [];
    messagesJSON.addAll(preferences.getStringList('messages') ?? []);
    messagesJSON.add(jsonEncode(message));
    preferences.setStringList('messages', messagesJSON);
  }

  //Network API methods
  Future<void> authorize(
      {required String mode,
      required String number,
      required int uid,
      required String token}) async {
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
        //print('[answer] (${_response.statusCode}) $answer');
        if (answer.runtimeType
            .toString()
            .startsWith('_InternalLinkedHashMap')) {
          if (Map.from(answer).containsKey('message')) {
            lastApiMessage = Map.from(answer)['message']['guids'].toString();
            //print(mode);
            //print('current abonent guids: $guids');
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
    } on HandshakeException {
      guids = [];
      lastApiErrorStatus = true;
      lastApiMessage = 'Ошибка на стороне сервера. Повторите попытку позже.';
    }
  }

  Future<void> getDataForGuidsFromServer() async {
    http.Response _response;
    Map<String, String> _headers = {'token': device};
    String url = '';
    print(
        '[getDataForGuidsFormServer] Start get data from server for guids: [$guids]');
    guids.forEach((guid) async {
      url = 'https://evpanet.com/api/apk/user/info/$guid';
      try {
        //print('[get] ${Uri.parse(url)}, headers: $_headers');
        _response = await http.get(Uri.parse(url), headers: _headers);
        if (_response.statusCode == 201) {
          var answer = jsonDecode(_response.body);
          //print(answer);
          if (answer.runtimeType
              .toString()
              .startsWith('_InternalLinkedHashMap')) {
            if (Map.from(answer).containsKey('message')) {
              lastApiMessage =
                  Map.from(answer)['message']['userinfo'].toString();
              //users.clear();
              fillAbonentWith(Map.from(answer)['message']['userinfo'], guid);
              saveUser(Map.from(answer)['message']['userinfo'], guid);
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
    });
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
}
