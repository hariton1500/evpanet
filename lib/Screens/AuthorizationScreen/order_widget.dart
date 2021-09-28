import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OrderView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        initialUrl: 'https://evpanet.com/internet/leave-a-statement.html',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
