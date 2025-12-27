import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shreebalaji_tounch/constant/app_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';

class ProductImagePreview extends StatefulWidget {
  final List urls;
  final int index;

  ProductImagePreview(this.urls, this.index);

  @override
  _BannerImagePreviewState createState() => _BannerImagePreviewState();
}

class _BannerImagePreviewState extends State<ProductImagePreview> {
  String _currentPage = '';
  late PageController pageController;
  bool _isLoading = false;

  @override
  void initState() {
    _currentPage = (widget.index + 1).toString();
    pageController = PageController(initialPage: widget.index);
    super.initState();
  }

  Future<void> _shareImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var response = await http
          .get(Uri.parse(widget.urls[int.parse(_currentPage) - 1].get('url')));

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await File('${directory.path}/image.png').create();
      await imagePath.writeAsBytes(response.bodyBytes);

      /// Share Plugin
      await Share.shareXFiles([XFile(imagePath.path)]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share image'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      systemNavigationBarColor: Colors.black,
    ));

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(10),
              child: CupertinoActivityIndicator(
                color: Colors.white,
              ),
            )
          else
            IconButton(
              onPressed: _shareImage,
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.share,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: widget.urls.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 80,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Images Available',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                PhotoViewGallery.builder(
                  scrollPhysics: BouncingScrollPhysics(),
                  pageController: pageController,
                  itemCount: widget.urls.length,
                  onPageChanged: (i) {
                    setState(() {
                      _currentPage = (i + 1).toString();
                    });
                  },
                  builder: (context, i) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: CachedNetworkImageProvider(
                        widget.urls[i].get('url'),
                      ),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                      heroAttributes: PhotoViewHeroAttributes(
                        tag: widget.urls[i].id,
                      ),
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white,
                                size: 50,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Image failed to load',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loadingBuilder: (context, event) {
                    return _loader();
                  },
                ),
                // Page indicator
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 80),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage,
                          style: TextStyle(
                            color: goldColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          " / ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          widget.urls.length.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _loader() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Container(
          height: 100,
          width: 100,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(goldColor),
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}
