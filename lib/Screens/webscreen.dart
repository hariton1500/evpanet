import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebScreen extends StatelessWidget {
  final String url;

  WebScreen({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Сайт EvpaNet'),
      ),
      body: WebView(
        initialUrl:
            url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
