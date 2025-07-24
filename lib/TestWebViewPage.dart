import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TestWebViewPage extends StatefulWidget {
  final String docId;
  final String identifier;
  final String token;
  final String environment;

  const TestWebViewPage({
    Key? key,
    required this.docId,
    required this.identifier,
    required this.token,
    required this.environment,
  }) : super(key: key);

  @override
  State<TestWebViewPage> createState() => _TestWebViewPageState();
}

class _TestWebViewPageState extends State<TestWebViewPage> {
  late final WebViewController _controller;
  static const String YOUR_REDIRECTION_URL = "your-redirect-url.in";

  @override
  void initState() {
    super.initState();
    requestPermissions();
    initializeWebView();
  }

  Future<void> requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.location,
    ].request();
  }

  void initializeWebView() {
    final url = getUrl();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains(YOUR_REDIRECTION_URL)) {
              parseResult(Uri.parse(request.url));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  String getUrl() {
    final baseUrl = widget.environment.toLowerCase() == "production"
        ? "https://app.digio.in"
        : "https://ext.digio.in";
    final txnId = DateTime.now().millisecondsSinceEpoch.toString();
    final url = StringBuffer(
        "$baseUrl/#/gateway/login/${widget.docId}/$txnId/${widget.identifier}");

    final theme = {
      "PRIMARY_COLOR": "#0261B0",
      "SECONDARY_COLOR": "#141414",
      "FONT_FAMILY": "Unbounded",
      "FONT_URL":
      "https://fonts.googleapis.com/css2?family=Unbounded:wght@200&display=swap",
      "FONT_FORMAT": ""
    };

    final params = {
      "logo": "https://www.digio.in/images/digio_blue.png",
      "token_id": widget.token,
      "theme": Uri.encodeComponent(jsonEncode(theme)),
      "redirect_url": "https://$YOUR_REDIRECTION_URL"
    };

    bool first = true;
    for (var entry in params.entries) {
      url.write(first ? '?' : '&');
      first = false;
      url.write('${entry.key}=${entry.value}');
    }

    return url.toString();
  }

  void parseResult(Uri uri) {
    final status = uri.queryParameters["status"];
    final digioDocId = uri.queryParameters["digio_doc_id"];
    final message = uri.queryParameters["message"];

    debugPrint("DigioResponse: status=$status, docId=$digioDocId, message=$message");

    Navigator.pop(context, uri.toString()); // Return result to previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Web View")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
