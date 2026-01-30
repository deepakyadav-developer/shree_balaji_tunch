import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shreebalaji_tounch/constant/app_info.dart' as app_info;
import 'package:shreebalaji_tounch/screens/main_screens/product_images.dart';

class ProductPage extends StatefulWidget {
  final String id;
  final String categoryName;
  final String categorypic;

  const ProductPage({
    super.key,
    required this.id,
    required this.categoryName,
    required this.categorypic,
  });

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: app_info.bgColor,
    ));

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("gallery")
              .where('category', isEqualTo: widget.id)
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
                      valueColor:
                          AlwaysStoppedAnimation<Color>(app_info.goldColor),
                    ),
                  ],
                ),
              );
            }

            return CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: Get.height / 2.5,
                  backgroundColor: app_info.bgColor,
                  floating: false,
                  pinned: true,
                  stretch: true,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      widget.categoryName,
                      style: TextStyle(
                        color: app_info.goldColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    background: Hero(
                      createRectTween: (begin, end) {
                        if (begin == null || end == null) {
                          return RectTween(begin: begin, end: end);
                        }
                        double radius = min(begin.width, begin.height) / 2;
                        return RectTween(
                          begin: Rect.fromCircle(
                              center: begin.center, radius: radius),
                          end: Rect.fromCircle(
                              center: end.center, radius: radius),
                        );
                      },
                      tag: 'galleryImage${widget.id}',
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: widget.categorypic,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: app_info.bgColor.withValues(alpha: 0.1),
                              child: Center(
                                child: Image.asset(
                                  "assets/images/logo.png",
                                  height: 80,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: app_info.bgColor.withValues(alpha: 0.05),
                              child: Center(
                                child: Image.asset(
                                  "assets/images/logo.png",
                                  height: 80,
                                ),
                              ),
                            ),
                          ),
                          // Add a gradient overlay for better text visibility
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.5),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  leading: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: app_info.bgColor.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: app_info.goldColor,
                      ),
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),

                // Gallery Grid
                if (snapshot.data!.docs.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/logo.png",
                            height: 150,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'No Images Available',
                            style: TextStyle(
                              fontSize: 20,
                              color: app_info.bgColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProductImagePreview(
                                    snapshot.data!.docs,
                                    index,
                                  ),
                                ),
                              );
                            },
                            child: Container(
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
                                child: CachedNetworkImage(
                                  imageUrl:
                                      snapshot.data!.docs[index].get("url"),
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) {
                                    return Container(
                                      color: app_info.bgColor
                                          .withValues(alpha: 0.1),
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
                                      color: app_info.bgColor
                                          .withValues(alpha: 0.05),
                                      child: Center(
                                        child: Image.asset(
                                          "assets/images/logo.png",
                                          height: 60,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: snapshot.data!.docs.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
