import 'package:evpanet/Helpers/maindata.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:flutter_icons/flutter_icons.dart';

class MainScreen extends StatefulWidget {
  //final List<String> guids;

  const MainScreen({ Key? key }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  
  Abonent abonent = Abonent();

  @override
  void initState() {
    print('{MainScreen.init}');
    start();
    super.initState();
  }
  
  Future<void> start() async {
    await abonent.loadSavedData();
    setState(() {});
    if (abonent.device.length > 10) abonent.getDataForGuidsFormServer().then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromRGBO(245, 246, 248, 1.0),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          iconTheme: const IconThemeData(
            color: const Color.fromRGBO(72, 95, 113, 1.0)
          ),
          titleSpacing: 0.0,
          backgroundColor: const Color.fromRGBO(245, 246, 248, 1.0),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Информация',
                style: const TextStyle(
                  color: const Color.fromRGBO(72, 95, 113, 1.0),
                  fontSize: 24.0,
                ),
              ),
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: const TextStyle(
                  color: const Color.fromRGBO(146, 152, 166, 1.0),
                  fontSize: 14.0
                ),
              )
            ],
          ),
          elevation: 0.0,
          actions: [
            GestureDetector(
              child: Container(
                padding: const EdgeInsets.only(
                  top: 10.0,
                  bottom: 10.0,
                  right: 10.0
                ),
                child: const Icon(
                  Icons.support_agent_outlined,
                  color: const Color.fromRGBO(72, 95, 113, 1.0),
                  size: 24.0,
                ),
              ),
              onTap: () {
                //showModalCallToSupport();
              },
            ),
            GestureDetector(
              child: Container(
                padding: const EdgeInsets.only(
                  top: 10.0,
                  bottom: 10.0,
                  right: 16.0
                ),
                child: const Icon(
                  Icons.mail_outline,
                  color: const Color.fromRGBO(72, 95, 113, 1.0),
                  size: 24.0,
                ),
              ),
              onTap: () {
                //showModalWriteToSupport();
              },
            )
          ],
        ),
      ),
      body: Center(
        child: Text(abonent.guids.toString()),
      ),
    );
  }
}