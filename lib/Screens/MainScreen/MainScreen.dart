import 'dart:async';
//import 'dart:convert';
//import 'package:crypto/crypto.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:evpanet/Helpers/maindata.dart';
import 'package:evpanet/Screens/accounts.dart';
import 'package:evpanet/Screens/messages.dart';
import 'package:evpanet/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../AuthorizationScreen/AuthorizationScreen.dart';
import 'helpers.dart';
import 'setup.dart';

class MainScreen extends StatefulWidget {
  final String token;

  //final List<String> guids;

  const MainScreen({Key? key, required this.token}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Abonent abonent = Abonent();
  int currentUserIndex = 0;
  bool isStarting = true, isShowSetup = false, isUpdating = false;
  bool isPaymentLaunched = false;
  String text = '';
  List<String> messages = [];
  DateTime? lastUpdateDateTime;
  String? version, buildNumber;

  @override
  void initState() {
    print('{MainScreen.init}');
    start();
    Intl.defaultLocale = 'ru_RU';
    initializeDateFormatting();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent, // navigation bar color
      statusBarColor: Colors.transparent, // status bar color
      statusBarIconBrightness: Brightness.dark, // status bar icons' color
      systemNavigationBarIconBrightness:
          Brightness.dark, //navigation bar icons' color
    ));
    PackageInfo.fromPlatform().then((value) {
      setState(() {
        version = value.version;
        buildNumber = value.buildNumber;
      });
    });
    super.initState();
  }

  Future<void> start() async {
    printLog('[start]');
    setState(() {
      isStarting = true;
    });
    await abonent.getDataForGuidsFromServer(widget.token).then((value) {
      setState(() {
        isStarting = false;
      });
    }).timeout(Duration(seconds: 3), onTimeout: () {
      abonent.loadSavedData(widget.token).then((value) {
        setState(() {
          isStarting = false;
        });
      }).timeout(Duration(seconds: 3), onTimeout: () {
        setState(() {
          isStarting = false;
        });
      });

      
      Fluttertoast.showToast(
        msg: 'Не удалось подключиться к серверу',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      
    });
    printLog('got data!');
    if (abonent.lastApiMessage == 'Абонент не найден') {
      /*
      setState(() {
        abonent.clearAuthorize();
      });
      */
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => AuthorizationScreen(
                token: widget.token,
                mode: 'new',
              )));
    }
    if (abonent.device.length > 10)
      update(); //abonent.getDataForGuidsFromServer();
    /*
    Timer.periodic(Duration(seconds: 1), (timer) async {
      setState(() {});
      print('[start] (${timer.tick}) refreshing...');
      if (abonent.users.length == abonent.guids.length) {
        timer.cancel();
        abonent.saveData();
        isStarting = false;
        if (!abonent.lastApiErrorStatus) lastUpdateDateTime = DateTime.now();
        setState(() {});
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.reload();
        print('[messages]');
        messages.addAll(preferences.getStringList('messages') ?? []);
        print(preferences.getStringList('messages'));
      }
    });*/
  }

  Future<void> update() async {
    printLog('[update...]');
    setState(() {
      isUpdating = true;
    });
    print(abonent.updatedUsers);
    await abonent.getDataForGuidsFromServer(widget.token);
    printLog(abonent.updatedUsers);
    Timer.periodic(Duration(seconds: 1), (timer) {
      print(abonent.updatedUsers);
      if (abonent.updatedUsers == abonent.guids.length) {
        timer.cancel();
        print('done.');
        print('errors: ${abonent.lastApiErrorStatus}');
        setState(() {
          isUpdating = false;
          if (!abonent.lastApiErrorStatus) lastUpdateDateTime = DateTime.now();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    printLog('{MainScreen}[build]');
    printLog('[currentUserIndex] $currentUserIndex');
    printLog('[isStarting] $isStarting');
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color.fromRGBO(245, 246, 248, 1.0),
        drawer: Drawer(
          child: Container(
            child: appDrawer(),
            color: Color.fromRGBO(245, 246, 248, 1.0),
          ),
        ),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
            iconTheme: const IconThemeData(
                color: const Color.fromRGBO(72, 95, 113, 1.0)),
            titleSpacing: 0.0,
            backgroundColor: const Color.fromRGBO(245, 246, 248, 1.0),
            title: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      magic += '+';
                      if (magic.length >= 5) {
                        magic = '';
                        //Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LogsPage()));
                        showAdaptiveDialog(
                    context: context,
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Text(logs.length.toString()),
                      ),
                          body: SingleChildScrollView(
                              child:
                                  Text(logs)),
                        ));
                      }
                    },
                    child: Text(
                      'Информация',
                      style: const TextStyle(
                        color: const Color.fromRGBO(72, 95, 113, 1.0),
                        fontSize: 24.0,
                      ),
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
            ),
            elevation: 0.0,
            actions: [
              GestureDetector(
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 10.0, bottom: 10.0, right: 10.0),
                  child: const Icon(
                    //Icons.support_agent_outlined,
                    Icons.call_rounded,
                    color: const Color.fromRGBO(72, 95, 113, 1.0),
                    size: 24.0,
                  ),
                ),
                onTap: () {
                  showModalCallToSupport();
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
                  showModalWriteToSupport();
                },
              ),
              GestureDetector(
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 10.0, bottom: 10.0, right: 16.0),
                  child: const Icon(
                    Icons.message_outlined,
                    color: const Color.fromRGBO(72, 95, 113, 1.0),
                    size: 24.0,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => Messages(
                            //messagesStrings: messages.reversed.toList(),
                            abonent: abonent,
                          )));
                },
              )
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: isStarting ||
                        abonent.users.length <= 0 //abonent.users.length == 0
                    ? Center(
                        child: RefreshProgressIndicator(),
                      )
                    : CarouselSlider.builder(
                        itemCount: abonent.users.length,
                        itemBuilder: (BuildContext context, int itemIndex,
                            int pageViewIndex) {
                          print('[courusel builder] itemIndex: $itemIndex');
                          return carouselUser(itemIndex);
                        },
                        options: CarouselOptions(
                            initialPage: currentUserIndex,
                            autoPlay: false,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: true,
                            aspectRatio: 16 / 10,
                            viewportFraction: 0.85,
                            onPageChanged: (index, reason) {
                              setState(() {
                                currentUserIndex = index;
                                isShowSetup = false;
                                //print('[onPageChanged] $index');
                              });
                            })),
              ),
              isShowSetup
                  ? Setup(
                      user: abonent.users[currentUserIndex],
                      index: currentUserIndex,
                      token: widget.token,
                      onSetupChanged: () => start(),
                    )
                  : Container(),
              //точки........
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: points(),
                ),
              ),
              // секция с картами деталей учетной записи
              abonent.users.length > 0
                  ? ListView(
                      shrinkWrap: true,
                      physics:
                          const ScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      children: [
                          // виджет отображения долга
                          Container(
                            child: Column(
                              children: [
                                abonent.users[currentUserIndex].debt > 0
                                    ? Card(
                                        color: Colors.red,
                                        child: ListTile(
                                          title: Text(
                                            'За вашей учетной записью числится задолженность ${abonent.users[currentUserIndex].debt} р.',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                          // текст - Детали учетной записи
                          Container(
                            padding: const EdgeInsets.only(
                                left: 40.0, top: 10.0, bottom: 10.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Детали учетной записи',
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Color.fromRGBO(72, 95, 113, 1.0),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Card(
                              child: Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(
                                        Icons.album,
                                        size: 40,
                                      ),
                                      title: const Text('Тарифный план'),
                                      subtitle: Text(
                                          '${abonent.users[currentUserIndex].tarifName} (${abonent.users[currentUserIndex].tarifSum} р.)'),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Card(
                              child: Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(
                                        Icons.album,
                                        size: 40,
                                      ),
                                      title: Text('IP адрес'),
                                      subtitle: Text(
                                          abonent.users[currentUserIndex].ip),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Card(
                              child: Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(
                                        Icons.album,
                                        size: 40,
                                      ),
                                      title: Text('Адрес подключения'),
                                      subtitle: Text(
                                          '${abonent.users[currentUserIndex].street}, д. ${abonent.users[currentUserIndex].house}, кв. ${abonent.users[currentUserIndex].flat}'),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ])
                  : Center(
                      child: RefreshProgressIndicator(),
                    )
            ],
          ),
        ));
  }

  Widget appDrawer() {
    if (isStarting) return RefreshProgressIndicator();
    return abonent.users.isEmpty
        ? Container()
        : ListView(children: [
            DrawerHeader(
              decoration: BoxDecoration(
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
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 50.0,
                      child: Text(
                        abonent.users[currentUserIndex].id.toString(),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 150.0,
                      child: Text(
                        abonent.users[currentUserIndex].name.toString(),
                        style: TextStyle(color: Colors.white70, fontSize: 20.0),
                        //textWidthBasis: TextWidthBasis.longestLine,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'Баланс: ${abonent.users[currentUserIndex].balance.toString()} р.',
                      style: TextStyle(color: Colors.white70, fontSize: 20.0),
                    ),
                  )
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.payments_outlined),
              title: Text('Пополнить счет'),
              onTap: () {
                Navigator.of(context).pop();
                showDialog<int>(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        elevation: 5,
                        child: PaymentDialog(),
                      );
                    }).then((value) {
                  if ((value ?? 0) > 0) {
                    print('pay $value');
                    abonent
                        .postGetPaymentNo(widget.token,
                            guid: abonent.users[currentUserIndex].guid)
                        .then((_) async {
                      String _launchUrl =
                          'https://payberry.ru/pay/26?acc=${abonent.users[currentUserIndex].id}';
                      print('[launch payment by URL] $_launchUrl');
                      launchUrl(Uri.parse(_launchUrl))
                          .then((value) => setState(() {
                                isPaymentLaunched = true;
                              }));
                    });
                    //launch('https://my.evpanet.com/?login=${abonent.users[currentUserIndex].login}&password=${abonent.users[currentUserIndex].password}');
                  }
                });
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.mail_outlined),
              title: Text('Оставить заявку на ремонт'),
              onTap: () {
                Navigator.of(context).pop();
                showModalWriteToSupport();
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.message_outlined),
              title: Text('Сообщения'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => Messages(
                          //messagesStrings: messages.reversed.toList(),
                          abonent: abonent,
                        )));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings_outlined),
              title: Text('Настройки'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  isShowSetup = !isShowSetup;
                });
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.manage_accounts_outlined),
              title: Text('Учетные записи'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => Accounts(
                          abonent: abonent,
                          token: widget.token,
                          callback: () {
                            if (currentUserIndex > abonent.users.length - 1)
                              currentUserIndex = abonent.users.length - 1;
                            setState(() {});
                          },
                        )));
              },
            ),
            Divider(),
            AboutListTile(
              icon: Icon(Icons.info_outline),
              applicationVersion: version,
              applicationIcon: Icon(
                Icons.insert_emoticon_outlined,
                size: 50,
              ),
              applicationLegalese: '(C) EvpaNet    2000 г.',
              applicationName: 'Мой EvpaNet',
              child: Text('Информация о приложении'),
              dense: false,
              aboutBoxChildren: [
                Center(
                  //padding: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Linkify(
                        onOpen: (url) async {
                          await launchUrl(Uri.parse(url.url));
                        },
                        text:
                            'Сайт: www.evpanet.com\nПочта: adm.evpanet@gmail.com\nТелефон: +79780489664\nТелефон: +79780755900'),
                  ),
                )
              ],
            ),
            //Expanded(child: Container()),
            /*
            TextButton(
              onPressed: () => showAboutDialog(
                context: context,
                applicationName: 'Мой EvpaNet',
                applicationVersion: version
              ),
              child: Text('Информация о приложении')
            ),
            //Text('Версия: $version'),*/
          ]);
  }

  Widget carouselUser(int index) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
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
                              const Shadow(
                                  blurRadius: 1.0,
                                  color: Colors.black,
                                  offset: Offset(1.0, 1.0))
                            ]),
                      )),
                  Container(
                      child: TextButton.icon(
                          onPressed: () {
                            showDialog<int>(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    elevation: 5,
                                    child: PaymentDialog(),
                                  );
                                }).then((value) {
                              if ((value ?? 0) > 0) {
                                abonent
                                    .postGetPaymentNo(widget.token,
                                        guid: abonent
                                            .users[currentUserIndex].guid)
                                    .then((_) {
                                  //String launchUrl = 'https://paymaster.ru/payment/init?LMI_MERCHANT_ID=95005d6e-a21d-492a-a4c5-c39773020dd3&LMI_PAYMENT_AMOUNT=$value&LMI_CURRENCY=RUB&LMI_PAYMENT_NO=${abonent.lastApiMessage}&LMI_PAYMENT_DESC=%D0%9F%D0%BE%D0%BF%D0%BE%D0%BB%D0%BD%D0%B5%D0%BD%D0%B8%D0%B5%20EvpaNet%20ID%20${abonent.users[currentUserIndex].id}';
                                  String _launchUrl =
                                      'https://payberry.ru/pay/26?acc=${abonent.users[currentUserIndex].id}';
                                  print('[launch payment by URL] $_launchUrl');
                                  launchUrl(Uri.parse(_launchUrl)).then(
                                      (value) =>
                                          print('[Launch result] $value'));
                                });
                                //launch('https://my.evpanet.com/?login=${abonent.users[index].login}&password=${abonent.users[index].password}');
                              }
                            });
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white38),
                              elevation: MaterialStateProperty.all(5.0),
                              textStyle: MaterialStateProperty.all(
                                  TextStyle(fontSize: 12))),
                          icon: const Icon(
                            Icons.payments_outlined,
                            color: Colors.white,
                          ),
                          label: Column(
                            children: [
                              Text(
                                'Пополнить',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'счет',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )))
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: GestureDetector(
                  onTap: update,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          'Баланс',
                          style: const TextStyle(
                              color: Color.fromRGBO(144, 198, 124, 1),
                              fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Row(
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Icon(
                                  Icons.update_outlined,
                                  color: Colors.grey,
                                  size: 16,
                                )),
                            Text(
                              lastUpdateDateTime != null
                                  ? DateFormat.Md()
                                      .add_Hms()
                                      .format(lastUpdateDateTime!)
                                  : '[не обновлено]',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          isPaymentLaunched
                              ? IconButton(
                                  onPressed: () {
                                    start();
                                    setState(() {
                                      isPaymentLaunched = false;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.refresh_outlined,
                                    color: Colors.white,
                                  ))
                              : Container(),
                          !isUpdating
                              ? Text(
                                  NumberFormat('#,##0.00##', 'ru_RU').format(
                                          abonent.users[index].balance) +
                                      ' р.',
                                  style: TextStyle(
                                      color: abonent.users[index].balance < 0
                                          ? Color.fromRGBO(255, 81, 105, 1)
                                          : Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        const Shadow(
                                          blurRadius: 1.0,
                                          color: Colors.black,
                                          offset: Offset(1.0, 1.0),
                                        )
                                      ]),
                                )
                              : RefreshProgressIndicator(
                                  color: Colors.grey,
                                  backgroundColor:
                                      Color.fromRGBO(68, 98, 124, 1),
                                ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              //Text('Обновлено: ${lastUpdateDateTime?.toLocal().toUtc() ?? ''}'),
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
                        offset: Offset(1.0, 1.0))
                  ]),
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
                                offset: Offset(1.0, 1.0))
                          ]),
                    ),
                    Text(
                      '${abonent.users[index].endDate} (${abonent.users[index].daysRemain} дн.)',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: abonent.users[index].daysRemain <= 3
                              ? Colors.red
                              : Colors.blue,
                          shadows: [
                            const Shadow(
                                blurRadius: 1.0,
                                color: Colors.black,
                                offset: const Offset(1.0, 1.0))
                          ]),
                    )
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined,
                      color: Colors.white, size: 35.0),
                  onPressed: () {
                    setState(() {
                      isShowSetup = !isShowSetup;
                    });
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Widget> points() {
    List<Widget> _points = [];
    for (var i = 0; i < abonent.guids.length; i++) {
      _points.add(Container(
        width: 8.0,
        height: 8.0,
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentUserIndex == i
                ? Color.fromRGBO(116, 162, 177, 1.0)
                : Color.fromRGBO(198, 209, 216, 1.0)),
      ));
    }
    return _points;
  }

  //  Вызов модального окна для совершения звонка
  showModalCallToSupport() async {
    return showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Color(0xff2c4860),
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          return Dialog(
              backgroundColor: Colors.transparent, child: CallWindowModal());
        });
  }

  // Вызов модального окна с сообщением в ремонты
  showModalWriteToSupport() async {
    return showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Color(0xff2c4860),
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          return Dialog(
              backgroundColor: Colors.transparent,
              child: SupportMessageModal(
                onMessageSended: sending,
                id: abonent.users[currentUserIndex].id,
              ));
        });
  }

  sending(text) async {
    if (text.toString().startsWith('google-token')) {
      text = widget.token;
    }
    await abonent.postMessageToProvider(widget.token,
        message: text, guid: abonent.users[currentUserIndex].guid);
    Fluttertoast.showToast(msg: abonent.lastApiMessage);
    if (!abonent.lastApiErrorStatus) {
      Map<String, dynamic> _message = {
        'title':
            '(${abonent.users[currentUserIndex].id}) Сообщение в службу поддержки',
        'message': text,
        'timestamp':
            '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}'
      };
      abonent.saveMessage(message: _message);
      //messages.add(jsonEncode(_message));
    }
  }
}
