import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../constant/app_info.dart';
import '../../widgets/my_seprators.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Bank extends StatefulWidget {
  @override
  State<Bank> createState() => _BankState();
}

class _BankState extends State<Bank> with AutomaticKeepAliveClientMixin {
  final ScreenshotController sc = ScreenshotController();
  bool _isLogoVisible = false;

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bgColor,
      textColor: whiteColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        title: Text(
          "Bank Details",
          style: TextStyle(
            color: whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: GestureDetector(
              onTap: () async {
                setState(() {
                  _isLogoVisible = true;
                });

                // Capture the screenshot
                final unit8List = await sc.capture();
                if (unit8List != null) {
                  String tempPath = (await getTemporaryDirectory()).path;
                  File file = File('$tempPath/image.png');
                  await file.writeAsBytes(unit8List);

                  // Prepare the text to be shared
                  String message =
                      "Download $projectName Mobile app and see the latest update\n"
                      "$androidLink$packageName";

                  await Share.shareXFiles(
                    [XFile(file.path)],
                    text: message,
                  );
                }

                setState(() {
                  _isLogoVisible = false;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: whiteColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.share,
                      color: whiteColor,
                      size: 18,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Share",
                      style: TextStyle(color: whiteColor),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Material(
        child: Screenshot(
          controller: sc,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      bgColor.withOpacity(0.9),
                      bgColor.withOpacity(0.6),
                      bgColor.withOpacity(0.3),
                      Colors.white,
                    ],
                  ),
                ),
                height: MediaQuery.of(context).size.height,
              ),
              // Background pattern overlay
              Positioned.fill(
                child: Opacity(
                  opacity: 0.05,
                  child: Image.asset(
                    'assets/images/pattern.png',
                    fit: BoxFit.cover,
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 20),
                      Container(
                        width: Get.width * 0.6,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: bgColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.account_balance_outlined,
                                color: bgColor,
                                size: 40,
                              ),
                            ),
                            SizedBox(height: 15),
                            Text(
                              "BANK DETAILS",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('bank')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) {
                            return Container(
                              height: 200,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CupertinoActivityIndicator(
                                      radius: 18,
                                      color: bgColor,
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      "Loading bank details...",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            if (snapshot.data!.docs.isEmpty) {
                              return Container(
                                height: 200,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 50,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 15),
                                      Text(
                                        "No Bank Details Available",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      snapshot.data!.docs[index]
                                              .get("bankURL")
                                              .toString()
                                              .isEmpty
                                          ? const SizedBox()
                                          : Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 16),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.08),
                                                    spreadRadius: 1,
                                                    blurRadius: 15,
                                                    offset: Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              child: _bankCard(
                                                snapshot.data!.docs[index]
                                                    .get("bankURL"),
                                                "${snapshot.data!.docs[index].get("bank")}",
                                                "${snapshot.data!.docs[index].get("accountName")}",
                                                "${snapshot.data!.docs[index].get("accountNumber")}",
                                                "${snapshot.data!.docs[index].get("ifsc")}",
                                                "${snapshot.data!.docs[index].get("branch")} ",
                                              ),
                                            ),
                                      const SizedBox(height: 30),
                                      snapshot.data!.docs[index]
                                              .get("qrURL")
                                              .toString()
                                              .isEmpty
                                          ? const SizedBox()
                                          : Column(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: bgColor
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Text(
                                                    "Scan QR Code to Pay",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                      color: bgColor,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 15),
                                                Container(
                                                  padding: EdgeInsets.all(15),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.08),
                                                        spreadRadius: 1,
                                                        blurRadius: 15,
                                                        offset: Offset(0, 8),
                                                      ),
                                                    ],
                                                  ),
                                                  child: CachedNetworkImage(
                                                    width: 250,
                                                    imageUrl:
                                                        '${snapshot.data!.docs[index].get("qrURL")}',
                                                    height: 250,
                                                    placeholder:
                                                        (context, url) =>
                                                            Container(
                                                      height: 250,
                                                      width: 250,
                                                      child: Center(
                                                        child:
                                                            CupertinoActivityIndicator(),
                                                      ),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      const SizedBox(height: 30),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
              if (_isLogoVisible)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 60,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bankCard(
    String imgUrl,
    String bankName,
    String accountName,
    String accountNumber,
    String ifscCode,
    String branch,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50] ?? Colors.grey.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: CachedNetworkImage(
                  imageUrl: imgUrl,
                  height: 60,
                  placeholder: (context, url) => Container(
                    height: 60,
                    child: Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              Divider(thickness: 1, color: Colors.grey[200], height: 30),
              _buildDetailRow("Bank Name", bankName),
              _buildDivider(),
              _buildDetailRow("Account Name", accountName),
              _buildDivider(),
              _buildDetailRowWithCopy("Account Number", accountNumber),
              _buildDivider(),
              _buildDetailRowWithCopy("IFSC Code", ifscCode),
              _buildDivider(),
              _buildDetailRow("Branch", branch),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(5),
            ),
            width: Get.width * 0.3,
            child: Text(
              label,
              style: TextStyle(
                color: bgColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithCopy(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(5),
            ),
            width: Get.width * 0.3,
            child: Text(
              label,
              style: TextStyle(
                color: bgColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              _showToast("$label copied to clipboard");
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.copy,
                size: 16,
                color: bgColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Dash(
        length: MediaQuery.of(context).size.width * 0.8,
        dashColor: Colors.grey[300] ?? Colors.grey,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
