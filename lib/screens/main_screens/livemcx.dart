import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ShopNow extends StatefulWidget {
  const ShopNow({super.key});

  @override
  _ShopNowState createState() => _ShopNowState();
}

class _ShopNowState extends State<ShopNow> with AutomaticKeepAliveClientMixin {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(
            controller: WebViewController()
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
                  onWebResourceError: (error) {
                    setState(() {
                      isLoading = false;
                    });
                    signupMessages("Please check your Internet connection");
                  },
                ),
              )
              ..loadRequest(Uri.parse("https://shreebalajistore.com/")),
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF800000)),
              ),
            ),
        ],
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
