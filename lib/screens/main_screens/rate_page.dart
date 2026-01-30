import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:html/parser.dart';
import 'dart:math';
import 'package:animated_digit/animated_digit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

import '../../widgets/story_widget.dart';
import '../../constant/app_info.dart' as app_info;

// Define common colors
const Color borderColor = Colors.grey;
const Color rateColor = Colors.green;
const Color bgColor = Colors.white;
const Color whiteColor = Colors.white;
const Color textColor = Colors.black87;

// Class to store MCX Silver data
class MCXSilverData {
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final String updateTime;

  MCXSilverData({
    this.name = '',
    this.price = 0.0,
    this.change = 0.0,
    this.changePercent = 0.0,
    this.openPrice = 0.0,
    this.highPrice = 0.0,
    this.lowPrice = 0.0,
    this.updateTime = '',
  });
}

class RatePage extends StatefulWidget {
  const RatePage({super.key});

  @override
  _RatePageState createState() => _RatePageState();
}

class _RatePageState extends State<RatePage>
    with AutomaticKeepAliveClientMixin {
  final ScreenshotController sc = ScreenshotController();
  double _height = 0;
  double _width = 0;
  String message1 = "", message2 = "";
  int oldRate1 = 0;
  int oldRate2 = 0;
  List<VideoPlayerController> controllers = [];
  String? url;
  bool play = false;
  List<String> urls = [];
  List<Widget> list = [];
  int oldRate3 = 0;
  int oldRate4 = 0;
  Timer? _timer;
  Timer? _timer2;
  bool showLogo = false;
  int rate1 = 0;
  int rate2 = 0;
  int rate3 = 0;
  int rate4 = 0;
  Color _goldColor = Colors.green, _silverColor = Colors.green;
  String name1 = "";
  String name2 = "";
  String name3 = "";
  String name4 = "";

  Color color1 = Colors.green;
  Color color2 = Colors.green;
  Color color3 = Colors.green;
  Color color4 = Colors.green;
  bool _startMcx = false;
  int silverRate = 0;
  int goldRate = 0;
  int silverOpen = 0;
  int goldOpen = 0;
  int gRate = 0, sRate = 0;
  double gSpot = 0, sSpot = 0, dollars = 0;
  double goldSpot = 0, silverSpot = 0, dollarsSpot = 0;
  String gSpotLow = '0', gSpotHigh = '0';
  String sSpotLow = '0', sSpotHigh = '0';
  int goldHigh = 0;
  int goldLow = 0;
  int silverHigh = 0;
  int silverLow = 0;
  int silverChange = 0;
  int goldCHange = 0;
  String inrLow = '0', inrHigh = '0';
  Color gSpotColor = rateColor;
  Color sSpotColor = rateColor;
  Color inrColor = rateColor;
  int _silverRateDiff = 0, _goldRateDiff = 0;
  int count = 0;
  QuerySnapshot? startMcx;
  var data;
  bool mcxOnOff = false;

  // MCX Silver Data
  List<MCXSilverData> mcxSilverDataList = [];
  String lastUpdateTime = "";

  final random = Random();

  Future<void> fetchMCXRates() async {
    try {
      // Fetch the HTML of the website
      final response = await http.get(Uri.parse('https://mcxlive.org/'));

      if (response.statusCode == 200) {
        final document = parse(response.body);

        // Clear the previous data
        mcxSilverDataList.clear();

        // Get all rows in the table
        final rows = document.querySelectorAll('table tbody tr');

        // Get the update time if available
        final updateTimeElement = document.querySelector('.text-primary');
        if (updateTimeElement != null) {
          lastUpdateTime = updateTimeElement.text.trim();
        }

        for (var row in rows) {
          final cells = row.querySelectorAll('td');

          // Check if row has the expected structure
          if (cells.length >= 7) {
            final commodityName = cells[0].text.trim();
            final spotPrice = cells[1].text.trim().replaceAll(',', '');
            final changePrice = cells[2].text.trim().replaceAll(',', '');
            final changePercent =
                cells[3].text.trim().replaceAll('%', '').replaceAll(',', '');
            final openPrice =
                cells[4].text.trim().replaceAll(',', ''); // Using as open price
            final highPrice = cells[4].text.trim().replaceAll(',', '');
            final lowPrice = cells[5].text.trim().replaceAll(',', '');
            final updateTime = cells.length > 7 ? cells[7].text.trim() : '';

            // Check if the data is valid before updating
            if (spotPrice.isNotEmpty &&
                changePrice.isNotEmpty &&
                highPrice.isNotEmpty &&
                lowPrice.isNotEmpty) {
              // Look for MCX Gold but not MCX Gold Mini
              if (commodityName.contains('MCX Gold') &&
                  !commodityName.contains('Mini')) {
                setState(() {
                  goldRate = int.tryParse(spotPrice.split('.').first) ?? 0;
                  goldCHange = int.tryParse(changePrice.split('.').first) ?? 0;
                  goldHigh = int.tryParse(highPrice.split('.').first) ?? 0;
                  goldLow = int.tryParse(lowPrice.split('.').first) ?? 0;
                });
              }
              // Process all MCX Silver variants
              if (commodityName.contains('MCX Silver')) {
                // Create MCXSilverData object
                final silverData = MCXSilverData(
                  name: commodityName,
                  price: double.tryParse(spotPrice) ?? 0.0,
                  change: double.tryParse(changePrice) ?? 0.0,
                  changePercent: double.tryParse(changePercent) ?? 0.0,
                  openPrice: double.tryParse(openPrice) ?? 0.0,
                  highPrice: double.tryParse(highPrice) ?? 0.0,
                  lowPrice: double.tryParse(lowPrice) ?? 0.0,
                  updateTime: updateTime,
                );

                mcxSilverDataList.add(silverData);

                // Update the main silver rate if it's the main MCX Silver (not Mini or Micro)
                if (commodityName.contains('MCX Silver') &&
                    !commodityName.contains('Mini') &&
                    !commodityName.contains('Micro')) {
                  setState(() {
                    silverRate = int.tryParse(spotPrice.split('.').first) ?? 0;
                    silverChange =
                        int.tryParse(changePrice.split('.').first) ?? 0;
                    silverHigh = int.tryParse(highPrice.split('.').first) ?? 0;
                    silverLow = int.tryParse(lowPrice.split('.').first) ?? 0;
                  });
                }
              }
            }
          }
        }
      } else {
        print('Failed to fetch data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching MCX Rates: $e');
    }
  }

  // Method to update the gold rate by 5 Rs up or down randomly
  void updateGoldRate() {
    setState(() {
      // Randomly decide if the rate should increase or decrease
      bool increase =
          random.nextBool(); // Random true/false for increase/decrease
      if (increase) {
        goldRate += 5; // Increase by 5 Rs
        _goldColor = Colors.green; // Set color to green for increase
      } else {
        goldRate -= 5; // Decrease by 5 Rs
        _goldColor = Colors.red; // Set color to red for decrease
      }
    });
  }

  // Method to update the silver rate by 5 Rs up or down randomly
  void updateSilverRate() {
    setState(() {
      // Randomly decide if the rate should increase or decrease
      bool increase =
          random.nextBool(); // Random true/false for increase/decrease
      if (increase) {
        silverRate += 5; // Increase by 5 Rs
        _silverColor = Colors.green; // Set color to green for increase
      } else {
        silverRate -= 5; // Decrease by 5 Rs
        _silverColor = Colors.red; // Set color to red for decrease
      }
    });
  }

  void _startTimer() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      updateGoldRate();
      updateSilverRate();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection('mcx_on_off')
        .snapshots()
        .listen((event) {
      event.docs.forEach((element) {
        if (element.get('on_off')) {
          mcxOnOff = true;
        } else {
          mcxOnOff = false;
        }
      });
    });

    // Fetch MCX data immediately
    fetchMCXRates();

    // Start timer to update rates periodically (every 30 seconds)
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      fetchMCXRates();
      updateGoldRate();
      updateSilverRate();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                height: 110,
                color: app_info.bgColor,
                child: Column(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("message1")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Container(
                            height: 25,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  app_info.primaryColor,
                                  app_info.primaryLightColor,
                                  app_info.accentColor,
                                ],
                              ),
                            ),
                            child: Center(child: _myMarquee(snapshot.data!)),
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: StoryWidget(),
                    ),
                  ],
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('slider')
                      .snapshots(),
                  builder: (context, snapshot) {
                    // Show loading indicator while waiting
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: 150,
                        child: Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      );
                    }

                    // Check if we have data and it's not empty
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      return SizedBox(
                        height: 150,
                        child: _carousel(snapshot.data!),
                      );
                    }

                    // Show fallback slider for errors or empty data
                    return _buildFallbackSlider();
                  }),
              const SizedBox(
                height: 5,
              ),

              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("rate")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Screenshot(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _upperRateCard(
                                          'assets/gif/gold.gif',
                                          snapshot.data!.docs[0].get('name'),
                                          snapshot.data!.docs[0]
                                              .get('rate')
                                              .toString(),
                                          "Update Time :-",
                                          snapshot.data!.docs[0]
                                              .get('updatedTime'),
                                          false,
                                          goldRate,
                                          _goldColor),
                                      _upperRateCard(
                                          'assets/gif/gold.gif',
                                          snapshot.data!.docs[2].get('name'),
                                          snapshot.data!.docs[2]
                                              .get('rate')
                                              .toString(),
                                          "Update Time :-",
                                          snapshot.data!.docs[2]
                                              .get('updatedTime'),
                                          false,
                                          goldRate,
                                          _goldColor),
                                    ],
                                  ),
                                  // Second row of rate cards
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _upperRateCard(
                                          'assets/gif/silver.gif',
                                          snapshot.data!.docs[1].get('name'),
                                          snapshot.data!.docs[1]
                                              .get('rate')
                                              .toString(),
                                          "Update Time :-",
                                          snapshot.data!.docs[1]
                                              .get('updatedTime'),
                                          false,
                                          silverRate,
                                          _silverColor),
                                      _upperRateCard(
                                          'assets/gif/bank.gif',
                                          snapshot.data!.docs[3].get('name'),
                                          snapshot.data!.docs[3]
                                              .get('rate')
                                              .toString(),
                                          "Update Time :-",
                                          snapshot.data!.docs[3]
                                              .get('updatedTime'),
                                          snapshot.data!.docs[3].get('mcx'),
                                          goldRate,
                                          _goldColor),
                                    ],
                                  ),

                                  showLogo
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.asset(
                                            'assets/images/logo.png',
                                            height: 50,
                                          ),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                              controller: sc,
                            );
                          } else {
                            return const SizedBox();
                          }
                        },
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),

              // MCX Silver Table

              const SizedBox(
                height: 20,
              ),
              _liveRate(),
              const SizedBox(
                height: 35,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _myMarquee(data) {
    String messages1 = 'Welcome to ${app_info.projectName}';
    for (var element in data.docs) {
      messages1 = messages1 + element.get('message') + '     ';
    }
    if (messages1.length < 50) {
      return Text(
        messages1,
        style: TextStyle(
            fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black87),
      );
    } else {
      return Marquee(
        text: messages1,
        style: TextStyle(
            fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        blankSpace: 20.0,
        velocity: 50.0,
        pauseAfterRound: const Duration(seconds: 1),
        startPadding: 10.0,
        accelerationDuration: const Duration(seconds: 0),
        accelerationCurve: Curves.linear,
        decelerationDuration: const Duration(milliseconds: 500),
        decelerationCurve: Curves.easeOut,
      );
    }
  }

  Widget _carousel(data) {
    List<Widget> list = [];

    try {
      print('Processing ${data.docs.length} slider documents');

      for (var element in data.docs) {
        try {
          String imageUrl = element.get('url') ?? '';

          if (imageUrl.isEmpty) {
            print('Empty URL found in slider document');
            continue;
          }

          print('Loading slider image: $imageUrl');

          list.add(Container(
            width: Get.width,
            margin: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                placeholder: (context, url) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          bgColor.withValues(alpha: 0.3),
                          bgColor.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 60,
                          ),
                          SizedBox(height: 10),
                          CupertinoActivityIndicator(),
                        ],
                      ),
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  print('Error loading image $url: $error');
                  return _buildErrorSlide();
                },
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                cacheKey: imageUrl,
                maxHeightDiskCache: 400,
                maxWidthDiskCache: 800,
              ),
            ),
          ));
        } catch (e) {
          print('Error processing slider document: $e');
          continue;
        }
      }
    } catch (e) {
      print('Error in _carousel: $e');
    }

    if (list.isEmpty) {
      print('No valid slider images, showing fallback');
      return _buildFallbackSlider();
    }

    print('Successfully loaded ${list.length} slider images');

    return Container(
      decoration: BoxDecoration(color: whiteColor),
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CarouselSlider(
          items: list,
          options: CarouselOptions(
            height: 150,
            viewportFraction: 0.95,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 4),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            enlargeFactor: 0.15,
            onPageChanged: (index, reason) {
              // Handle page change if needed
            },
          ),
        ),
      ),
    );
  }

  // Beautiful fallback slider when no network or data
  Widget _buildFallbackSlider() {
    final List<Map<String, dynamic>> fallbackSlides = [
      {
        'title': 'Welcome to\nShree Balaji',
        'subtitle': 'Your Trusted Gold & Silver Partner',
        'gradient': [Color(0xFFFFD700), Color(0xFFFFA500)],
        'icon': Icons.diamond,
      },
      {
        'title': 'Live Rates',
        'subtitle': 'Real-time Gold & Silver Prices',
        'gradient': [Color(0xFF1A237E), Color(0xFF3949AB)],
        'icon': Icons.trending_up,
      },
      {
        'title': 'Best Quality',
        'subtitle': '100% Pure & Certified',
        'gradient': [Color(0xFFC0C0C0), Color(0xFF808080)],
        'icon': Icons.verified,
      },
    ];

    return Container(
      height: 150,
      child: CarouselSlider(
        items: fallbackSlides.map((slide) {
          return Container(
            width: Get.width,
            margin: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: slide['gradient'],
              ),
              boxShadow: [
                BoxShadow(
                  color: slide['gradient'][0].withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -20,
                  left: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              slide['title'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              slide['subtitle'],
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          slide['icon'],
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        options: CarouselOptions(
          height: 150,
          viewportFraction: 0.95,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 4),
          autoPlayAnimationDuration: Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
          enlargeFactor: 0.15,
        ),
      ),
    );
  }

  // Error slide widget
  Widget _buildErrorSlide() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor.withValues(alpha: 0.3),
            bgColor.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 60,
            ),
            SizedBox(height: 10),
            Text(
              'Shree Balaji',
              style: TextStyle(
                color: bgColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _myCategories() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('category').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading categories'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No categories found'));
        }

        final categories = snapshot.data!.docs;

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final categoryDoc = categories[index];
            final categoryName = categoryDoc['categoryName'] ?? 'Unnamed';
            final imageUrl = categoryDoc['url'] ?? '';

            return GestureDetector(
              onTap: () async {
                print('Tapped category: ${categoryDoc.id}');
                try {
                  final QuerySnapshot galleryDocs = await FirebaseFirestore
                      .instance
                      .collection('gallery')
                      .where('category', isEqualTo: categoryDoc.id)
                      .get();

                  final urls = galleryDocs.docs
                      .map((doc) => (doc.data() as Map<String, dynamic>)['url'])
                      .where((url) => url != null)
                      .cast<String>()
                      .toList();

                  print(
                      'Found ${urls.length} URLs for category: ${categoryDoc.id}');
                  if (urls.isEmpty) {
                    print('No URLs found for category: ${categoryDoc.id}');
                    return;
                  }

                  // Navigate to StoryView and pass the category names and URLs
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoryViewPage(
                        initialIndex: 0,
                        stories: galleryDocs.docs,
                      ),
                    ),
                  );
                } catch (e) {
                  print('Error in onTap for category ${categoryDoc.id}: $e');
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/images/logo.png'),
                      // imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                      backgroundColor: Colors.grey[300],
                      child: imageUrl.isEmpty
                          ? Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 28,
                            )
                          : null,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      categoryName,
                      style: TextStyle(color: Colors.black87),
                      overflow: TextOverflow.ellipsis, // Handle long text
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _upperRateCard(
    String assetUrl,
    String name,
    String rate,
    String high,
    String low,
    bool mcx,
    int metalRate,
    Color rateColor,
  ) {
    int newRate = int.parse(rate);
    int displayedRate = mcx ? newRate + metalRate : newRate;

    // Determine gradient colors based on metal type
    List<Color> gradientColors;
    Color accentColor;

    if (name.toLowerCase().contains('gold')) {
      gradientColors = [Color(0xFFFFD700), Color(0xFFFFA500)];
      accentColor = Color(0xFFFFD700);
    } else if (name.toLowerCase().contains('silver')) {
      gradientColors = [Color(0xFFC0C0C0), Color(0xFF808080)];
      accentColor = Color(0xFFC0C0C0);
    } else {
      gradientColors = [app_info.primaryColor, app_info.primaryLightColor];
      accentColor = app_info.primaryColor;
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.44,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            accentColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.1),
                      accentColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -15,
              left: -15,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.1),
                      accentColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon and name row
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradientColors,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          assetUrl,
                          height: 32,
                          width: 32,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Rate display
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withValues(alpha: 0.15),
                          accentColor.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(width: 2),
                            Text(
                              displayedRate.toString(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        if (mcx)
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: rateColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              rateColor == Colors.green
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: rateColor,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 8),

                  // Update time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          low,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onDismiss() {
    print('Menu is dismiss');
  }

  void _moveToGalleryScreen(String id, String categoryname) {
    // Get.to(() => ProductPage(
    //       id: id,
    //       categoryName: categoryname,
    //     )
    // );
  }

  Widget _liveRate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _liveRateRow('Gold', goldRate, _goldColor, goldCHange),
        _share(),
        _liveRateRow('Silver', silverRate, _silverColor, silverChange),
      ],
    );
  }

  Widget _liveRateRow(String metal, int rate, color, rateDiff) {
    return SizedBox(
      height: 100,
      width: MediaQuery.of(context).size.width * 0.3,
      child: Stack(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 6),
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width * 0.3,
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "\u20b9 ",
                      style: TextStyle(
                          color: textColor, fontSize: Get.height * .03),
                    ),
                    AnimatedDigitWidget(
                      value: rate,
                      // animateAutoSize: true,
                      // autoSize: true,
                      textStyle: TextStyle(
                        fontSize: Get.height * .03,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      rateDiff >= 0
                          ? "assets/images/up.png"
                          : "assets/images/down.png",
                      height: 20,
                    ),
                    Text(
                      rateDiff.toString(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(metal,
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _share() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () async {
            setState(() {
              showLogo = true;
            });
            await sc
                .capture(delay: const Duration(milliseconds: 300))
                .then((image) async {
              if (image != null) {
                final directory = await getApplicationDocumentsDirectory();
                final imagePath =
                    await File('${directory.path}/image.png').create();
                await imagePath.writeAsBytes(image);
                setState(() {
                  showLogo = false;
                });

                /// Share Plugin
                await Share.shareXFiles([XFile(imagePath.path)]);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.share,
                  color: Colors.black87,
                  size: 15,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  'Share',
                  style: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _buildMCXSilverTable() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xff44000d),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('MCX Silver Rates',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white)),
                Text(lastUpdateTime,
                    style: TextStyle(fontSize: 12, color: Colors.white)),
              ],
            ),
          ),
          Table(
            border: TableBorder.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            columnWidths: {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(2),
              5: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                ),
                children: [
                  _buildTableHeader('Type'),
                  _buildTableHeader('Price'),
                  _buildTableHeader('Change'),
                  _buildTableHeader('%'),
                  _buildTableHeader('High'),
                  _buildTableHeader('Low'),
                ],
              ),
              ...mcxSilverDataList.map((data) {
                Color changeColor =
                    data.change >= 0 ? Colors.green : Colors.red;
                return TableRow(
                  children: [
                    _buildTableCell(data.name),
                    _buildTableCell(data.price.toStringAsFixed(2)),
                    _buildTableCell(
                      data.change.toStringAsFixed(2),
                      textColor: changeColor,
                    ),
                    _buildTableCell(
                      '${data.changePercent.toStringAsFixed(2)}%',
                      textColor: changeColor,
                    ),
                    _buildTableCell(data.highPrice.toStringAsFixed(2)),
                    _buildTableCell(data.lowPrice.toStringAsFixed(2)),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text, {Color textColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(color: textColor),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
