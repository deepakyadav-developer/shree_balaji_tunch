import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/Get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../register.dart';
import 'my_bottomBar.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  var _visible = true;

  AnimationController animationController;
  Animation<double> animation;
  Animation<double> fadeAnimation;

  startTimer() {
    Future.delayed(const Duration(seconds: 3), _getData);
  }

  @override
  void initState() {
    _checkDeveloperMode();
    // playSound();

    super.initState();

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeOutBack);
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    animation.addListener(() => setState(() {}));
    animationController.forward();

    setState(() {
      _visible = !_visible;
    });
  }

  Future<void> _checkDeveloperMode() async {
    // Only check developer mode in release builds
    if (kReleaseMode && Platform.isAndroid) {
      try {
        final deviceInfoPlugin = DeviceInfoPlugin();
        final androidInfo = await deviceInfoPlugin.androidInfo;
        final isDeveloperModeEnabled = androidInfo.isPhysicalDevice != null &&
            await _isDeveloperModeEnabled();

        if (isDeveloperModeEnabled) {
          _showDeveloperModeDialog();
        } else {
          startTimer();
        }
      } catch (e) {
        print("Error checking developer mode: $e");
        startTimer();
      }
    } else {
      // In debug mode or non-Android platforms, just proceed
      startTimer();
    }
  }

  Future<bool> _isDeveloperModeEnabled() async {
    try {
      const platform = MethodChannel('com.shreebalajitunch/developer_mode');
      final bool result = await platform.invokeMethod('isDeveloperModeEnabled');
      return result;
    } on PlatformException catch (e) {
      print("Failed to get developer mode: ${e.message}");
      return false;
    }
  }

  void _showDeveloperModeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Developer Mode Detected'),
          content: Text(
              'Please turn off Developer Mode to use this application. Go to Settings > System > Developer options and turn it off.'),
          actions: <Widget>[
            TextButton(
              child: Text('Exit App'),
              onPressed: () {
                SystemNavigator.pop();
              },
            ),
            TextButton(
              child: Text('I\'ve Turned it Off'),
              onPressed: () {
                Navigator.of(context).pop();
                Future.delayed(Duration(milliseconds: 500), () async {
                  final isDeveloperModeStillEnabled =
                      await _isDeveloperModeEnabled();
                  if (isDeveloperModeStillEnabled) {
                    _showDeveloperModeDialog();
                  } else {
                    startTimer();
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Configure upgrader with basic settings
    final upgrader = Upgrader()
      ..countryCode = 'IN'
      ..debugDisplayAlways = false
      ..showIgnore = false
      ..showLater = false
      ..minAppVersion = '2.0.0';

    return UpgradeAlert(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                const Color(0xFF800020), // Dark maroon
                const Color(0xFF5D0015), // Deeper maroon
                const Color(0xFF3A000E), // Very deep maroon
                const Color(0xFF1A0008), // Almost black maroon
              ],
              stops: [0.1, 0.4, 0.7, 0.9],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // Background decoration elements
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -80,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),

              // Main content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Logo with shadow and glow effect
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                    child: FadeTransition(
                      opacity: fadeAnimation,
                      child: ScaleTransition(
                        scale: animation,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 220,
                            height: 220,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Custom animated loader
                  FadeTransition(
                    opacity: fadeAnimation,
                    child: Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Loading text with shimmer effect
                  FadeTransition(
                    opacity: fadeAnimation,
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [Colors.white, Colors.amber, Colors.white],
                          stops: [0.0, 0.5, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          tileMode: TileMode.mirror,
                        ).createShader(bounds);
                      },
                      child: const Text(
                        'Loading...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Welcome text at bottom
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: Column(
                    children: [
                      const Text(
                        'Welcome to',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Shree Balaji Tunch',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 50,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getData() async {
    if (Platform.isIOS) {
      // Get.offAll(() => const HomePage());
    } else {
      SharedPreferences sp = await SharedPreferences.getInstance();
      if (sp.getString("mobile") == null) {
        Get.offAll(() => MyRegister());
      } else {
        Get.offAll(() => MyBottomBar());
      }
    }
  }
}

// Simple Shimmer effect widget for text
class ShimmerText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const ShimmerText({Key key, this.text, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [Colors.white, Colors.amber, Colors.white],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          tileMode: TileMode.mirror,
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}
