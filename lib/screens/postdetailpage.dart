import 'package:flutter/material.dart';

class PostDetailPage extends StatelessWidget {
  final String caption;
  final int views;
  final List<Map<String, String>> images;

  const PostDetailPage({
    super.key,
    required this.caption,
    required this.views,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(caption)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(caption, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.remove_red_eye, size: 18, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("$views views", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),

          // Show each image with description
          ...images.map((img) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  img['url']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    img['desc'] ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
