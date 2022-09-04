import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  String lastApiMessage = '';
  List<String> guids = [];
  dynamic lastApiErrorStatus = {};
  int updatedUsers = 0;
  String token = '';

  Api({required this.token});

  Future<void> authorize({required String phone, required int uid}) async {
    //final WifiInfo _wifiInfo = WifiInfo();
    http.Response _response;
    Map<String, String> _headers = {'token': '$token'};
    Map _body = {'number': '$phone', 'uid': '$uid'};
    String _url = 'https://evpanet.com/api/apk/login/user';
    try {
      print('[authorize]');
      print('[post] ${Uri.parse(_url)}, headers: $_headers, body: $_body');
      _response =
          await http.post(Uri.parse(_url), headers: _headers, body: _body);
      if (_response.statusCode == 201) {
        var answer = jsonDecode(_response.body);
        print('[answer] (${_response.statusCode}) $answer');
        if (answer is Map) {
          if (Map.from(answer).containsKey('message')) {
            lastApiMessage = Map.from(answer)['message']['guids'].toString();
            //print(mode);
            print('current abonent guids: $guids');
            guids.addAll(List.from(answer['message']['guids']));
            guids = guids.toSet().toList();
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
        print('[get] ${Uri.parse(url)}, headers: $_headers');
        _response = await http.get(Uri.parse(url), headers: _headers);
        updatedUsers += 1;
        print(_response.body);
        print(_response.statusCode);
        if (_response.statusCode == 201) {
          var answer = jsonDecode(_response.body);
          print(answer);
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
          print(answer);
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

  Future<void> changeSwitchParameters(String token,
      {required String type, required String guid}) async {
    http.Response _response;
    Map<String, String> _headers = {'token': token};
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

  Future<void> changeTarif(String token,
      {required String tarifId, required String guid}) async {
    http.Response _response;
    Map<String, String> _headers = {'token': token};
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

  Future<void> addDays(String token,
      {required int days, required String guid}) async {
    http.Response _response;
    Map<String, String> _headers = {'token': token};
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

  Future<void> postMessageToProvider(String token,
      {required String message, required String guid}) async {
    http.Response _response;
    Map<String, String> _headers = {'token': token};
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
