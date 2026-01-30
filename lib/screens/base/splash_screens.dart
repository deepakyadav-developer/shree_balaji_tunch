import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/Get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

import '../../constant/app_info.dart' as app_info;
import '../register.dart';
import 'my_bottomBar.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  var _visible = true;

  late AnimationController animationController;
  late AnimationController pulseController;
  late AnimationController rotationController;
  late Animation<double> animation;
  late Animation<double> fadeAnimation;
  late Animation<double> pulseAnimation;
  late Animation<double> rotationAnimation;

  startTimer() {
    Future.delayed(const Duration(seconds: 3), _getData);
  }

  @override
  void initState() {
    _checkDeveloperMode();
    super.initState();

    // Main scale animation
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.elasticOut);
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    // Pulse animation for glow effect
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );

    // Rotation animation for decorative elements
    rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    rotationAnimation =
        Tween<double>(begin: 0, end: 1).animate(rotationController);

    animation.addListener(() => setState(() {}));
    animationController.forward();

    setState(() {
      _visible = !_visible;
    });
  }

  Future<void> _checkDeveloperMode() async {
    if (kReleaseMode && Platform.isAndroid) {
      try {
        final isDeveloperModeEnabled = await _isDeveloperModeEnabled();

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
    pulseController.dispose();
    rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return UpgradeAlert(
      upgrader: Upgrader(
        messages: MyHindiMessages(),
      ),
      dialogStyle: UpgradeDialogStyle.cupertino,
      showIgnore: false,
      showLater: false,
      shouldPopScope: () => true,
      child: Scaffold(
        body: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                app_info.primaryDarkColor,
                app_info.primaryColor,
                app_info.primaryLightColor,
                app_info.accentColor,
              ],
              stops: [0.0, 0.3, 0.6, 1.0],
            ),
          ),
          child: Stack(
            children: <Widget>[
              // Animated background circles
              ...List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: rotationAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: size.height * (0.1 + index * 0.3) -
                          (100 * rotationAnimation.value),
                      right: size.width * (0.2 + index * 0.2) -
                          (80 * rotationAnimation.value),
                      child: Container(
                        width: 150 + (index * 50),
                        height: 150 + (index * 50),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              app_info.whiteColor.withValues(alpha: 0.05),
                              app_info.whiteColor.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

              // Floating particles effect
              ...List.generate(15, (index) {
                return AnimatedBuilder(
                  animation: pulseAnimation,
                  builder: (context, child) {
                    return Positioned(
                      left: (index * 50.0) % size.width,
                      top: (index * 80.0) % size.height,
                      child: Opacity(
                        opacity: 0.3 * pulseAnimation.value,
                        child: Container(
                          width: 4 + (index % 3) * 2,
                          height: 4 + (index % 3) * 2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: app_info.amberColor,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    app_info.amberColor.withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Logo with advanced animations
                    AnimatedBuilder(
                      animation: pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: app_info.amberColor.withValues(
                                    alpha: 0.3 * pulseAnimation.value),
                                blurRadius: 40 * pulseAnimation.value,
                                spreadRadius: 20 * pulseAnimation.value,
                              ),
                              BoxShadow(
                                color: app_info.orangeColor.withValues(
                                    alpha: 0.2 * pulseAnimation.value),
                                blurRadius: 60 * pulseAnimation.value,
                                spreadRadius: 30 * pulseAnimation.value,
                              ),
                            ],
                          ),
                          child: FadeTransition(
                            opacity: fadeAnimation,
                            child: ScaleTransition(
                              scale: animation,
                              child: Container(
                                padding: EdgeInsets.all(size.width * 0.04),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      app_info.whiteColor
                                          .withValues(alpha: 0.2),
                                      app_info.whiteColor
                                          .withValues(alpha: 0.05),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: app_info.amberColor
                                        .withValues(alpha: 0.4),
                                    width: 3,
                                  ),
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(size.width * 0.03),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: app_info.whiteColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: app_info.whiteColor
                                            .withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    width: size.width * 0.45,
                                    height: size.width * 0.45,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: size.height * 0.08),

                    // Animated loading indicator
                    FadeTransition(
                      opacity: fadeAnimation,
                      child: AnimatedBuilder(
                        animation: pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  app_info.amberColor.withValues(alpha: 0.2),
                                  app_info.orangeColor.withValues(alpha: 0.2),
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  app_info.amberColor,
                                ),
                                strokeWidth: 3,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),

                    // Loading text with gradient
                    FadeTransition(
                      opacity: fadeAnimation,
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              app_info.whiteColor,
                              app_info.amberColor,
                              app_info.orangeColor,
                              app_info.whiteColor,
                            ],
                            stops: [0.0, 0.3, 0.7, 1.0],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: Text(
                          'Loading...',
                          style: TextStyle(
                            color: app_info.whiteColor,
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom branding section
              Positioned(
                bottom: size.height * 0.08,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Welcome to',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: app_info.whiteColor.withValues(alpha: 0.8),
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              app_info.amberColor,
                              app_info.orangeColor,
                              app_info.amberColor,
                            ],
                          ).createShader(bounds);
                        },
                        child: Text(
                          'Shree Balaji Tunch',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: app_info.whiteColor,
                            fontSize: size.width * 0.065,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),
                      AnimatedBuilder(
                        animation: pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 60 * pulseAnimation.value,
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  app_info.amberColor,
                                  app_info.orangeColor,
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: app_info.amberColor
                                      .withValues(alpha: 0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Version text
              Positioned(
                bottom: size.height * 0.02,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: Text(
                    'Version 1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: app_info.whiteColor.withValues(alpha: 0.5),
                      fontSize: size.width * 0.03,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                    ),
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
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (sp.getString("mobile") == null) {
      Get.offAll(() => MyRegister());
    } else {
      Get.offAll(() => MyBottomBar());
    }
  }
}

// Custom Hindi messages class for Upgrader
class MyHindiMessages extends UpgraderMessages {
  MyHindiMessages() : super(code: 'hi');

  @override
  String message(UpgraderMessage messageKey) {
    if (languageCode == 'hi') {
      switch (messageKey) {
        case UpgraderMessage.body:
          return 'नया अपडेट उपलब्ध है!';
        case UpgraderMessage.title:
          return 'अपडेट उपलब्ध';
        case UpgraderMessage.prompt:
          return 'क्या आप अभी अपडेट करना चाहते हैं?';
        case UpgraderMessage.buttonTitleIgnore:
          return 'नज़रअंदाज़ करें';
        case UpgraderMessage.buttonTitleLater:
          return 'बाद में';
        case UpgraderMessage.buttonTitleUpdate:
          return 'अभी अपडेट करें';
        default:
          break;
      }
    }
    return super.message(messageKey) ?? '';
  }
}
