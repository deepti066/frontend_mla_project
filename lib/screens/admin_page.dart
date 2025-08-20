// lib/screens/admin_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post added')));
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
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _titleController.text = widget.initial!.title;
      _descController.text = widget.initial!.description;
      _locationController.text = widget.initial!.location;
      // initial image is File -> not loaded to XFile here. Keep simple for now.
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _pickedImage = picked);
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final location = _locationController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter title')));
      return;
    }

    final post = Post(
      title: title,
      description: desc,
      location: location,
      imageFile: _pickedImage != null ? File(_pickedImage!.path) : null,
    );

    widget.onCreate(post);

    // clear form
    _titleController.clear();
    _descController.clear();
    _locationController.clear();
    setState(() => _pickedImage = null);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: widget.key,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create New Post', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Image Title',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Location (optional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickImage,
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
                  Text(_pickedImage == null ? 'Pick Image' : 'Change Image', style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_pickedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(_pickedImage!.path), height: 200, width: double.infinity, fit: BoxFit.cover),
            ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}


class PostList extends StatelessWidget {
  final List<Post> posts;
  final void Function(int) onDelete;

  const PostList({Key? key, required this.posts, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20),
        child: Text('No posts yet. Tap "Post" to add one.', style: TextStyle(fontSize: 16)),
      ));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final post = posts[index];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image (file or placeholder)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: post.imageFile != null
                    ? Image.file(post.imageFile!, height: 200, width: double.infinity, fit: BoxFit.cover)
                    : Container(
                  height: 200,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Icon(Icons.image, size: 64, color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        post.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Simple delete flow
                        onDelete(index);
                      },
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
