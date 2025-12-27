import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

import '../constant/APP_INFO.dart';

class BannerImagePreview extends StatefulWidget {
  final List _photos;
  final int _sno;

  BannerImagePreview(this._photos, this._sno);

  @override
  _BannerImagePreviewState createState() =>
      _BannerImagePreviewState(_photos, _sno);
}

class _BannerImagePreviewState extends State<BannerImagePreview> {
  List _photos = [];
  int _sno;

  _BannerImagePreviewState(this._photos, this._sno);

  PageController _controller = PageController();
  String _currentPage = "1";

  @override
  void initState() {
    _currentPage = (_sno + 1).toString();
    _controller =
        PageController(viewportFraction: 1, keepPage: true, initialPage: _sno);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: mainColor, // status bar color
    // ));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: whiteColor,
            )),
        flexibleSpace: Container(
          decoration: BoxDecoration(color: bgColor),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                var response = await http.get(Uri.parse(
                    widget._photos[int.parse(_currentPage) - 1].get('url')));
                final directory = await getApplicationDocumentsDirectory();
                final imagePath =
                    await File('${directory.path}/image.png').create();
                await imagePath.writeAsBytes(response.bodyBytes);

                /// Share Plugin
                await Share.shareXFiles([XFile(imagePath.path)]);
              },
              icon: Icon(
                Icons.share,
                color: whiteColor,
              ))
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: Colors.white,
              child: PageView.builder(
                itemCount: _photos.length,
                controller: _controller,
                onPageChanged: (i) {
                  setState(() {
                    _currentPage = (i + 1).toString();
                  });
                },
                itemBuilder: (context, i) {
                  return Container(
                      child: PhotoView(
                          loadingBuilder: (context, a) {
                            return Center(
                              child: CupertinoActivityIndicator(),
                            );
                          },
                          imageProvider: CachedNetworkImageProvider(
                            _photos[i].get('url'),
                          )));
                },
              ),
            ),
            Positioned(
              bottom: 0,
              left: MediaQuery.of(context).size.width / 2,
              child: Row(
                children: [
                  Text(
                    _currentPage,
                    style: TextStyle(color: textColor, fontSize: 18),
                  ),
                  Text(
                    " / ",
                    style: TextStyle(color: textColor, fontSize: 18),
                  ),
                  Text(
                    _photos.length.toString(),
                    style: TextStyle(color: textColor, fontSize: 18),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
