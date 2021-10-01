import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class User {
  late int id;
  late String name;
  late double balance;
  late String endDate;
  late int daysRemain;
  late String login;
  late String password;
}

class Abonent {
  List<String> guids = [];
  String lastApiMessage = '';
  bool lastApiErrorStatus = false;
  String device = '';
  List<User> users = [];

  Future<void> loadSavedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    guids = preferences.getStringList('guids') ?? [];
    device = preferences.getString('deviceId') ?? '';
    print('[loadSavedData] guids: $guids');
  }

  Future<void> saveData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setStringList('guids', guids);
    print('[saveData] guids: $guids');
  }

  void fillAbonentWith(Map user) {
    print('[fillAbonentWith] $user');
    User _user = User();
    _user.id = int.parse(user['id']);
    _user.name = user['name'];
    _user.balance = double.parse(user['extra_account']);
    _user.login = user['login'];
    _user.password = user['clear_pass'];
    _user.daysRemain = (int.parse(user['packet_secs']) / 60 / 60 / 24).round();
    users.add(_user);
    print('[getDataForGuidsFromServer] Loaded ${users.length} users');
  }

  Future<void> authorize(
      {required String number, required int uid, required String token}) async {
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
            guids = List.from(Map.from(answer)['message']['guids']);
          }
          if (Map.from(answer).containsKey('error'))
            lastApiErrorStatus = Map.from(answer)['error'];
        }
      } else {
        guids = [];
        var answer = jsonDecode(_response.body);
        print('[answer] (${_response.statusCode}) $answer');
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
              fillAbonentWith(Map.from(answer)['message']['userinfo']);
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
}
