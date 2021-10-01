import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebScreen extends StatelessWidget {
  final String url;

  WebScreen({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        initialUrl:
            url, //'https://evpanet.com/internet/leave-a-statement.html',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
