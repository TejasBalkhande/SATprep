import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:cfdptest/screens/blog_page.dart';
import 'package:cfdptest/utils/slug_helper.dart';

class CreateBlogPage extends StatefulWidget {
  static const String routeName = '/create-blog';

  @override
  _CreateBlogPageState createState() => _CreateBlogPageState();
}

class _CreateBlogPageState extends State<CreateBlogPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isAuthenticated = false;
  bool _isEditing = false;
  Map<String, dynamic>? _existingPost;

  String _slug = '';
  final _titleController = TextEditingController();
  final _metaDescriptionController = TextEditingController();
  final _metaKeywordsController = TextEditingController();
  final _coverImageUrlController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _isInitialized = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is String) {
        _isEditing = true;
        _slug = args;
        _loadExistingPost();
      }
    }
  }

  Future<void> _loadExistingPost() async {
    try {
      final response = await http.get(
          Uri.parse('https://blog-api.tejasbalkhande221.workers.dev/api/blog/$_slug'),
          headers: {'Origin': 'https://localhost'}
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        setState(() {
          _existingPost = json.decode(response.body);
          _titleController.text = _existingPost!['title'];
          _metaDescriptionController.text = _existingPost!['metaDescription'];
          _metaKeywordsController.text = _existingPost!['metaKeywords'].join(', ');
          _coverImageUrlController.text = _existingPost!['coverImageUrl'] ?? '';
          _contentController.text = _existingPost!['content'];
          _authorController.text = _existingPost!['author'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server error: ${response.statusCode}')));
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request timed out')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load post: $e')));
    }
  }

  void _authenticate() {
    if (_passwordController.text == 'QAZWSXEDCRFVTGB') {
      setState(() {
        _isAuthenticated = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Incorrect password')));
    }
  }

  void _generateSlug() {
    if (_titleController.text.isNotEmpty) {
      setState(() {
        _slug = generateSlug(_titleController.text);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final postData = {
        'title': _titleController.text,
        'slug': _slug,
        'metaDescription': _metaDescriptionController.text,
        'metaKeywords': _metaKeywordsController.text.split(',').map((k) => k.trim()).toList(),
        'coverImageUrl': _coverImageUrlController.text,
        'content': _contentController.text,
        'author': _authorController.text,
        'datePublished': _isEditing && _existingPost != null
            ? _existingPost!['datePublished']
            : DateTime.now().toIso8601String(),
      };

      final url = _isEditing
          ? 'https://blog-api.tejasbalkhande221.workers.dev/api/blog/$_slug'
          : 'https://blog-api.tejasbalkhande221.workers.dev/api/blog';

      try {
        final response = await (_isEditing
            ? http.put(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'QAZWSXEDCRFVTGB',
              'Origin': 'https://localhost'
            },
            body: json.encode(postData))
            : http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'QAZWSXEDCRFVTGB',
              'Origin': 'https://localhost'
            },
            body: json.encode(postData)))
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BlogPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Server error: ${response.statusCode}')));
        }
      } on TimeoutException {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request timed out')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Blog Post' : 'Create New Post'),
      ),
      body: _isAuthenticated
          ? SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title*'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
                onChanged: (value) => _generateSlug(),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Slug*'),
                      initialValue: _slug,
                      onChanged: (value) => _slug = value,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: _generateSlug,
                    tooltip: 'Generate from title',
                  ),
                ],
              ),
              TextFormField(
                controller: _metaDescriptionController,
                decoration: InputDecoration(labelText: 'Meta Description*'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _metaKeywordsController,
                decoration: InputDecoration(labelText: 'Keywords (comma separated)'),
              ),
              TextFormField(
                controller: _coverImageUrlController,
                decoration: InputDecoration(labelText: 'Cover Image URL'),
              ),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(labelText: 'Author*'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Content (HTML)*'),
                maxLines: 20,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(_isEditing ? 'Update Post' : 'Publish Post'),
              ),
            ],
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Admin Access Required', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authenticate,
              child: Text('Authenticate'),
            ),
          ],
        ),
      ),
    );
  }
}