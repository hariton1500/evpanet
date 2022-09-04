import 'package:evpanet/Helpers/api.dart';
import 'package:evpanet/Models/message.dart';
import 'package:evpanet/Models/person.dart';

class AppData {
  List<String> guid = [];
  List<Person> subscribers = [];
  List<Note> messages = [];
  Api api = Api(token: '');

  String token;
}
