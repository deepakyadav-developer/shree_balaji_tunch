import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';

import '../../constant/APP_INFO.dart';

class ContactUs_Screen extends StatefulWidget {
  const ContactUs_Screen({
    Key key,
  }) : super(key: key);

  @override
  State<ContactUs_Screen> createState() => _ContactUs_ScreenState();
}

class _ContactUs_ScreenState extends State<ContactUs_Screen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          "Contact Us",
          style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('contactRef')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: CupertinoActivityIndicator(
                            radius: 20,
                          ),
                        ),
                      );
                    } else {
                      return Column(
                        children: [
                          FadeInDown(
                            duration: Duration(milliseconds: 500),
                            child: _buildContactCard(
                              icon: Icons.location_on_sharp,
                              title: "ADDRESS",
                              onTap: () async {
                                var uri = Uri.parse(
                                    "https://www.google.com/maps/dir/25.303991,83.0078659/shree+balaji+computer+tunch+%26+laser+solding+centar/@25.3100921,83.0039124,16z/data=!3m1!4b1!4m9!4m8!1m1!4e1!1m5!1m1!1s0x398e2e190593b945:0xecf9ff14a975e1af!2m2!1d83.011441!2d25.3161194?entry=ttu&g_ep=EgoyMDI0MTAwMi4xIKXMDSoASAFQAw%3D%3D");
                                if (await canLaunch(uri.toString())) {
                                  await launch(uri.toString());
                                } else {
                                  throw 'Could not launch ${uri.toString()}';
                                }
                              },
                              content:
                                  "CK 61/57 B1 Kashipura, Varanasi,\nUttar Pradesh, 221001",
                              iconBackgroundColor: bgColor,
                              iconColor: whiteColor,
                            ),
                          ),
                          FadeInDown(
                            duration: Duration(milliseconds: 600),
                            child: _buildContactCard(
                              icon: FontAwesomeIcons.envelope,
                              title: "EMAIL",
                              onTap: () {
                                _launchEmail("shreebalajijewels01@gmail.com");
                              },
                              content: "shreebalajijewels01@gmail.com",
                              iconBackgroundColor: bgColor,
                              iconColor: whiteColor,
                            ),
                          ),
                          FadeInDown(
                            duration: Duration(milliseconds: 700),
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: bgColor.withOpacity(0.1),
                                      child: Icon(
                                        FontAwesomeIcons.phone,
                                        color: bgColor,
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      "BOOKING NUMBER",
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    ListView.builder(
                                      primary: false,
                                      shrinkWrap: true,
                                      itemCount: snapshot.data.docs.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            _makingPhoneCall(snapshot
                                                .data.docs[index]
                                                .get("number"));
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(bottom: 10),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 15),
                                            decoration: BoxDecoration(
                                              color: bgColor.withOpacity(0.05),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.phone,
                                                    color: bgColor),
                                                SizedBox(width: 15),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        snapshot
                                                            .data.docs[index]
                                                            .get("name"),
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Text(
                                                        snapshot
                                                            .data.docs[index]
                                                            .get("number"),
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[700]),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(Icons.arrow_forward_ios,
                                                    size: 16,
                                                    color: Colors.grey),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          FadeInDown(
                            duration: Duration(milliseconds: 800),
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor:
                                          Colors.green.withOpacity(0.1),
                                      child: FaIcon(
                                        FontAwesomeIcons.whatsapp,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      "WHATSAPP NUMBER",
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    ListView.builder(
                                      primary: false,
                                      shrinkWrap: true,
                                      itemCount: snapshot.data.docs.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            _launchWhatsapp(snapshot
                                                .data.docs[index]
                                                .get("number"));
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(bottom: 10),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 15),
                                            decoration: BoxDecoration(
                                              color: Colors.green
                                                  .withOpacity(0.05),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(FontAwesomeIcons.whatsapp,
                                                    color: Colors.green),
                                                SizedBox(width: 15),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        snapshot
                                                            .data.docs[index]
                                                            .get("name"),
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Text(
                                                        snapshot
                                                            .data.docs[index]
                                                            .get("number"),
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[700]),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(Icons.arrow_forward_ios,
                                                    size: 16,
                                                    color: Colors.grey),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          FadeInDown(
                            duration: Duration(milliseconds: 900),
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Text(
                                          "FEEDBACK FORM",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      _buildTextFormField(
                                        controller: _nameController,
                                        label: "Name",
                                        hintText: "Enter your name",
                                        icon: Icons.person_outline,
                                      ),
                                      SizedBox(height: 15),
                                      _buildTextFormField(
                                        controller: _phoneController,
                                        label: "Phone",
                                        hintText: "Enter your phone number",
                                        icon: Icons.phone_outlined,
                                        keyboardType: TextInputType.phone,
                                      ),
                                      SizedBox(height: 15),
                                      _buildTextFormField(
                                        controller: _emailController,
                                        label: "Email",
                                        hintText: "Enter your email",
                                        icon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                      ),
                                      SizedBox(height: 15),
                                      _buildTextFormField(
                                        controller: _subjectController,
                                        label: "Subject",
                                        hintText: "Enter subject",
                                        icon: Icons.subject,
                                      ),
                                      SizedBox(height: 15),
                                      _buildTextFormField(
                                        controller: _messageController,
                                        label: "Message",
                                        hintText: "Type your message here",
                                        icon: Icons.message_outlined,
                                        maxLines: 3,
                                      ),
                                      SizedBox(height: 25),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState
                                              .validate()) {
                                            // Process data
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content:
                                                    Text('Processing Data'),
                                                backgroundColor: bgColor,
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          "SEND MESSAGE",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          primary: bgColor,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          minimumSize:
                                              Size(double.infinity, 50),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    IconData icon,
    String title,
    String content,
    Function onTap,
    Color iconBackgroundColor,
    Color iconColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: iconBackgroundColor.withOpacity(0.1),
                  child: Icon(
                    icon,
                    color: iconBackgroundColor,
                    size: 20,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    TextEditingController controller,
    String label,
    String hintText,
    IconData icon,
    TextInputType keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label *",
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType ?? TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(icon, color: bgColor),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter $label';
            }
            if (label == "Email" && !value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  _launchWhatsapp(String number) async {
    final url = "whatsapp://send?phone=+91$number&text=hello";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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

  @override
  bool get wantKeepAlive => true;
}

_launchEmail(String email) async {
  if (await canLaunch("mailto:$email")) {
    await launch("mailto:$email");
  } else {
    throw 'Could not launch';
  }
}
