import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key, required this.messagesStrings}) : super(key: key);

  final List<String> messagesStrings;

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    loadShared();
    super.initState();
  }

  void loadShared() async {
    /*
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.reload();
    print('[messages]');
    preferences.getStringList('messages') ??
        [].forEach((messageString) {
          messages.add(jsonDecode(messageString));
        });
    print('[loadShared] $messages');
    setState(() {});
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        body: ListView.builder(
            itemCount: widget.messagesStrings.length,
            itemBuilder: (bc, index) {
              String _title =
                  jsonDecode(widget.messagesStrings[index])['title'];
              String _body =
                  jsonDecode(widget.messagesStrings[index])['message'];
              String _date =
                  jsonDecode(widget.messagesStrings[index])['timestamp'];
              return ListTile(
                  key: Key(index.toString()),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  tileColor: index.isEven ? Colors.white : Colors.white,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_date.split(' ')[0]),
                      Text(_date.split(' ')[1]),
                    ],
                  ),
                  leading: Icon(_title.contains('Мой EvpaNet')
                      ? Icons.question_answer_outlined
                      : Icons.warning_outlined),
                  title: Text(_title),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      _body,
                      style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.blueGrey),
                    ),
                  ),
                  onLongPress: () => showDialog<bool>(
                          context: bc,
                          builder: (bc) => AlertDialog(
                                content: Text('Удалить сообщение из списка?'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        print(index);
                                        Navigator.pop(bc, true);
                                      },
                                      child: Text('Да')),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(bc, false);
                                      },
                                      child: Text('Нет')),
                                ],
                              )).then((answer) {
                        if (answer ?? false) print(answer);
                      }));
            }));
  }
}
