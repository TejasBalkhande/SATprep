import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_html/flutter_html.dart';
import 'dart:js' as js;

class BlogPostPage extends StatefulWidget {
  static const String routeName = '/blog';  // Singular 'blog'

  final String slug;

  const BlogPostPage({required this.slug});

  @override
  _BlogPostPageState createState() => _BlogPostPageState();
}

class _BlogPostPageState extends State<BlogPostPage> {
  Map<String, dynamic>? blogPost;
  bool isLoading = true;
  String? error;
  int retryCount = 0;
  final int maxRetries = 3;
  bool _isInitialized = false;  // Added initialization flag

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _fetchBlogPost();
    }
  }

  Future<void> _fetchBlogPost() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      print('Fetching blog post with slug: ${widget.slug}');

      final response = await http.get(
          Uri.parse('https://blog-api.tejasbalkhande221.workers.dev/api/blog/${widget.slug}'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Origin': 'https://localhost',
          }
      ).timeout(const Duration(seconds: 30));

      print('Blog post response status: ${response.statusCode}');
      print('Blog post response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          setState(() {
            error = 'Empty response from server';
            isLoading = false;
          });
          return;
        }

        try {
          final decodedData = json.decode(responseBody);
          setState(() {
            blogPost = decodedData;
            isLoading = false;
            retryCount = 0;
          });
          _setSEOTags();
        } catch (jsonError) {
          print('JSON decode error: $jsonError');
          setState(() {
            error = 'Invalid response format from server';
            isLoading = false;
          });
        }
      } else {
        _handleErrorResponse(response.statusCode, response.body);
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      _handleNetworkError();
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      _handleTimeoutError();
    } on http.ClientException catch (e) {
      print('ClientException: $e');
      setState(() {
        error = 'Connection failed: ${e.message}. Please check if the server is running.';
        isLoading = false;
      });
    } catch (e) {
      print('Generic error: $e');
      _handleGenericError(e);
    }
  }

  void _handleErrorResponse(int statusCode, String responseBody) {
    String errorMsg;
    switch (statusCode) {
      case 404:
        errorMsg = 'Blog post not found. It may have been deleted or the URL is incorrect.';
        break;
      case 500:
        errorMsg = 'Server error occurred. Please try again later.';
        break;
      default:
        errorMsg = 'HTTP error: $statusCode';
    }

    print('Error response: $statusCode - $responseBody');

    setState(() {
      error = errorMsg;
      isLoading = false;
    });
  }

  void _handleNetworkError() {
    setState(() {
      error = 'Network error: Please check your internet connection and try again.';
      isLoading = false;
    });
  }

  void _handleTimeoutError() {
    setState(() {
      error = 'Request timed out. The server may be busy. Please try again.';
      isLoading = false;
    });
  }

  void _handleGenericError(dynamic e) {
    setState(() {
      error = 'Unexpected error: ${e.toString()}';
      isLoading = false;
    });
  }

  void _retry() {
    if (retryCount < maxRetries) {
      setState(() {
        retryCount++;
      });
      _fetchBlogPost();
    }
  }

  void _setSEOTags() {
    if (blogPost == null) return;

    try {
      if (identical(0, 0.0)) return;

      js.context.callMethod('setTitle', [blogPost!['title']]);
      js.context.callMethod('setMetaTag', ['description', blogPost!['metaDescription']]);

      if (blogPost!['metaKeywords'] != null) {
        final keywords = blogPost!['metaKeywords'] is List
            ? (blogPost!['metaKeywords'] as List).join(',')
            : blogPost!['metaKeywords'].toString();
        js.context.callMethod('setMetaTag', ['keywords', keywords]);
      }

      if (blogPost!['coverImageUrl'] != null && blogPost!['coverImageUrl'].toString().isNotEmpty) {
        js.context.callMethod('setOGTag', ['og:image', blogPost!['coverImageUrl']]);
      }
    } catch (e) {
      print('Error setting SEO tags: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(blogPost?['title'] ?? 'Loading...'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _retry,
            tooltip: 'Retry',
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading blog post...'),
          ],
        ),
      )
          : error != null
          ? Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Failed to load blog post',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              if (retryCount < maxRetries)
                ElevatedButton.icon(
                  onPressed: _retry,
                  icon: Icon(Icons.refresh),
                  label: Text('Try Again'),
                ),
              if (retryCount >= maxRetries)
                Column(
                  children: [
                    Text(
                      'Maximum retries reached',
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_back),
                      label: Text('Go Back'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            if (blogPost?['coverImageUrl'] != null &&
                blogPost!['coverImageUrl'].toString().isNotEmpty)
              Container(
                width: double.infinity,
                height: 250,
                child: Image.network(
                  blogPost!['coverImageUrl'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(Icons.broken_image,
                            size: 50, color: Colors.grey[400]),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blogPost?['title'] ?? 'Untitled Post',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person,
                            size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          blogPost?['author'] ?? 'Unknown author',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          _formatDate(blogPost?['datePublished']),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        if (blogPost?['lastUpdated'] != null) ...[
                          SizedBox(width: 16),
                          Icon(Icons.update,
                              size: 16, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            'Updated: ${_formatDate(blogPost!['lastUpdated'])}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  if (blogPost?['content'] != null &&
                      blogPost!['content'].toString().isNotEmpty)
                    Html(
                      data: blogPost!['content'],
                      style: {
                        "body": Style(
                          fontSize: FontSize(16),
                          lineHeight: LineHeight(1.6),
                        ),
                        "p": Style(
                          margin: Margins.only(bottom: 12),
                        ),
                        "h1, h2, h3, h4, h5, h6": Style(
                          margin:
                          Margins.only(top: 20, bottom: 10),
                          fontWeight: FontWeight.bold,
                        ),
                      },
                    )
                  else
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 8),
                          Text(
                            "No content available",
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown date';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString.split('T')[0];
    }
  }
}