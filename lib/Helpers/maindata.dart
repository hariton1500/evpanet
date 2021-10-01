import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Abonent {
  late List<String> guids;
  String lastApiMessage = '';
  late bool lastApiErrorStatus;

  Future<void> authorize(
      {required String number, required int uid, required String token}) async {
    http.Response _response;
    Map<String, String> _headers = {'token': '$token'};
    Map _body = {'number': '$number', 'uid': '$uid'};
    String _url = 'https://evpanet.com/api/apk/login/user';
    try {
      _response =
          await http.post(Uri.parse(_url), headers: _headers, body: _body);
      if (_response.statusCode == 201) {
        var answer = jsonDecode(_response.body);
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

  Future<void> loadSavedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    guids = preferences.getStringList('guids') ?? [];
  }
}
