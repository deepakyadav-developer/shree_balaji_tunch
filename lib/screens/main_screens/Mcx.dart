import 'dart:async';



import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'mcxdata.dart';


class LiveMcx extends StatefulWidget {
  const LiveMcx({Key key,}) : super(key: key);



  @override
  _LiveMcxState createState() => _LiveMcxState();
}

class _LiveMcxState extends State<LiveMcx> with AutomaticKeepAliveClientMixin{
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();
  String mcxUrl="";
  // CollectionReference liveRef;


  @override
  void initState() {
    // liveRef=FirebaseFirestore.instance.collection("livemcx");
    // liveRef.get().then((QuerySnapshot snapshot)  {
    //   snapshot.docs.forEach((f) {
    //     print(f.get("url"));
    //     setState(() {
    //       mcxUrl=f.get("url");
    //     });
    //   });
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(

        body:Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: ListView(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  child: WebView(
                    initialUrl: "https://mcxlive.org/",
                    gestureRecognizers: {
                      Factory(() => CustomGestureRecognizer(maxScreenOffsetX: screenWidth)),
                    },
                    onPageStarted: (data) {
                      _beforePageLoad();
                    },
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller.complete(webViewController);
                    },
                  ),
                ),
              ],
            )
        )
    );
  }

  Widget _beforePageLoad() {
    return const Center(
      child: CircularProgressIndicator(),
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
        fontSize: 12.0);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
