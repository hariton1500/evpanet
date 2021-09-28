import 'package:http/http.dart' as http;

class Abonent {
  late List<String> guids;

  Future<void> authorize(
      {required String number, required int uid, required String token}) async {
    http.Response _response;
    Map<String, String> _headers = {'token': '$token'};
    Map _body = {'number': '$number', 'uid': '$uid'};
    String _url = 'https://evpanet.com/api/apk/login/user';
    http.post(Uri.parse(_url), headers: _headers, body: _body).then((value) {
      _response = value;
      print(_response.statusCode);
      print(_response.body);
    });
  }
}
