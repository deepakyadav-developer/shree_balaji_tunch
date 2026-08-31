import 'dart:io' as a;
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shreebalaji_tounch/controllers/language_controller.dart';
import 'package:shreebalaji_tounch/screens/main_screens/contact_us.dart';
import 'package:shreebalaji_tounch/screens/main_screens/livemcx.dart';
import 'package:shreebalaji_tounch/screens/register.dart';
import 'package:marquee/marquee.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constant/app_info.dart' as app_info;
import '../main_screens/Mcx.dart';
import '../main_screens/bank_page.dart';
import '../main_screens/gallery.dart';
import '../main_screens/rate_page.dart';

class MyBottomBar extends StatefulWidget {
  const MyBottomBar({super.key});

  @override
  State<MyBottomBar> createState() => _MyBottomBarState();
}

class _MyBottomBarState extends State<MyBottomBar> {
  int _selectedIndex = 2;
  String message1 = "";
  var data;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final LanguageController languageController = Get.find<LanguageController>();

  Future<void> requestNotificationPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  @override
  void initState() {
    getUserId();
    requestNotificationPermissions();
    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          print("New Notification");
        }
      },
    );
    // Wakelock.enable();
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  getUserId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      id = pref.getString('mobile');
    });
    print('is null -------${id == null}');
    print('ID -------$id');
  }

  late String? id;
  final PageController _pageController = PageController();
  String mobile = "";
  final List<Widget> _pages = [
    // RatePage(),
    // Gallery(),
    // Contact(),
    // Bank(),
    // LiveMcx()
  ];

  getData() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      mobile = sp.getString("mobile") ?? "";
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 2) {
          setState(() {
            _selectedIndex = 2;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        key: scaffoldKey,
        drawer: _buildDrawer(),
        appBar: _buildAppBar(),
        bottomNavigationBar: _buildBottomNavigationBar(),
        body: _getBodyWidget(),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF0D1442),
              Color(0xFF131A50),
              Color(0xFF0A0E27),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: ListView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            // ✨ Premium Header with floating orbs
            Container(
              height: 310,
              child: Stack(
                children: [
                  // Background gradient with wave
                  Container(
                    height: 310,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1A237E),
                          Color(0xFF0D47A1),
                          Color(0xFF1565C0),
                          Color(0xFF0D1442),
                        ],
                        stops: [0.0, 0.3, 0.6, 1.0],
                      ),
                    ),
                  ),
                  // Decorative floating orbs
                  Positioned(
                    top: -40,
                    right: -30,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFFFFD700).withOpacity(0.15),
                            Color(0xFFFFD700).withOpacity(0.05),
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: -40,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFF448AFF).withOpacity(0.2),
                            Color(0xFF448AFF).withOpacity(0.05),
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 60,
                    left: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Sparkle dots
                  Positioned(
                    top: 45,
                    right: 50,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFD700).withOpacity(0.6),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFFD700).withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100,
                    right: 30,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    right: 60,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF64B5F6).withOpacity(0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF64B5F6).withOpacity(0.3),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Main content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 50),
                        // Glowing Logo Container
                        Hero(
                          tag: 'drawer_logo',
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  Color(0xFFFFD700),
                                  Color(0xFFFFA726),
                                  Color(0xFFFFD700),
                                  Color(0xFFFF8F00),
                                  Color(0xFFFFD700),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFFFD700).withOpacity(0.4),
                                  blurRadius: 25,
                                  spreadRadius: 5,
                                ),
                                BoxShadow(
                                  color: Color(0xFF1A237E).withOpacity(0.5),
                                  blurRadius: 40,
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF0D1442),
                              ),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.2),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  "assets/images/logo.png",
                                  height: 85,
                                  width: 85,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 18),
                        // Premium name with gold shimmer
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [
                                Color(0xFFFFD700),
                                Color(0xFFFFF8E1),
                                Color(0xFFFFD700),
                                Color(0xFFFFF8E1),
                                Color(0xFFFFD700),
                              ],
                              stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                            ).createShader(bounds);
                          },
                          child: Text(
                            "Shree Balaji",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                              shadows: [
                                Shadow(
                                  color: Color(0xFFFFD700).withOpacity(0.5),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        // Subtitle pill
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.12),
                                Colors.white.withOpacity(0.06),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Color(0xFFFFD700).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            "Computer Store & Laser Solding Center",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bottom fade line
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0xFFFFD700).withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // ✨ Premium Menu Items
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildPremiumMenuItem(
                    icon: Icons.shopping_bag_rounded,
                    title: 'shop_now'.tr,
                    subtitle: 'Browse our collection',
                    iconGradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    onTap: () {
                      Get.to(() => ShopNow());
                    },
                  ),
                  SizedBox(height: 10),
                  _buildPremiumMenuItem(
                    icon: Icons.star_rounded,
                    title: 'leave_review'.tr,
                    subtitle: 'Rate us on store',
                    iconGradient: [Color(0xFFFFB800), Color(0xFFFF8F00)],
                    onTap: () {
                      Navigator.pop(context);
                      if (a.Platform.isAndroid) {
                        openGooglePlayStore();
                      } else if (a.Platform.isIOS) {
                        openAppStore();
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  _buildPremiumMenuItem(
                    icon: Icons.share_rounded,
                    title: 'share_app'.tr,
                    subtitle: 'Share with friends',
                    iconGradient: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                    onTap: () {
                      Navigator.pop(context);
                      try {
                        if (a.Platform.isAndroid) {
                          Share.share(
                              "${app_info.projectName}\n${app_info.androidLink}${app_info.packageName}\n");
                        } else {
                          Share.share(
                              "${app_info.projectName}\n${app_info.iosLink}${app_info.iosAppId}");
                        }
                      } catch (e) {}
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ✨ Glassmorphism Settings Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF94A3B8), Color(0xFF64748B)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF94A3B8).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.settings_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'settings'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                    iconColor: Colors.white.withOpacity(0.7),
                    collapsedIconColor: Colors.white.withOpacity(0.5),
                    children: [
                      // Language Selector
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Container(
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.07),
                                Colors.white.withOpacity(0.03),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.language_rounded,
                                    color: Color(0xFF64B5F6),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'language'.tr,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              _buildLanguageOption('en_US', 'english'.tr),
                              _buildLanguageOption('hi_IN', 'hindi'.tr),
                              _buildLanguageOption('bho_IN', 'bhojpuri'.tr),
                            ],
                          ),
                        ),
                      ),

                      // Account Management Options
                      id == null || id == ''
                          ? SizedBox()
                          : _buildDarkDrawerItem(
                              icon: Icons.delete_outline_rounded,
                              title: 'deactivate_account'.tr,
                              iconColor: Color(0xFFEF4444),
                              onTap: () async {
                                Navigator.pop(context);
                                SharedPreferences pref =
                                    await SharedPreferences.getInstance();
                                String? id = pref.getString('mobile');
                                print('Drawer Id -------${id}');

                                showDialog<void>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('delete_account'.tr),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          children: <Widget>[
                                            Text('delete_confirmation'.tr),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('yes'.tr),
                                          onPressed: () async {
                                            if (id != null) {
                                              final querySnapshot = await FirebaseFirestore.instance
                                                  .collection('register')
                                                  .where('mobile', isEqualTo: id)
                                                  .get();
                                              for (var doc in querySnapshot.docs) {
                                                await doc.reference.delete();
                                              }
                                            }
                                            await pref.clear();
                                            Navigator.of(context).pop();
                                            Get.offAll(() => MyRegister());
                                            Fluttertoast.showToast(
                                                msg: "Your account is deleted");
                                          },
                                        ),
                                        TextButton(
                                          child: Text('no'.tr),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                      id == null || id == ''
                          ? SizedBox()
                          : _buildDarkDrawerItem(
                              icon: Icons.logout_rounded,
                              title: 'logout'.tr,
                              iconColor: Color(0xFFF97316),
                              onTap: () async {
                                Navigator.pop(context);
                                SharedPreferences sp =
                                    await SharedPreferences.getInstance();
                                sp.setString('mobile', '');
                                sp.setString('useId', '');
                                Get.offAll(() => MyRegister());
                              },
                            ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            // ✨ Neon Social Media Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.06),
                      Colors.white.withOpacity(0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Follow Us header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 30,
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0xFFFFD700).withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'FOLLOW US',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFD700).withOpacity(0.8),
                            letterSpacing: 3,
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          width: 30,
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFFD700).withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNeonSocialButton(
                          FontAwesomeIcons.instagram,
                          Color(0xFFE1306C),
                          'Instagram',
                          () => _launchUrl(
                              "https://www.instagram.com/theshreebalaji/?igsh=amZnczh0ZnlneGdj"),
                        ),
                        _buildNeonSocialButton(
                          FontAwesomeIcons.facebook,
                          Color(0xFF1877F2),
                          'Facebook',
                          () => _launchUrl(
                              "https://www.facebook.com/people/Shree-Balaji/pfbid02kvDi8B6qPzswMYHKDo2VLY4ktChFk1GQosHU8GMon8kiTgRxpCQp18dSiiDL5Ha3l/?mibextid=qi2Omg&rdid=xOYclUullAbBqnCK&share_url=https%3A%2F%2Fwww.facebook.com%2Fshare%2FvzNj95cMMoy1j1ig%2F%3Fmibextid%3Dqi2Omg"),
                        ),
                        _buildNeonSocialButton(
                          FontAwesomeIcons.youtube,
                          Color(0xFFFF0000),
                          'YouTube',
                          () => _launchUrl(
                              "https://www.youtube.com/@shreebalaji6677"),
                        ),
                        _buildNeonSocialButton(
                          FontAwesomeIcons.whatsapp,
                          Color(0xFF25D366),
                          'WhatsApp',
                          () => _launchWhatsapp("7505891747"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Bottom branding
            Center(
              child: Text(
                "Made with ❤️ in India",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.25),
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    EdgeInsetsGeometry? padding,
  }) {
    return ListTile(
      contentPadding: padding ?? EdgeInsets.symmetric(horizontal: 20.0),
      leading: Icon(icon, color: iconColor ?? app_info.primaryColor, size: 26),
      title: Text(
        title,
        style: TextStyle(
          color: app_info.primaryColor,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      trailing:
          Icon(Icons.arrow_forward_ios, size: 16, color: app_info.primaryColor),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      tileColor: Colors.transparent,
      hoverColor: app_info.primaryColor.withOpacity(0.1),
    );
  }

  // ✨ Premium Menu Item with glassmorphism
  Widget _buildPremiumMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> iconGradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white.withOpacity(0.05),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Gradient icon container
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: iconGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: iconGradient[0].withOpacity(0.4),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.4),
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dark drawer item for settings subsection
  Widget _buildDarkDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withOpacity(0.05),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor ?? Colors.white.withOpacity(0.7), size: 22),
                SizedBox(width: 14),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Spacer(),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white.withOpacity(0.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernMenuItem({
    required IconData icon,
    required String title,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: app_info.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.9),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String value, String title) {
    return Obx(() => Container(
          margin: EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: languageController.currentLanguage.value == value
                ? Colors.white.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: languageController.currentLanguage.value == value
                ? Border.all(color: Color(0xFF64B5F6).withOpacity(0.3), width: 1)
                : null,
          ),
          child: RadioListTile<String>(
            title: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: languageController.currentLanguage.value == value
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: languageController.currentLanguage.value == value
                    ? Colors.white
                    : Colors.white.withOpacity(0.6),
              ),
            ),
            value: value,
            groupValue: languageController.currentLanguage.value,
            onChanged: (value) {
              if (value != null) {
                languageController.changeLanguage(value);
              }
            },
            activeColor: Color(0xFF64B5F6),
            dense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ));
  }

  Widget _socialButton(FaIconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFFFE4E1),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.7),
            width: 1.5,
          ),
        ),
        child: FaIcon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildStunningSocialButton(
    FaIconData icon,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              spreadRadius: -2,
              blurRadius: 8,
              offset: Offset(-2, -2),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: FaIcon(
          icon,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  // ✨ Neon Social Button with glow effect
  Widget _buildNeonSocialButton(
    FaIconData icon,
    Color color,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withOpacity(0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: FaIcon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 130,
      leadingWidth: 65,
      leading: Container(
        margin: EdgeInsets.only(left: 12),
        child: IconButton(
          icon: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.sort, size: 30, color: app_info.primaryColor),
          ),
          onPressed: () {
            if (scaffoldKey.currentState?.isDrawerOpen ?? false) {
              scaffoldKey.currentState?.closeDrawer();
            } else {
              scaffoldKey.currentState?.openDrawer();
            }
          },
        ),
      ),
      title: Hero(
        tag: 'logo',
        child: Container(
          height: 95,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Image.asset("assets/images/logo.png", height: 95),
        ),
      ),
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFFFE4E1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: app_info.primaryColor.withOpacity(0.25),
              blurRadius: 12,
              offset: Offset(0, 2),
            )
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: IconButton(
            icon: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: app_info.primaryColor.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Icon(Icons.notifications_none_outlined,
                  size: 30, color: app_info.primaryColor),
            ),
            onPressed: () {
              // Notification action can be added here
            },
          ),
        ),
      ],
    );
  }

  Widget _getBodyWidget() {
    return Column(
      children: [
        Expanded(
          child: _getSelectedTabContent(),
        ),
      ],
    );
  }

  Widget _getSelectedTabContent() {
    if (_selectedIndex == 0) {
      return Center(child: ContactUs_Screen());
    } else if (_selectedIndex == 1) {
      return Center(child: Bank());
    } else if (_selectedIndex == 2) {
      return Center(child: RatePage());
    } else if (_selectedIndex == 3) {
      return Center(child: Gallery());
    } else if (_selectedIndex == 4) {
      return Center(child: LiveMcx());
    } else {
      return Container();
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            app_info.primaryColor,
            app_info.primaryLightColor,
            app_info.accentColor,
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: app_info.primaryColor.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main Navigation Bar
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.contact_phone_rounded,
                    label: 'contact_us'.tr,
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.account_balance_rounded,
                    label: 'bank'.tr,
                    index: 1,
                  ),
                  // Center Floating Button
                  _buildCenterButton(),
                  _buildNavItem(
                    icon: Icons.shopping_bag_rounded,
                    label: 'products'.tr,
                    index: 3,
                  ),
                  _buildNavItem(
                    icon: Icons.show_chart_rounded,
                    label: 'mcx'.tr,
                    index: 4,
                  ),
                ],
              ),
            ),

            // Footer Section
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    app_info.whiteColor.withOpacity(0.1),
                    app_info.whiteColor.withOpacity(0.05),
                  ],
                ),
                border: Border(
                  top: BorderSide(
                    color: app_info.whiteColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.copyright_rounded,
                        size: 14,
                        color: app_info.whiteColor.withOpacity(0.9),
                      ),
                      SizedBox(width: 4),
                      Text(
                        app_info.projectName,
                        style: TextStyle(
                          fontSize: 11,
                          color: app_info.whiteColor.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          app_info.amberColor,
                          app_info.orangeColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: app_info.amberColor.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 12,
                          color: app_info.whiteColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'powered_by'.tr,
                          style: TextStyle(
                            fontSize: 10,
                            color: app_info.whiteColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    app_info.whiteColor.withOpacity(0.25),
                    app_info.whiteColor.withOpacity(0.15),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: app_info.whiteColor.withOpacity(0.3),
                  width: 1.5,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.all(isSelected ? 8 : 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? app_info.whiteColor.withOpacity(0.2)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? app_info.whiteColor
                    : app_info.whiteColor.withOpacity(0.6),
                size: isSelected ? 26 : 24,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? app_info.whiteColor
                    : app_info.whiteColor.withOpacity(0.6),
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    final isSelected = _selectedIndex == 2;

    return GestureDetector(
      onTap: () => _onItemTapped(2),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0, isSelected ? -8 : -5, 0),
        child: Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [
                      app_info.amberColor,
                      app_info.orangeColor,
                    ]
                  : [
                      app_info.whiteColor,
                      app_info.whiteColor.withOpacity(0.95),
                    ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? app_info.amberColor.withOpacity(0.6)
                    : app_info.whiteColor.withOpacity(0.5),
                blurRadius: isSelected ? 20 : 15,
                spreadRadius: isSelected ? 4 : 2,
              ),
              BoxShadow(
                color: app_info.primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: app_info.whiteColor.withOpacity(0.3),
              width: 3,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: isSelected ? app_info.whiteColor : app_info.primaryColor,
                size: 32,
              ),
              SizedBox(height: 2),
              Text(
                'live_bhaw'.tr,
                style: TextStyle(
                  color:
                      isSelected ? app_info.whiteColor : app_info.primaryColor,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Cant open URL';
    }
  }

  _makingPhoneCall(String number) async {
    final url = 'tel:+91$number';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchWhatsapp(String number) async {
    final url = "https://wa.me/91$number?text=Your Message here";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void openGooglePlayStore() async {
    final url =
        'https://play.google.com/store/apps/details?id=${app_info.packageName}&hl=en';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("error");
    }
  }

  Widget _myMarquee(data) {
    String messages1 = '';
    for (var element in data.docs) {
      messages1 = messages1 + element.get('message') + '     ';
    }
    if (messages1.length < 50) {
      return Text(
        messages1,
        style: TextStyle(fontWeight: FontWeight.bold, color: app_info.bgColor),
      );
    } else {
      return Center(
        child: Marquee(
          text: messages1,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: app_info.whiteColor),
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
        ),
      );
    }
  }

  void openAppStore() async {
    final String appId = '';
    final url = 'https://apps.apple.com/app/id$appId';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("error");
    }
  }
}
