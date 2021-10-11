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
        appBar: AppBar(
          title: Text('Сообщения'),
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
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                tileColor: index.isEven ? Colors.white : Colors.white,
                leading: Text(_date),
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
                onLongPress: () => showDialog(
                    context: bc,
                    builder: (bc) => AlertDialog(
                          content: Text('Удалить сообщение из списка?'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(bc, true);
                                },
                                child: Text('Да')),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(bc, false);
                                },
                                child: Text('Нет')),
                          ],
                        )),
              );
            }));
  }
}
