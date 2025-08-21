import 'package:flutter/material.dart';
import 'package:login_signup/screens/postdetailpage.dart';
import 'package:login_signup/screens/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final List<Map<String, dynamic>> posts = [
    {
      "caption": "Coco",
      "views": 120,
      "images": [
        {"url": "assets/images/dog.png", "desc": "Coco sitting happily"},
        {"url": "assets/images/coco.jpeg", "desc": "Coco looking at the sky"}
      ]
    },
    {
      "caption": "Nature at its best",
      "views": 250,
      "images": [
        {"url": "assets/images/tower.jpg", "desc": "Sky-high beauty"},
        {"url": "assets/images/scenery.jpg", "desc": "Calm and peaceful landscape"}
      ]
    },
    {
      "caption": "Nature at its best",
      "views": 250,
      "images": [
        {"url": "assets/images/tower.jpg", "desc": "Sky-high beauty"},
        {"url": "assets/images/bg1.png", "desc": "Calm and peaceful landscape"}
      ]
    }
  ];

  final List<PageController> _controllers =
  List.generate(10, (_) => PageController());

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("role"); // ✅ remove saved role
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Picture Feed"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context), // ✅ Logout button
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          final images = List<Map<String, String>>.from(post['images']);
          final controller = _controllers[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailPage(
                    caption: post['caption'],
                    views: post['views'],
                    images: images,
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Slider
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      controller: controller,
                      itemCount: images.length,
                      itemBuilder: (context, imgIndex) {
                        return ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: Image.asset(
                            images[imgIndex]['url']!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),

                  // SmoothPageIndicator
                  if (images.length > 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: SmoothPageIndicator(
                          controller: controller,
                          count: images.length,
                          effect: const WormEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            activeDotColor: Colors.blue,
                          ),
                        ),
                      ),
                    ),

                  // Caption and Views
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          post['caption'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.remove_red_eye,
                                size: 18, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              "${post['views']}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
