import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:evpanet/Helpers/maindata.dart';
import 'package:evpanet/Screens/webscreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:flutter_icons/flutter_icons.dart';

class MainScreen extends StatefulWidget {
  //final List<String> guids;

  const MainScreen({Key? key}) : super(key: key);

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
    print('[start]');
    await abonent.loadSavedData();
    setState(() {});
    if (abonent.device.length > 10) await abonent.getDataForGuidsFromServer();
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
      print('[start] (${timer.tick}) refreshing...');
      if (abonent.users.length == abonent.guids.length) timer.cancel();
    });
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
                color: const Color.fromRGBO(72, 95, 113, 1.0)),
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
                      fontSize: 14.0),
                )
              ],
            ),
            elevation: 0.0,
            actions: [
              GestureDetector(
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 10.0, bottom: 10.0, right: 10.0),
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
                      top: 10.0, bottom: 10.0, right: 16.0),
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
        body: Column(
          children: [
            Container(
              child: abonent.users.length == 0
                  ? Center(
                      child: RefreshProgressIndicator(),
                    )
                  : CarouselSlider.builder(
                      itemCount: abonent.users.length,
                      itemBuilder: (BuildContext context, int itemIndex,
                              int pageViewIndex) =>
                          carouselUser(itemIndex),
                      options: CarouselOptions(
                        autoPlay: false,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: true,
                        aspectRatio: 16 / 10,
                        viewportFraction: 0.85,
                      )),
            )
          ],
        ));
  }

  Widget carouselUser(int index) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
        decoration: BoxDecoration(
            border:
                Border.all(width: 1.0, color: Color.fromRGBO(52, 79, 100, 1.0)),
            borderRadius: BorderRadius.circular(18.0),
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(184, 202, 220, 1.0),
                  blurRadius: 5.0,
                  spreadRadius: 1.0,
                  offset: Offset(1.0, 2.0))
            ],
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
                ])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          'ID: ${abonent.users[index].id}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                    blurRadius: 1.0,
                                    color: Colors.black,
                                    offset: Offset(1.0, 1.0))
                              ]),
                        )),
                    Container(
                        child: TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) => WebScreen(
                                        url:
                                            'https://my.evpanet.com/?login=${abonent.users[index].login}&password=${abonent.users[index].password}',
                                      )));
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.green)),
                            icon: Icon(
                              Icons.payments_outlined,
                              color: Colors.white,
                            ),
                            label: Text(
                              'Пополнить онлайн',
                              style: TextStyle(color: Colors.white),
                            )))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18, right: 18),
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.end,
                    //crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          'Баланс',
                          style: TextStyle(
                              color: Color.fromRGBO(144, 198, 124, 1),
                              fontSize: 20),
                        ),
                      ),
                      Text(
                        NumberFormat('#,##0.00##', 'ru_RU')
                                .format(abonent.users[index].balance) +
                            ' р.',
                        style: TextStyle(
                            color: abonent.users[index].balance < 0
                                ? Color.fromRGBO(255, 81, 105, 1)
                                : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 1.0,
                                color: Colors.black,
                                offset: Offset(1.0, 1.0),
                              )
                            ]),
                      )
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                abonent.users[index].name,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(166, 187, 204, 1),
                  shadows: [
                    const Shadow(
                      blurRadius: 1.0,
                      color: Colors.black,
                      offset: Offset(1.0, 1.0)
                    )
                  ]
                ),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Окончание действия пакета',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          shadows: [
                            const Shadow(
                              blurRadius: 1.0,
                              color: Colors.black,
                              offset: Offset(1.0, 1.0)
                            )
                          ]
                        ),
                      ),
                      Text(
                        '${abonent.users[index].endDate} (${abonent.users[index].daysRemain} дн.)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          shadows: [
                            const Shadow(
                            blurRadius: 1.0,
                            color: Colors.black,
                            offset: const Offset(1.0, 1.0)
                            )
                          ]
                        ),
                      )
                    ],
                  ),
                  const Icon(
                    Icons.settings_suggest_outlined,
                    color: Colors.white,
                    size: 35.0,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget carouselUser2(int index) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
        decoration: BoxDecoration(
            border:
                Border.all(width: 1.0, color: Color.fromRGBO(52, 79, 100, 1.0)),
            borderRadius: BorderRadius.circular(18.0),
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(184, 202, 220, 1.0),
                  blurRadius: 5.0,
                  spreadRadius: 1.0,
                  offset: Offset(1.0, 2.0))
            ],
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
                ])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                'ID: ${abonent.users[index].id}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                          blurRadius: 1.0,
                                          color: Colors.black,
                                          offset: Offset(1.0, 1.0))
                                    ]),
                              ))
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
