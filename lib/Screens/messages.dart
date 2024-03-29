import 'dart:convert';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:evpanet/Helpers/maindata.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key, required this.abonent}) : super(key: key);

  //final List<String> messagesStrings;
  final Abonent abonent;

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  List<Map<String, dynamic>> messages = [];
  List<String>? messagesEncoded;

  @override
  void initState() {
    load();
    super.initState();
  }

  Future<void> load() async {
    print('[loading messages]');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    messagesEncoded = preferences.getStringList('messages') ?? [];
    print('loaded ${messagesEncoded!.length} messages');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(245, 246, 248, 1.0),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: AppBar(
            iconTheme: const IconThemeData(
                color: const Color.fromRGBO(72, 95, 113, 1.0)),
            titleSpacing: 0.0,
            backgroundColor: const Color.fromRGBO(245, 246, 248, 1.0),
            title: Text(
              'Сообщения',
              style: const TextStyle(
                color: const Color.fromRGBO(72, 95, 113, 1.0),
                fontSize: 24.0,
              ),
            ),
          ),
        ),
        body: messagesEncoded != null && messagesEncoded!.length > 0
            ? ListView.builder(
                itemCount: messagesEncoded!.length,
                itemBuilder: (bc, index) {
                  String _title =
                      //jsonDecode(widget.messagesStrings[index])['title'];
                      jsonDecode(messagesEncoded![index])['title'];
                  String _body =
                      //jsonDecode(widget.messagesStrings[index])['message'];
                      jsonDecode(messagesEncoded![index])['message'];
                  String _date =
                      //jsonDecode(widget.messagesStrings[index])['timestamp'];
                      jsonDecode(messagesEncoded![index])['timestamp'];
                  //bool isFiltered;

                  //filtersState!.forEach((state) { });
                  return Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: Container(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        //color: Color.fromRGBO(245, 246, 248, 1.0),
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: [
                              0.2,
                              1.0
                            ],
                            colors: [
                              Color.fromRGBO(68, 98, 124, 1),
                              Color.fromRGBO(10, 33, 51, 1)
                            ]),
                      ),
                      child: ListTile(
                          key: Key(index.toString()),
                          onLongPress: () => showActions(context, index),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          tileColor: index.isEven ? Colors.white : Colors.white,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _date.split(' ')[0],
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(_date.split(' ')[1],
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          leading: Icon(
                            _title.contains('Мой EvpaNet')
                                ? Icons.question_answer_outlined
                                : Icons.warning_outlined,
                            color: Colors.white,
                          ),
                          title: Text(_title,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Linkify(
                              onOpen: (link) async {
                                if (await canLaunchUrl(Uri.parse(link.url))) {
                                  await launchUrl(Uri.parse(link.url));
                                } else {
                                  print('Could not launch $link');
                                }
                              },
                              text: _body,
                              linkStyle: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.normal,
                                  color: Colors.white70),
                            ),
                          )),
                    ),
                  );
                })
            : Container());
  }

  void showActions(BuildContext context, int index) {
    showDialog(
        context: context,
        builder: (bc) => AlertDialog(
              content: Text('Удалить?'),
              actions: [
                TextButton(
                    onPressed: () async {
                      setState(() {
                        messagesEncoded?.removeAt(index);
                      });
                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      preferences.setStringList('messages', messagesEncoded!);
                      Navigator.pop(context);
                    },
                    child: Text('Да')),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Отмена')),
              ],
            ));
  }
}

class Filters extends StatefulWidget {
  const Filters({Key? key, required this.users, required this.onFiltersDone})
      : super(key: key);

  final List<User> users;
  final Function onFiltersDone;

  @override
  _FiltersState createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  Map<int, bool> filterStates = {};

  @override
  void initState() {
    for (var i = 0; i < widget.users.length; i++) {
      filterStates[widget.users[i].id] = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.users.length,
        itemBuilder: (bc, index) {
          return Row(
            children: [
              Checkbox(
                  value: filterStates[widget.users[index].id],
                  onChanged: (state) {
                    setState(() {
                      filterStates[widget.users[index].id] = state!;
                      widget.onFiltersDone(filterStates);
                    });
                  }),
              TextButton(
                  onPressed: () => setState(() {
                        bool? temp = filterStates[widget.users[index].id];
                        filterStates[widget.users[index].id] = !temp!;
                      }),
                  child: Text(widget.users[index].id.toString()))
            ],
          );
        });
  }
}
