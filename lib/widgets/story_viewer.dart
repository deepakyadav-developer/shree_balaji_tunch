import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StoryViewer(),
    );
  }
}

class Story {
  final String url;
  final String type;
  final String caption;
  final Timestamp timestamp;
  final String id;
  int likes;

  Story({
    this.url,
    this.type,
    this.caption,
    this.timestamp,
    this.id,
    this.likes = 0,
  });

  factory Story.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Story(
      id: doc.id,
      url: data['url'] ?? '',
      type: data['type'] ?? '',
      caption: data['caption'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likes: data['likes'] ?? 0,
    );
  }
}

class StoryViewer extends StatefulWidget {
  @override
  _StoryViewerState createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Story> stories = [];
  int currentIndex = 0;
  VideoPlayerController _videoController;
  bool isLoading = true;
  Set<String> likedStoryIds = {};

  @override
  void initState() {
    super.initState();
    fetchStories();
  }

  Future<void> fetchStories() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('story')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        stories =
            querySnapshot.docs.map((doc) => Story.fromFirestore(doc)).toList();
        isLoading = false;
      });

      if (stories.isNotEmpty) {
        initializeCurrentStory();
      }
    } catch (e) {
      print('Error fetching stories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void initializeCurrentStory() {
    if (stories[currentIndex].type == 'video') {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    _videoController?.dispose();
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(stories[currentIndex].url),
    )..initialize().then((_) {
        setState(() {});
        _videoController?.play();
      });
  }

  Future<void> likeStory(Story currentStory) async {
    try {
      // Check if story is already liked by this user
      if (!likedStoryIds.contains(currentStory.id)) {
        // Update likes in Firestore
        await _firestore.collection('story').doc(currentStory.id).update({
          'likes': FieldValue.increment(1),
        });

        // Update local state
        setState(() {
          currentStory.likes++;
          likedStoryIds.add(currentStory.id);
        });
      }
    } catch (e) {
      print('Error liking story: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to like story')),
      );
    }
  }

  void nextStory() {
    if (currentIndex < stories.length - 1) {
      setState(() {
        currentIndex++;
        initializeCurrentStory();
      });
    }
  }

  void previousStory() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        initializeCurrentStory();
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (stories.isEmpty) {
      return Scaffold(
        body: Center(child: Text('No stories available')),
      );
    }

    Story currentStory = stories[currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            previousStory();
          } else {
            nextStory();
          }
        },
        child: Stack(
          children: [
            // Story Content
            Center(
              child: currentStory.type == 'video'
                  ? _videoController?.value.isInitialized ?? false
                      ? AspectRatio(
                          aspectRatio: _videoController.value.aspectRatio,
                          child: VideoPlayer(_videoController),
                        )
                      : CircularProgressIndicator()
                  : CachedNetworkImage(
                      imageUrl: currentStory.url,
                      fit: BoxFit.contain,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
            ),

            // Progress Bar
            Positioned(
              top: 50,
              left: 10,
              right: 10,
              child: Row(
                children: stories.asMap().entries.map((entry) {
                  return Expanded(
                    child: Container(
                      height: 2,
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      color: entry.key == currentIndex
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Caption and Like Button
            Positioned(
              bottom: 50,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentStory.caption,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => likeStory(currentStory),
                        child: Icon(
                          Icons.favorite,
                          color: likedStoryIds.contains(currentStory.id)
                              ? Colors.pink
                              : Colors.white,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${currentStory.likes} likes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
