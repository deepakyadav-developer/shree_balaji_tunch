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

import '../../constant/app_info.dart';
import '../main_screens/Mcx.dart';
import '../main_screens/bank_page.dart';
import '../main_screens/gallery.dart';
import '../main_screens/rate_page.dart';
import 'package:shreebalaji_tounch/constant/app_info.dart' as app_info;

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
      elevation: 10,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFFAF0E6),
              Color(0xFFFFE4E1),
            ],
          ),
        ),
        child: ListView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 260,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF800000),
                    Color(0xFF5D0000),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'drawer_logo',
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        "assets/images/logo.png",
                        height: 160,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Shree Balaji",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Tunch ",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1,
                      ),
                    ),
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

            // Menu Items with improved design
            _buildDrawerItem(
              icon: Icons.shopping_bag_outlined,
              title: 'shop_now'.tr,
              onTap: () {
                Get.to(() => ShopNow());
              },
            ),
            _buildDrawerItem(
              icon: Icons.star_border_outlined,
              title: 'leave_review'.tr,
              onTap: () {
                Navigator.pop(context);
                if (a.Platform.isAndroid) {
                  openGooglePlayStore();
                } else if (a.Platform.isIOS) {
                  openAppStore();
                }
              },
            ),
            _buildDrawerItem(
              icon: Icons.share_outlined,
              title: 'share_app'.tr,
              onTap: () {
                Navigator.pop(context);
                try {
                  if (a.Platform.isAndroid) {
                    Share.share("$projectName\n$androidLink$packageName\n");
                  } else {
                    Share.share("$projectName\n$iosLink$iosAppId");
                  }
                } catch (e) {}
              },
            ),

            // Settings section with modernized design
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                colorScheme: ColorScheme.light(
                  primary: Color(0xFF800000),
                ),
              ),
              child: ExpansionTile(
                leading: Icon(
                  Icons.settings_outlined,
                  color: Color(0xFF800000),
                  size: 26,
                ),
                title: Text(
                  'settings'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF800000),
                  ),
                ),
                iconColor: Color(0xFF800000),
                collapsedIconColor: Color(0xFF800000),
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
                            color: Color(0xFF800000).withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: Color(0xFF800000).withOpacity(0.2),
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
                                color: Color(0xFF800000),
                                size: 22,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'language'.tr,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF800000),
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

            // Social Media Icons with new design
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Color(0xFFFFE4E1),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF800000).withOpacity(0.25),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: Color(0xFF800000).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Color(0xFF800000),
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Follow Us',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF800000),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _socialButton(
                        FontAwesomeIcons.instagram,
                        Colors.purple,
                        () => _launchUrl(
                            "https://www.instagram.com/theshreebalaji/?igsh=amZnczh0ZnlneGdj"),
                      ),
                      _socialButton(
                        FontAwesomeIcons.facebook,
                        Colors.blue,
                        () => _launchUrl(
                            "https://www.facebook.com/people/Shree-Balaji/pfbid02kvDi8B6qPzswMYHKDo2VLY4ktChFk1GQosHU8GMon8kiTgRxpCQp18dSiiDL5Ha3l/?mibextid=qi2Omg&rdid=xOYclUullAbBqnCK&share_url=https%3A%2F%2Fwww.facebook.com%2Fshare%2FvzNj95cMMoy1j1ig%2F%3Fmibextid%3Dqi2Omg"),
                      ),
                      _socialButton(
                        FontAwesomeIcons.youtube,
                        Colors.red,
                        () => _launchUrl(
                            "https://www.youtube.com/@shreebalaji6677"),
                      ),
                      _socialButton(
                        FontAwesomeIcons.whatsapp,
                        Colors.green,
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
      leading: Icon(icon, color: iconColor ?? Color(0xFF800000), size: 26),
      title: Text(
        title,
        style: TextStyle(
          color: Color(0xFF800000),
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      trailing:
          Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF800000)),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      tileColor: Colors.transparent,
      hoverColor: Color(0xFF800000).withOpacity(0.1),
    );
  }

  Widget _buildLanguageOption(String value, String title) {
    return Obx(() => Container(
          margin: EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: languageController.currentLanguage.value == value
                ? Color(0xFF800000).withOpacity(0.1)
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
                color: Color(0xFF800000),
              ),
            ),
            value: value,
            groupValue: languageController.currentLanguage.value,
            onChanged: (value) {
              if (value != null) {
                languageController.changeLanguage(value);
              }
            },
            activeColor: Color(0xFF800000),
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
            child: Icon(Icons.sort, size: 30, color: Color(0xFF800000)),
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
              color: Color(0xFF800000).withOpacity(0.25),
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
                    color: Color(0xFF800000).withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Icon(Icons.notifications_none_outlined,
                  size: 30, color: Color(0xFF800000)),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF800000), // Maroon
                Color(0xFF4A0000), // Darker maroon
              ],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomNavigationBar(
              unselectedItemColor: Colors.white.withOpacity(0.7),
              selectedItemColor: Colors.white, // White color
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  backgroundColor: Colors.transparent,
                  icon: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.all(_selectedIndex == 0 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 0
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.contact_phone),
                  ),
                  label: 'contact_us'.tr,
                ),
                BottomNavigationBarItem(
                  backgroundColor: Colors.transparent,
                  icon: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.all(_selectedIndex == 1 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 1
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.account_balance),
                  ),
                  label: 'bank'.tr,
                ),
                BottomNavigationBarItem(
                  backgroundColor: Colors.transparent,
                  icon: Container(
                    height: 60,
                    width: 60,
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            spreadRadius: 2,
                            blurRadius: 8,
                          )
                        ]),
                    child: const Icon(Icons.bar_chart_sharp,
                        color: Color(0xFF800000), size: 30),
                  ),
                  label: 'live_bhaw'.tr,
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.all(_selectedIndex == 3 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 3
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.production_quantity_limits),
                  ),
                  label: 'products'.tr,
                  backgroundColor: Colors.transparent,
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.all(_selectedIndex == 4 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 4
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.launch),
                  ),
                  label: 'mcx'.tr,
                  backgroundColor: Colors.transparent,
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
              color: Color(0xFF800000).withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(0, -1),
            )
          ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '@ $projectName',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF800000),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'powered_by'.tr,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF800000),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
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
        'https://play.google.com/store/apps/details?id=$packageName&hl=en';

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
              fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
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
