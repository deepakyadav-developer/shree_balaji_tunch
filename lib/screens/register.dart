import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shreebalaji_tounch/constant/app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'base/my_bottomBar.dart';

class MyRegister extends StatefulWidget {
  const MyRegister({super.key});

  @override
  _MyRegisterState createState() => _MyRegisterState();
}

class _MyRegisterState extends State<MyRegister> {
  TextEditingController nameController = TextEditingController();
  TextEditingController firmController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  // Modern color scheme matching the design
  final primaryColor = Color(0xFF2C3E50); // Deep blue-gray
  final accentColor = Color(0xFFE8B44F); // Golden yellow
  final backgroundColor = Color(0xFF1E2A35); // Dark blue-gray
  final cardColor = Color(0xFF2A3A47); // Card background

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
              Color(0xFF1A2530),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
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
                        SizedBox(height: isSmallScreen ? 20 : 30),
                        // Back button
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              color: accentColor,
                              size: 20,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 25 : 35),
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
                            SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                'Create Account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 28 : 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            'Please fill in the details below',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: isSmallScreen ? 14 : 16,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 35 : 45),
                        // Form fields
                        _buildTextField(
                          controller: nameController,
                          hintText: "Full Name",
                          icon: Icons.person_outline_rounded,
                          isSmallScreen: isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        _buildTextField(
                          controller: mobileController,
                          hintText: "Mobile Number",
                          icon: Icons.phone_android_rounded,
                          keyboardType: TextInputType.number,
                          isSmallScreen: isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        _buildTextField(
                          controller: firmController,
                          hintText: "Firm Name",
                          icon: Icons.business_rounded,
                          isSmallScreen: isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        _buildTextField(
                          controller: addressController,
                          hintText: "Address",
                          icon: Icons.location_on_outlined,
                          isSmallScreen: isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 35 : 45),
                        // Register button
                        _buildRegisterButton(isSmallScreen),
                        SizedBox(height: isSmallScreen ? 25 : 35),
                        // Sign in option
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, 'login');
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: RichText(
                              text: TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: isSmallScreen ? 14 : 16,
                                  letterSpacing: 0.3,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Sign In',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      decorationColor: accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isSmallScreen = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cardColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: Colors.white,
          fontSize: isSmallScreen ? 14 : 16,
          letterSpacing: 0.3,
        ),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 12, right: 8),
            child: Icon(
              icon,
              color: accentColor,
              size: isSmallScreen ? 20 : 22,
            ),
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: isSmallScreen ? 14 : 16,
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

  Widget _buildRegisterButton(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      height: isSmallScreen ? 50 : 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _sendOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Register',
          style: TextStyle(
            color: backgroundColor,
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  void _showDialogLoading() {
    Get.defaultDialog(
        title: 'Loading',
        onWillPop: () async => false,
        barrierDismissible: false,
        content: Column(
          children: const [
            CupertinoActivityIndicator(),
            SizedBox(
              width: 10,
            ),
            Text('Please wait'),
          ],
        ));
  }

  Future<void> _sendOtp() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your name',
          backgroundColor: Colors.white);
    } else if (mobileController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter your Mobile Number",
          backgroundColor: Colors.white);
    } else if (mobileController.text.length != 10) {
      Get.snackbar("Error", "Please enter Valid Mobile Number",
          backgroundColor: Colors.white);
    } else if (firmController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter your Firm name",
          backgroundColor: Colors.white);
    } else {
      _showDialogLoading();

      var uuid = const Uuid();
      var useId = uuid.v4();
      FirebaseFirestore.instance
          .collection('register')
          .where('mobile', isEqualTo: mobileController.text)
          .get()
          .then((QuerySnapshot snapshot) {
        if (snapshot.docs.isEmpty) {
          FirebaseFirestore.instance.collection('register').add({
            "name": nameController.text,
            "city": addressController.text,
            "mobile": mobileController.text,
            "userId": useId,
            "firmName": firmController.text,
            'enteredDate': Timestamp.now(),
          }).whenComplete(() async {
            SharedPreferences sp = await SharedPreferences.getInstance();
            sp.setString("name", nameController.text);
            sp.setString("city", addressController.text);
            sp.setString("userId", useId);
            sp.setString("mobile", mobileController.text);
            sp.setString("firmName", firmController.text);
            Get.snackbar('Success', 'Login Successfull',
                backgroundColor: Colors.white);
            FirebaseFirestore.instance
                .collection('registrationcount')
                .get()
                .then((QuerySnapshot snapshot) {
              if (snapshot.docs.isEmpty) {
                FirebaseFirestore.instance
                    .collection('registrationcount')
                    .add({'count': 1});
              } else {
                for (var element in snapshot.docs) {
                  FirebaseFirestore.instance
                      .collection('registrationcount')
                      .doc(element.id)
                      .update({'count': element.get('count') + 1});
                }
              }
            });
            _notifyAdmin('/topics/visiondgtech');
            Get.offAll(() => MyBottomBar());
          });
        } else {
          snapshot.docs.first.reference.update({
            "name": nameController.text,
            "company": firmController.text,
            "mobile": mobileController.text,
            "userId": useId,
            "city": addressController.text,
          }).whenComplete(() async {
            // playSound();
            SharedPreferences sp = await SharedPreferences.getInstance();
            sp.setString("name", nameController.text);
            sp.setString("userId", useId);
            sp.setString("company", firmController.text);
            sp.setString("mobile", mobileController.text);

            sp.setString("city", addressController.text);
            Get.snackbar('Success', 'Login successful',
                backgroundColor: Colors.white);
            Get.offAll(() => MyBottomBar());
            _notifyAdmin2('/topics/visiondgtech');
          });
        }
      });
    }
  }

  void _notifyAdmin(String recipientToken) async {
    try {
      final _credentials = new ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "shreebalajitunch",
        "private_key_id": "29ab1c008eadb87301704a590dede443df844d6c",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC/S6slOF57GSou\nf5PLH+kTTT/brzYKwsGcCvbZL2kHjFFvpUn3NTM2TBirzeUz9t2fPbPv/JL9NK5n\nhntuJH3D5Gcy4Axq9gOhE8zq1BrI29DX46m4QZIM2iFZuUBbmkdnItW0x3+WFoCp\nL3mbKQ6XQWxzMtzHoX1iz2TgpvRV9a1dgW2zijKUKXa13mjCnh6mF5QeV79F1CGm\nWqV0dkbXzJsDeF57FHFqAlNlwB4p/KDJQPXMUVimKQe/OybJa0McojkUWeXkRq2g\ny/6ACaoVN2udfEIlLdtDA/wojFu/JMBiLprXtpIN9icg8zkptCZ3wB9dMQe4nb0e\nG6nxpfvbAgMBAAECggEAH2lj+ZEnhowrzoXZdXXQdoBtV3wOYjb3xtFQFnrAAuLK\nLoyUODkupyBYvsFo/R7w5mih5urxEg34A3zkQMJSOnwDbCm5MEkkcGtJb1gT696Y\njRLPuDdgLacV6d9PD5umVOu17uEBdNpOFzn5/H4B7Nlr3wC/mzJL3hFTLcaMgZ60\nZjtoDG03EVhfZNTNzILebmDVuHSWiEJMFsOk+Yq93fa16lBqpCVapUFXxQyItU0w\n+lMxDIJz3nrIh0OT5WvYf3M3PAxTsYicvb/+xR4rvekah6/X8G0UCVTmCjuNwy+p\n472ixFt4A7tG+W7piGY3IldNpHHU2Tphe7PB8UwVqQKBgQD0kYD7woMe2Xc3/HXV\nssAuMsLQzFls/veSEPL7RsElG13GOpWsI5xzzj9u755tdLaxHKshqWV1seA4ZgUC\nAhIM/6dXKnOIgGBLNLMAs2VqLJ3pBm3evuzaKK9/AlhXXCUOtJFytR2G/UyZysNr\nrAI9GHzrmTt8lOmZayUFHrNV8wKBgQDIPLRTu+zo66Fx1DmvKR1NIvSPVeMt0xZD\ndXyzM6xeLYJ+yeaKIC8w3rz049ZDP8vJmatcOcUvftAqlpJI3asRzg561PDTdLYN\nNAXCBy+/r8XILSooik4TtSWtF4L1m7x0PBgz3/wBpudQZbw3FKy5lGVHllhmzRWS\nd+EEQx80eQKBgH2XpwwihGE4Pd/TVtPJ+qT+zkqZVicB/DLXX2AoopEir5JXjXsb\nwoE53htjFBGTiSoE1eDwc7jwAnwT7+hrFcf1FYNOuovTmR+lzXLDrYXLqb/73Doy\nA8G4eP8ZPjKGkEUv9y1X0vT6aPblSFuntnKXe7clNoYwlpGBkz5A2Ml/AoGBAJ8X\nTBbzSsnM3Rq5iZNX0UYGLdTsYnF4M0opwIgI2DyDYBkohRjddWEYt3zCwOvxdhKZ\nG4NNCxQvZ2lO9K8cH90noG2LXkRDiJl46dI9L3zXRQdEiyhmqp4R4PtjoNNPhy26\nyWf94BXX7BT+n8oLjShtdQKpu1cCPs9+m7NtOQ/RAoGAPP5SzaeCKAb49mWjzqz4\n9BTm9AZsgg5bXYkl/CU1v0K+YGhVMvSsoQgVtk9mYDvQ40dczOXvoh7L3HRvDZJ1\nkjP0PrlA3Eoo0Rrx/5GTl+9Ars+SBdlu4rZ6TcHpfXgndPOreQwPhy0UR1yJ47iA\nG52f0Mt4osMpB9hLBrAT3jk=\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-mjfgl@shreebalajitunch.iam.gserviceaccount.com",
        "client_id": "105099159709396640117",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-mjfgl%40shreebalajitunch.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      });

      const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      var client = await clientViaServiceAccount(_credentials, scopes);

      var url = Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$key/messages:send');

      var data = {
        "message": {
          "topic": "visiondgtech",
          "notification": {
            "title": "New User Found",
            "body":
                "Name: ${nameController.text}, \n PhoneNumber:${mobileController.text} "
          },
          "data": {"key1": "value1", "key2": "value2"},
          "android": {"priority": "HIGH"}
        }
      };

      var response = await client.post(url, body: jsonEncode(data));

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.reasonPhrase}');
      }

      client.close();
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  void _notifyAdmin2(String recipientToken) async {
    try {
      final _credentials = new ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "shreebalajitunch",
        "private_key_id": "29ab1c008eadb87301704a590dede443df844d6c",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC/S6slOF57GSou\nf5PLH+kTTT/brzYKwsGcCvbZL2kHjFFvpUn3NTM2TBirzeUz9t2fPbPv/JL9NK5n\nhntuJH3D5Gcy4Axq9gOhE8zq1BrI29DX46m4QZIM2iFZuUBbmkdnItW0x3+WFoCp\nL3mbKQ6XQWxzMtzHoX1iz2TgpvRV9a1dgW2zijKUKXa13mjCnh6mF5QeV79F1CGm\nWqV0dkbXzJsDeF57FHFqAlNlwB4p/KDJQPXMUVimKQe/OybJa0McojkUWeXkRq2g\ny/6ACaoVN2udfEIlLdtDA/wojFu/JMBiLprXtpIN9icg8zkptCZ3wB9dMQe4nb0e\nG6nxpfvbAgMBAAECggEAH2lj+ZEnhowrzoXZdXXQdoBtV3wOYjb3xtFQFnrAAuLK\nLoyUODkupyBYvsFo/R7w5mih5urxEg34A3zkQMJSOnwDbCm5MEkkcGtJb1gT696Y\njRLPuDdgLacV6d9PD5umVOu17uEBdNpOFzn5/H4B7Nlr3wC/mzJL3hFTLcaMgZ60\nZjtoDG03EVhfZNTNzILebmDVuHSWiEJMFsOk+Yq93fa16lBqpCVapUFXxQyItU0w\n+lMxDIJz3nrIh0OT5WvYf3M3PAxTsYicvb/+xR4rvekah6/X8G0UCVTmCjuNwy+p\n472ixFt4A7tG+W7piGY3IldNpHHU2Tphe7PB8UwVqQKBgQD0kYD7woMe2Xc3/HXV\nssAuMsLQzFls/veSEPL7RsElG13GOpWsI5xzzj9u755tdLaxHKshqWV1seA4ZgUC\nAhIM/6dXKnOIgGBLNLMAs2VqLJ3pBm3evuzaKK9/AlhXXCUOtJFytR2G/UyZysNr\nrAI9GHzrmTt8lOmZayUFHrNV8wKBgQDIPLRTu+zo66Fx1DmvKR1NIvSPVeMt0xZD\ndXyzM6xeLYJ+yeaKIC8w3rz049ZDP8vJmatcOcUvftAqlpJI3asRzg561PDTdLYN\nNAXCBy+/r8XILSooik4TtSWtF4L1m7x0PBgz3/wBpudQZbw3FKy5lGVHllhmzRWS\nd+EEQx80eQKBgH2XpwwihGE4Pd/TVtPJ+qT+zkqZVicB/DLXX2AoopEir5JXjXsb\nwoE53htjFBGTiSoE1eDwc7jwAnwT7+hrFcf1FYNOuovTmR+lzXLDrYXLqb/73Doy\nA8G4eP8ZPjKGkEUv9y1X0vT6aPblSFuntnKXe7clNoYwlpGBkz5A2Ml/AoGBAJ8X\nTBbzSsnM3Rq5iZNX0UYGLdTsYnF4M0opwIgI2DyDYBkohRjddWEYt3zCwOvxdhKZ\nG4NNCxQvZ2lO9K8cH90noG2LXkRDiJl46dI9L3zXRQdEiyhmqp4R4PtjoNNPhy26\nyWf94BXX7BT+n8oLjShtdQKpu1cCPs9+m7NtOQ/RAoGAPP5SzaeCKAb49mWjzqz4\n9BTm9AZsgg5bXYkl/CU1v0K+YGhVMvSsoQgVtk9mYDvQ40dczOXvoh7L3HRvDZJ1\nkjP0PrlA3Eoo0Rrx/5GTl+9Ars+SBdlu4rZ6TcHpfXgndPOreQwPhy0UR1yJ47iA\nG52f0Mt4osMpB9hLBrAT3jk=\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-mjfgl@shreebalajitunch.iam.gserviceaccount.com",
        "client_id": "105099159709396640117",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-mjfgl%40shreebalajitunch.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      });

      const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      var client = await clientViaServiceAccount(_credentials, scopes);

      var url = Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$key/messages:send');

      var data = {
        "message": {
          "topic": "visiondgtech",
          "notification": {
            "title": "Old User install your app Again",
            "body":
                "Name: ${nameController.text}, \n PhoneNumber:${mobileController.text} "
          },
          "data": {"key1": "value1", "key2": "value2"},
          "android": {"priority": "HIGH"}
        }
      };

      var response = await client.post(url, body: jsonEncode(data));

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.reasonPhrase}');
      }

      client.close();
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
