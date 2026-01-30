import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'mcxdata.dart';

class LiveMcx extends StatefulWidget {
  const LiveMcx({
    super.key,
  }) : super();

  @override
  _LiveMcxState createState() => _LiveMcxState();
}

class _LiveMcxState extends State<LiveMcx> with AutomaticKeepAliveClientMixin {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            signupMessages("Please check your Internet connection");
          },
        ),
      )
      ..loadRequest(Uri.parse("https://mcxlive.org/"));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Stack(
          children: [
            WebViewWidget(
              controller: _controller,
              gestureRecognizers: {
                Factory(() =>
                    CustomGestureRecognizer(maxScreenOffsetX: screenWidth)),
              },
            ),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  void signupMessages(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 12.0,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
