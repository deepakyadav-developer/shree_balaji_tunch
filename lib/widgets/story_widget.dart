// Add this in your existing imports if not present
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../constant/APP_INFO.dart';

class StoryWidget extends StatefulWidget {
  const StoryWidget({super.key});

  @override
  _StoryWidgetState createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  List<DocumentSnapshot> stories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStories();
  }

  Future<void> fetchStories() async {
    DateTime now = DateTime.now();
    DateTime twentyFourHoursAgo = now.subtract(Duration(hours: 24));

    // Fetch stories from Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('story')
        .where('timestamp', isGreaterThan: twentyFourHoursAgo)
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      stories = querySnapshot.docs;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 70,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (stories.isEmpty) {
      // Show social buttons when no stories are available
      return Container(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialButton(
              icon: FontAwesomeIcons.facebook,
              color: Colors.blue,
              label: 'Facebook',
              onTap: () {
                _launchUrl(
                    "https://www.facebook.com/people/Shree-Balaji/pfbid02kvDi8B6qPzswMYHKDo2VLY4ktChFk1GQosHU8GMon8kiTgRxpCQp18dSiiDL5Ha3l/?mibextid=qi2Omg&rdid=xOYclUullAbBqnCK&share_url=https%3A%2F%2Fwww.facebook.com%2Fshare%2FvzNj95cMMoy1j1ig%2F%3Fmibextid%3Dqi2Omg");
              },
            ),
            _buildSocialButton(
              icon: FontAwesomeIcons.youtube,
              color: Colors.red,
              label: 'Youtube',
              onTap: () {
                _launchUrl("https://www.youtube.com/@shreebalaji6677");
              },
            ),
            _buildSocialButton(
              icon: FontAwesomeIcons.instagram,
              color: Colors.pink,
              label: 'Instagram',
              onTap: () {
                _launchUrl(
                    "https://www.instagram.com/theshreebalaji/?igsh=amZnczh0ZnlneGdj");
              },
            ),
          ],
        ),
      );
    }

    return Container(
      height: 800,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stories.length,
        padding: EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final story = stories[index];
          final bool isVideo = story['type'] == 'video';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoryViewPage(
                    initialIndex: index,
                    stories: stories,
                  ),
                ),
              );
            },
            child: Container(
              width: 60,
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: whiteColor,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: isVideo
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset('assets/images/logo.png')
                                // CachedNetworkImage(
                                //   imageUrl: story['url'],
                                //   fit: BoxFit.cover,
                                //   placeholder: (context, url) => Container(
                                //     color: Colors.grey[300],
                                //   ),
                                // ),
                              ],
                            )
                          : Image.asset('assets/images/logo.png'),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    story['caption'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSocialButton({
    required dynamic icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: whiteColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: icon is IconData ? Icon(icon, color: color) : FaIcon(icon, color: color),
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Cant open URL';
    }
  }
}

class StoryViewPage extends StatefulWidget {
  final int initialIndex;
  final List<DocumentSnapshot> stories;

  const StoryViewPage({
    super.key,
    required this.initialIndex,
    required this.stories,
  });

  @override
  _StoryViewPageState createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage> {
  late PageController _pageController;
  VideoPlayerController? _videoController;
  late int _currentIndex;
  Timer? _timer;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _loadStory(_currentIndex);
  }

  void _loadStory(int index) {
    _timer?.cancel();
    _videoController?.dispose();
    _videoController = null;

    if (widget.stories[index]['type'] == 'video') {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.stories[index]['url']),
      )..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoController?.play();
            _timer = Timer(const Duration(seconds: 15), () {
              if (_currentIndex < widget.stories.length - 1) {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              } else {
                Navigator.pop(context);
              }
            });
          }
        });
    } else {
      _timer = Timer(const Duration(seconds: 15), () {
        if (_currentIndex < widget.stories.length - 1) {
          _pageController.nextPage(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;

    if (dx < screenWidth / 3) {
      // Left tap
      if (_currentIndex > 0) {
        _pageController.previousPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    } else if (dx > 2 * screenWidth / 3) {
      // Right tap
      if (_currentIndex < widget.stories.length - 1) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        Navigator.pop(context);
      }
    } else {
      // Center tap - pause/play video
      if (_videoController != null) {
        setState(() {
          _isPlaying = !_isPlaying;
          _isPlaying ? _videoController!.play() : _videoController!.pause();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: _onTapDown,
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.stories.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
            _loadStory(index);
          },
          itemBuilder: (context, index) {
            final story = widget.stories[index];
            final bool isVideo = story['type'] == 'video';

            return Stack(
              children: [
                Center(
                  child: isVideo
                      ? _videoController?.value.isInitialized ?? false
                          ? AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            )
                          : CircularProgressIndicator()
                      : CachedNetworkImage(
                          imageUrl: story['url'],
                          fit: BoxFit.contain,
                        ),
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: widget.stories.asMap().entries.map((entry) {
                      return Expanded(
                        child: Container(
                          height: 2,
                          margin: EdgeInsets.symmetric(horizontal: 2),
                          color: entry.key == _currentIndex
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 10,
                  right: 10,
                  child: Text(
                    story['caption'] ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
