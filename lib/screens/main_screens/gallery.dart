import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shreebalaji_tounch/constant/app_info.dart' as app_info;
import 'package:shreebalaji_tounch/screens/main_screens/play_video.dart';
import 'package:shreebalaji_tounch/screens/main_screens/product_page.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> with AutomaticKeepAliveClientMixin {
  List<String> list = [];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: app_info.whiteColor,
          appBar: AppBar(
            backgroundColor: app_info.bgColor,
            elevation: 0,
            title: Text(
              "Gallery",
              style: TextStyle(
                color: app_info.goldColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            bottom: TabBar(
              unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
              labelColor: app_info.goldColor,
              indicatorColor: app_info.goldColor,
              indicatorWeight: 3,
              labelStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(
                  text: "Gallery",
                  icon: Icon(Icons.photo_library),
                ),
                Tab(
                  text: "Videos",
                  icon: Icon(Icons.video_library),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildGalleryTab(),
              _buildVideoTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryTab() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("category").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    height: 120,
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(app_info.goldColor),
                  ),
                ],
              ),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    height: 150,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No categories available',
                    style: TextStyle(
                      fontSize: 18,
                      color: app_info.bgColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 20,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                return _buildCategoryCard(
                  snapshot.data!.docs[index].id,
                  snapshot.data!.docs[index].get('categoryName'),
                  snapshot.data!.docs[index].get("url"),
                );
              },
            ),
          );
        });
  }

  Widget _buildCategoryCard(String id, String categoryName, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: () => _moveToGalleryScreen(id, categoryName, imageUrl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Hero(
                    createRectTween: (begin, end) {
                      double radius = min(begin!.width, begin.height) / 2;
                      return RectTween(
                        begin: Rect.fromCircle(
                            center: begin.center, radius: radius),
                        end: Rect.fromCircle(
                            center: end!.center, radius: radius),
                      );
                    },
                    tag: 'galleryImage$id',
                    child: Container(
                      decoration: BoxDecoration(
                        color: app_info.bgColor.withValues(alpha: 0.1),
                      ),
                      child: CachedNetworkImage(
                        placeholder: (context, url) {
                          return Container(
                            color: app_info.bgColor.withValues(alpha: 0.1),
                            child: Center(
                              child: Image.asset(
                                "assets/images/logo.png",
                                height: 60,
                              ),
                            ),
                          );
                        },
                        errorWidget: (context, url, error) {
                          return Container(
                            color: app_info.bgColor.withValues(alpha: 0.05),
                            child: Center(
                              child: Image.asset(
                                "assets/images/logo.png",
                                height: 60,
                              ),
                            ),
                          );
                        },
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: app_info.bgColor,
                  ),
                  child: Center(
                    child: Text(
                      categoryName,
                      style: TextStyle(
                        color: app_info.goldColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('videos')
          .orderBy("updatedTime", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/logo.png",
                  height: 120,
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(app_info.goldColor),
                ),
              ],
            ),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/logo.png",
                  height: 150,
                ),
                SizedBox(height: 20),
                Text(
                  'No videos available',
                  style: TextStyle(
                    fontSize: 18,
                    color: app_info.bgColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              var thumbnail = snapshot.data!.docs[index].get('thumbnail');
              list.add(snapshot.data!.docs[index].get('url'));

              return Container(
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Material(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        Get.to(() => ShortsPlayer(
                              url: snapshot.data!.docs[index].get('url'),
                            ));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: thumbnail,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color:
                                        app_info.bgColor.withValues(alpha: 0.1),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                app_info.goldColor),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: app_info.bgColor
                                        .withValues(alpha: 0.05),
                                    child: Center(
                                      child: Image.asset(
                                        "assets/images/logo.png",
                                        height: 80,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  color: Colors.black.withValues(alpha: 0.2),
                                ),
                                Center(
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: app_info.goldColor
                                          .withValues(alpha: 0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.play_arrow,
                                      size: 42,
                                      color: app_info.bgColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.video_collection,
                                  color: app_info.bgColor,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Video ${index + 1}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: app_info.bgColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _moveToGalleryScreen(
      String id, String categoryName, String categorypic) {
    Get.to(
      () => ProductPage(
        id: id,
        categoryName: categoryName,
        categorypic: categorypic,
      ),
      transition: Transition.fadeIn,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
