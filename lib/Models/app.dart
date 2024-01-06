//import 'package:evpanet/Helpers/api.dart';
import 'package:evpanet/Models/message.dart';
import 'package:evpanet/Models/person.dart';

class AppData {
  String token = '';
  List<String> guids = [];
  List<Person> subscribers = [];
  List<Note> messages = [];
  //Api api = Api(token: token);
}
