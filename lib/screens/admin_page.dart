// lib/screens/admin_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:login_signup/screens/welcome_screen.dart';
import 'package:login_signup/screens/post_list.dart';


class Post {
  final String title;
  final String description;
  final String location;
  final File? imageFile;
  final DateTime createdAt;

  Post({
    required this.title,
    required this.description,
    required this.location,
    this.imageFile,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0; // 0 = Feed, 1 = Create
  final List<Post> _posts = [];

  void _addPost(Post post) {
    setState(() {
      _posts.insert(0, post); // newest at top
      _selectedIndex = 0; // go to feed automatically
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post added')),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => _posts.removeAt(index));
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("role");
    await prefs.remove("token");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Picture Feed', 'Create Post'];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _selectedIndex == 0
              ? PostList(
            key: const ValueKey('feed'),
            posts: _posts,
            onDelete: _confirmDelete,
          )
              : CreatePostForm(
            key: const ValueKey('create'),
            onCreate: _addPost,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.add_a_photo), label: 'Post'),
        ],
      ),
    );
  }
}

class CreatePostForm extends StatefulWidget {
  final void Function(Post) onCreate;
  final Post? initial;

  const CreatePostForm({Key? key, required this.onCreate, this.initial}) : super(key: key);

  @override
  State<CreatePostForm> createState() => _CreatePostFormState();
}

class _CreatePostFormState extends State<CreatePostForm> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _pickedImages = []; // multiple images
  bool _isPosting = false;

  Future<void> _pickImages() async {
    final List<XFile> picked = await _picker.pickMultiImage(
      maxWidth: 1600,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (picked.isNotEmpty) {
      setState(() => _pickedImages = picked);
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final location = _locationController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title')),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("http://10.0.2.2:8000/api/posts"),
      );

      request.headers['Authorization'] = "Bearer $token";
      request.fields['title'] = title;
      request.fields['description'] = desc;
      request.fields['location'] = location;
      // Attach multiple images
      for (var img in _pickedImages) {
        request.files.add(
          await http.MultipartFile.fromPath("media[]", img.path),
        );
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        widget.onCreate(Post(
          title: title,
          description: desc,
          location: location,
          imageFile: _pickedImages.isNotEmpty ? File(_pickedImages.first.path) : null,
        ));

        _titleController.clear();
        _descController.clear();
        _locationController.clear();
        setState(() => _pickedImages = []);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post uploaded successfully')),
        );
      } else {
        final errorText = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.statusCode}\n$errorText")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create New Post', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Title
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Image Title',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),

          // Description
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),

          // Location
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),

          // Pick images button
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    _pickedImages.isEmpty ? 'Choose Images' : 'Change Images',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Preview selected images
          if (_pickedImages.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _pickedImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_pickedImages[index].path),
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: _isPosting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isPosting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Post'),
          ),
        ],
      ),
    );
  }
}
