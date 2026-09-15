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
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading categories',
                style: TextStyle(color: app_info.bgColor, fontSize: 16),
              ),
            );
          }

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
                var docData = snapshot.data!.docs[index].data() as Map<String, dynamic>?;
                
                String imageUrl = '';
                if (docData != null) {
                  List<String> possibleKeys = ['url', 'image', 'imageUrl', 'imageURL', 'image_url', 'img', 'pic', 'photo', 'categorypic', 'categoryPic', 'thumbnail'];
                  for (String key in possibleKeys) {
                    if (docData.containsKey(key) && docData[key] != null && docData[key].toString().isNotEmpty) {
                      imageUrl = docData[key].toString();
                      break;
                    }
                  }
                }

                return _buildCategoryCard(
                  snapshot.data!.docs[index].id,
                  docData != null && docData.containsKey('categoryName') ? docData['categoryName'] ?? 'Unnamed' : 'Unnamed',
                  imageUrl,
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
                      child: Builder(
                        builder: (context) {
                          if (imageUrl.isNotEmpty) {
                            return _buildCachedImage(imageUrl);
                          }
                          // Fallback: Query the first image from this category in the gallery collection
                          return FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection("gallery")
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(
                                  child: Image.asset("assets/images/logo.png", height: 60),
                                );
                              }
                              
                              String fallbackUrl = '';
                              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                for (var doc in snapshot.data!.docs) {
                                  var docData = doc.data() as Map<String, dynamic>?;
                                  if (docData != null) {
                                    // Local case-insensitive check
                                    String cName = (docData['categoryName'] ?? '').toString().toLowerCase();
                                    String cId = (docData['category'] ?? '').toString().toLowerCase();
                                    
                                    if (cId == id.toLowerCase() || 
                                        cId == categoryName.toLowerCase() || 
                                        cName == categoryName.toLowerCase() ||
                                        cName.contains(categoryName.toLowerCase()) ||
                                        categoryName.toLowerCase().contains(cName)) {
                                          
                                      List<String> possibleKeys = ['url', 'image', 'imageUrl', 'imageURL', 'image_url', 'img', 'pic', 'photo', 'thumbnail'];
                                      for (String key in possibleKeys) {
                                        if (docData.containsKey(key) && docData[key] != null && docData[key].toString().isNotEmpty) {
                                          fallbackUrl = docData[key].toString();
                                          break;
                                        }
                                      }
                                      if (fallbackUrl.isNotEmpty) break;
                                    }
                                  }
                                }
                              }
                              
                              if (fallbackUrl.isNotEmpty) {
                                return _buildCachedImage(fallbackUrl);
                              }
                              
                              // Absolute fallback
                              if (categoryName.toLowerCase().contains('gold')) {
                                fallbackUrl = 'https://cdn-icons-png.flaticon.com/512/2155/2155913.png';
                                return _buildCachedImage(fallbackUrl);
                              } else if (categoryName.toLowerCase().contains('silver')) {
                                fallbackUrl = 'https://cdn-icons-png.flaticon.com/512/3233/3233042.png';
                                return _buildCachedImage(fallbackUrl);
                              }
                              
                              return Container(
                                color: app_info.bgColor.withValues(alpha: 0.05),
                                child: Center(
                                  child: Image.asset("assets/images/logo.png", height: 60),
                                ),
                              );
                            },
                          );
                        }
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
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading videos',
              style: TextStyle(color: app_info.bgColor, fontSize: 16),
            ),
          );
        }

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
        
        List<DocumentSnapshot> docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          var aData = a.data() as Map<String, dynamic>?;
          var bData = b.data() as Map<String, dynamic>?;
          var aTime = aData != null && aData.containsKey('updatedTime') ? aData['updatedTime'] : null;
          var bTime = bData != null && bData.containsKey('updatedTime') ? bData['updatedTime'] : null;
          
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          
          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }
          return 0;
        });

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: docs.length,
            itemBuilder: (BuildContext context, int index) {
              var docData = docs[index].data() as Map<String, dynamic>?;
              
              String thumbnail = '';
              String videoUrl = '';
              
              if (docData != null) {
                List<String> thumbKeys = ['thumbnail', 'thumb', 'image', 'imageUrl', 'image_url', 'pic'];
                for (String key in thumbKeys) {
                  if (docData.containsKey(key) && docData[key] != null && docData[key].toString().isNotEmpty) {
                    thumbnail = docData[key].toString();
                    break;
                  }
                }
                
                List<String> videoKeys = ['url', 'video', 'videoUrl', 'video_url', 'link', 'file'];
                for (String key in videoKeys) {
                  if (docData.containsKey(key) && docData[key] != null && docData[key].toString().isNotEmpty) {
                    videoUrl = docData[key].toString();
                    break;
                  }
                }
              }
              
              list.add(videoUrl);

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
                        if (videoUrl.isNotEmpty) {
                          Get.to(() => ShortsPlayer(
                                url: videoUrl,
                              ));
                        }
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

  Widget _buildCachedImage(String url) {
    return CachedNetworkImage(
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
      imageUrl: url,
      fit: BoxFit.cover,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
