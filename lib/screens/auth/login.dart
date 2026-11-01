import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shreebalaji_tounch/screens/base/my_bottomBar.dart';
import 'package:shreebalaji_tounch/screens/register.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  // Empty by default (no prefilled dummy numbers)
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _step = 0; // 0: Mobile Number, 1: OTP Verification
  bool _isLoading = false;
  String? _verificationId;
  int? _resendToken;

  // Modern color scheme matching MyRegister exactly
  final Color primaryColor = const Color(0xFF2C3E50); // Deep blue-gray
  final Color accentColor = const Color(0xFFE8B44F); // Golden yellow
  final Color backgroundColor = const Color(0xFF1E2A35); // Dark blue-gray
  final Color cardColor = const Color(0xFF2A3A47); // Card background

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _showLoadingDialog(String message) {
    Get.defaultDialog(
      title: 'Please Wait',
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      backgroundColor: backgroundColor,
      barrierDismissible: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          CupertinoActivityIndicator(
            radius: 14,
            color: accentColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // Step 1: Check in Firebase if user exists, then send real Firebase OTP
  Future<void> _sendFirebaseOtp() async {
    String mobile = _mobileController.text.trim();

    if (mobile.isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter your mobile number',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (mobile.length != 10) {
      Get.snackbar(
        'Invalid Number',
        'Please enter a valid 10-digit mobile number',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isLoading = true);
    _showLoadingDialog('Checking account in Firebase...');

    try {
      // 1. CONDITION: Check if mobile number exists in Firebase Firestore 'register' collection
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('register')
          .where('mobile', isEqualTo: mobile)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        // Number NOT found in Firebase -> DO NOT SEND OTP
        if (Get.isDialogOpen ?? false) Get.back();
        setState(() => _isLoading = false);

        Get.snackbar(
          'Account Not Found',
          'Mobile number $mobile is not registered. Please create an account first.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM,
          mainButton: TextButton(
            onPressed: () {
              Get.to(() => const MyRegister());
            },
            child: const Text(
              'REGISTER NOW',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        return;
      }

      // 2. Number exists -> Send official SMS OTP via Firebase Authentication
      if (Get.isDialogOpen ?? false) Get.back();
      _showLoadingDialog('Dispatching OTP via Firebase SMS...');

      String fullPhoneNumber = '+91$mobile';

      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Instant auto-verification by Android OS (if supported)
          try {
            UserCredential userCredential =
                await _auth.signInWithCredential(credential);
            if (userCredential.user != null) {
              await _completeLoginProcess(mobile);
            }
          } catch (_) {}
        },
        verificationFailed: (FirebaseAuthException e) {
          if (Get.isDialogOpen ?? false) Get.back();
          setState(() => _isLoading = false);

          String errorMsg = e.message ?? 'Verification failed';
          if (e.code == 'invalid-phone-number') {
            errorMsg = 'The provided phone number is invalid.';
          } else if (e.code == 'too-many-requests') {
            errorMsg =
                'Too many SMS requests sent. Please try again after a few minutes.';
          }

          Get.snackbar(
            'Firebase Auth Error',
            errorMsg,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          if (Get.isDialogOpen ?? false) Get.back();
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _step = 1;
            _isLoading = false;
            _otpController.clear(); // NO AUTOFILL - user types manually!
          });

          Get.snackbar(
            'OTP Sent',
            'Official Firebase SMS OTP sent to $fullPhoneNumber. Please enter it below.',
            backgroundColor: Colors.green.shade800,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.TOP,
            icon: const Icon(Icons.sms_outlined, color: Colors.white),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        'Failed to connect to Firebase: ${e.toString()}',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Step 2: Verify user-typed OTP with Firebase servers
  Future<void> _verifyOtpAndLogin() async {
    String enteredOtp = _otpController.text.trim();
    String mobile = _mobileController.text.trim();

    if (enteredOtp.isEmpty || enteredOtp.length != 6) {
      Get.snackbar(
        'Invalid OTP',
        'Please enter the complete 6-digit OTP received via SMS',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_verificationId == null) {
      Get.snackbar(
        'Session Expired',
        'OTP session expired. Please request a new OTP.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isLoading = true);
    _showLoadingDialog('Verifying OTP with Firebase servers...');

    try {
      // Create Firebase Phone Auth credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: enteredOtp,
      );

      // Sign in with Firebase Authentication
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _completeLoginProcess(mobile);
      } else {
        if (Get.isDialogOpen ?? false) Get.back();
        setState(() => _isLoading = false);
        Get.snackbar(
          'Verification Failed',
          'Could not authenticate credentials with Firebase.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      setState(() => _isLoading = false);

      String errorMsg = 'Invalid verification code';
      if (e.code == 'invalid-verification-code') {
        errorMsg =
            'Incorrect OTP entered. Please check your SMS and try again.';
      } else if (e.code == 'session-expired') {
        errorMsg = 'The OTP has expired. Please tap Resend OTP.';
      }

      Get.snackbar(
        'Verification Error',
        errorMsg,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        'Authentication error: ${e.toString()}',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _completeLoginProcess(String mobile) async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    // Fetch user details from Firestore 'register' collection
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('register')
        .where('mobile', isEqualTo: mobile)
        .limit(1)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      var userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
      await sp.setString('mobile', mobile);
      await sp.setString('name', userData['name']?.toString() ?? '');
      await sp.setString('firmName', userData['firmName']?.toString() ?? '');
      await sp.setString('city', userData['city']?.toString() ?? '');
      await sp.setString('userId', userData['userId']?.toString() ?? '');
    } else {
      await sp.setString('mobile', mobile);
    }

    await sp.setBool('isGuest', false);

    if (Get.isDialogOpen ?? false) Get.back();

    Get.snackbar(
      'Login Successful',
      'Welcome to Shree Balaji Tunch!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );

    Get.offAll(() => const MyBottomBar());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor,
              const Color(0xFF1A2530),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 20.0 : 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: isSmallScreen ? 20 : 35),

                        // Official Brand Logo (Replacing SBT text)
                        Center(
                          child: Container(
                            width: isSmallScreen ? 85 : 95,
                            height: isSmallScreen ? 85 : 95,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cardColor.withOpacity(0.6),
                              border: Border.all(
                                color: accentColor,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.25),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/playstore-icon.png',
                                    fit: BoxFit.contain,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 25 : 30),

                        // Header with gold accent bar
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 4,
                              height: isSmallScreen ? 35 : 45,
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                _step == 0 ? 'Sign In' : 'Verify SMS OTP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 28 : 34,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            _step == 0
                                ? 'Enter your registered mobile number'
                                : 'Enter the 6-digit SMS code sent by Firebase to +91 ${_mobileController.text}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: isSmallScreen ? 13 : 15,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 30 : 40),

                        // Step 0: Mobile Number Input
                        if (_step == 0) ...[
                          _buildMobileField(isSmallScreen),
                          SizedBox(height: isSmallScreen ? 25 : 35),
                          _buildActionButton(
                            label: 'SEND FIREBASE OTP',
                            onTap: _sendFirebaseOtp,
                            isSmallScreen: isSmallScreen,
                          ),
                        ] else ...[
                          // Step 1: OTP Input (NO AUTOFILL - user manually inputs)
                          _buildOtpField(isSmallScreen),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _step = 0;
                                    _otpController.clear();
                                  });
                                },
                                icon: Icon(Icons.edit_rounded,
                                    size: 16, color: accentColor),
                                label: Text(
                                  'Change Number',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _sendFirebaseOtp,
                                child: Text(
                                  'Resend OTP',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 25),
                          _buildActionButton(
                            label: 'VERIFY & SIGN IN',
                            onTap: _verifyOtpAndLogin,
                            isSmallScreen: isSmallScreen,
                          ),
                        ],

                        SizedBox(height: isSmallScreen ? 15 : 20),

                        // Continue as Guest (Crucial for Apple Review)
                        Center(
                          child: TextButton(
                            onPressed: () async {
                              SharedPreferences sp =
                                  await SharedPreferences.getInstance();
                              await sp.setBool('isGuest', true);
                              Get.offAll(() => const MyBottomBar());
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              'Continue as Guest',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: isSmallScreen ? 15 : 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Create Account link
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Get.to(() => const MyRegister());
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: RichText(
                              text: TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: isSmallScreen ? 14 : 16,
                                  letterSpacing: 0.3,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Create Account',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileField(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cardColor.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _mobileController,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        style: TextStyle(
          color: Colors.white,
          fontSize: isSmallScreen ? 15 : 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        decoration: InputDecoration(
          counterText: '',
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.phone_android_rounded,
                  color: accentColor,
                  size: isSmallScreen ? 20 : 22,
                ),
                const SizedBox(width: 8),
                Text(
                  '+91',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  height: 18,
                  width: 1,
                  color: Colors.white24,
                ),
              ],
            ),
          ),
          hintText: 'Enter 10-digit Mobile Number',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: isSmallScreen ? 13 : 15,
            letterSpacing: 0.3,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 16 : 20,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withOpacity(0.7),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _otpController,
        keyboardType: TextInputType.number,
        maxLength: 6,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: accentColor,
          fontSize: isSmallScreen ? 20 : 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 12,
        ),
        decoration: InputDecoration(
          counterText: '',
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(
              Icons.lock_clock_rounded,
              color: accentColor,
              size: isSmallScreen ? 20 : 22,
            ),
          ),
          hintText: 'Enter 6-digit OTP',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 16,
            letterSpacing: 2,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 14 : 18,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return Container(
      width: double.infinity,
      height: isSmallScreen ? 50 : 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? CupertinoActivityIndicator(color: backgroundColor)
            : Text(
                label,
                style: TextStyle(
                  color: backgroundColor,
                  fontSize: isSmallScreen ? 15 : 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }
}
