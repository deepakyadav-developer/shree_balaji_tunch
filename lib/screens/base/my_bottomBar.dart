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
      id = pref.getString('mobile_number');
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
      mobile = sp.getString("mobile_number") ?? "";
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
      elevation: 20,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFFFFFFF),
              Color(0xFFF0F4F8),
            ],
          ),
        ),
        child: ListView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            // Stunning Header
            Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    app_info.primaryColor,
                    app_info.primaryLightColor,
                    app_info.accentColor,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: app_info.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Animated circles
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),
                      // Logo
                      Hero(
                        tag: 'drawer_logo',
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.3),
                                Colors.white.withValues(alpha: 0.1),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.5),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 3,
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Image.asset(
                              "assets/images/logo.png",
                              height: 100,
                              width: 100,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              Colors.white,
                              app_info.amberColor,
                              Colors.white
                            ],
                          ).createShader(bounds);
                        },
                        child: Text(
                          "Shree Balaji",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.25),
                              Colors.white.withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          "Computer Tunch & Lager Solding Center",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            Divider(
              thickness: 1,
              color: Colors.amber.withOpacity(0.5),
              indent: 20,
              endIndent: 20,
            ),
            SizedBox(height: 10),

            // Menu Items with stunning gradient cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildModernMenuItem(
                    icon: Icons.shopping_bag_rounded,
                    title: 'shop_now'.tr,
                    gradient: LinearGradient(
                      colors: [
                        app_info.primaryColor,
                        app_info.primaryLightColor,
                      ],
                    ),
                    onTap: () {
                      Get.to(() => ShopNow());
                    },
                  ),
                  SizedBox(height: 12),
                  _buildModernMenuItem(
                    icon: Icons.star_rounded,
                    title: 'leave_review'.tr,
                    gradient: LinearGradient(
                      colors: [
                        app_info.amberColor,
                        app_info.orangeColor,
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (a.Platform.isAndroid) {
                        openGooglePlayStore();
                      } else if (a.Platform.isIOS) {
                        openAppStore();
                      }
                    },
                  ),
                  SizedBox(height: 12),
                  _buildModernMenuItem(
                    icon: Icons.share_rounded,
                    title: 'share_app'.tr,
                    gradient: LinearGradient(
                      colors: [
                        app_info.accentColor,
                        app_info.primaryLightColor,
                      ],
                    ),
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

            // Settings section with modernized design
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                colorScheme: ColorScheme.light(
                  primary: app_info.primaryColor,
                ),
              ),
              child: ExpansionTile(
                leading: Icon(
                  Icons.settings_outlined,
                  color: app_info.primaryColor,
                  size: 26,
                ),
                title: Text(
                  'settings'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: app_info.primaryColor,
                  ),
                ),
                iconColor: app_info.primaryColor,
                collapsedIconColor: app_info.primaryColor,
                children: [
                  // Language Selector
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Color(0xFFFFE4E1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: app_info.primaryColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: app_info.primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.language,
                                color: app_info.primaryColor,
                                size: 22,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'language'.tr,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: app_info.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
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
                      : _buildDrawerItem(
                          icon: Icons.delete_outline,
                          title: 'deactivate_account'.tr,
                          iconColor: Colors.red,
                          padding: EdgeInsets.only(left: 32.0, right: 16.0),
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
                                      onPressed: () {
                                        if (id != null) {
                                          FirebaseFirestore.instance
                                              .collection('register')
                                              .doc(id)
                                              .delete();
                                        }
                                        pref.clear();
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
                      : _buildDrawerItem(
                          icon: Icons.logout,
                          title: 'logout'.tr,
                          padding: EdgeInsets.only(left: 32.0, right: 16.0),
                          onTap: () async {
                            Navigator.pop(context);
                            SharedPreferences sp =
                                await SharedPreferences.getInstance();
                            sp.setString('mobile', '');
                            sp.setString('useId', '');
                            Get.offAll(() => MyRegister());
                          },
                        ),
                ],
              ),
            ),

            SizedBox(height: Get.height * 0.05),

            // Social Media Section with stunning design
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    app_info.primaryColor.withOpacity(0.1),
                    app_info.accentColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: app_info.primaryColor.withOpacity(0.15),
                    spreadRadius: 2,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: app_info.primaryColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              app_info.primaryColor,
                              app_info.accentColor,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: app_info.primaryColor.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              app_info.primaryColor,
                              app_info.accentColor,
                            ],
                          ).createShader(bounds);
                        },
                        child: Text(
                          'Follow Us',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStunningSocialButton(
                        FontAwesomeIcons.instagram,
                        [
                          Color(0xFFC13584),
                          Color(0xFFE1306C),
                          Color(0xFFFD1D1D)
                        ],
                        () => _launchUrl(
                            "https://www.instagram.com/theshreebalaji/?igsh=amZnczh0ZnlneGdj"),
                      ),
                      _buildStunningSocialButton(
                        FontAwesomeIcons.facebook,
                        [Color(0xFF1877F2), Color(0xFF4267B2)],
                        () => _launchUrl(
                            "https://www.facebook.com/people/Shree-Balaji/pfbid02kvDi8B6qPzswMYHKDo2VLY4ktChFk1GQosHU8GMon8kiTgRxpCQp18dSiiDL5Ha3l/?mibextid=qi2Omg&rdid=xOYclUullAbBqnCK&share_url=https%3A%2F%2Fwww.facebook.com%2Fshare%2FvzNj95cMMoy1j1ig%2F%3Fmibextid%3Dqi2Omg"),
                      ),
                      _buildStunningSocialButton(
                        FontAwesomeIcons.youtube,
                        [Color(0xFFFF0000), Color(0xFFCC0000)],
                        () => _launchUrl(
                            "https://www.youtube.com/@shreebalaji6677"),
                      ),
                      _buildStunningSocialButton(
                        FontAwesomeIcons.whatsapp,
                        [Color(0xFF25D366), Color(0xFF128C7E)],
                        () => _launchWhatsapp("7505891747"),
                      ),
                    ],
                  ),
                ],
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
                ? app_info.primaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: RadioListTile<String>(
            title: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: languageController.currentLanguage.value == value
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: app_info.primaryColor,
              ),
            ),
            value: value,
            groupValue: languageController.currentLanguage.value,
            onChanged: (value) {
              if (value != null) {
                languageController.changeLanguage(value);
              }
            },
            activeColor: app_info.primaryColor,
            dense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ));
  }

  Widget _socialButton(IconData icon, Color color, VoidCallback onTap) {
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
    IconData icon,
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
