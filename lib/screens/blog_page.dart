import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:cfdptest/utils/slug_helper.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cfdptest/screens/create_blog_page.dart';
import 'package:cfdptest/screens/blog_post_page.dart';
import 'dart:js' as js;

class BlogPage extends StatefulWidget {
  static const String routeName = '/blogs';

  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  List<dynamic>? blogPosts;
  List<dynamic>? filteredBlogPosts;
  bool isLoading = true;
  String? error;
  int retryCount = 0;
  final int maxRetries = 3;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String filterValue = 'all';
  String sortValue = 'latest';

  @override
  void initState() {
    super.initState();
    _fetchBlogPosts();
  }

  Future<void> _fetchBlogPosts() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      print('Attempting to fetch blog posts...');

      final response = await http.get(
          Uri.parse('https://blog-api.tejasbalkhande221.workers.dev/api/blog'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Origin': 'https://localhost',
          }
      ).timeout(const Duration(seconds: 30));

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          setState(() {
            blogPosts = [];
            filteredBlogPosts = [];
            isLoading = false;
            retryCount = 0;
          });
          return;
        }

        try {
          final decodedData = json.decode(responseBody);
          List<dynamic> posts = decodedData is List ? decodedData : [];

          // Sort by latest first
          posts.sort((a, b) {
            String dateA = a['datePublished'] ?? '';
            String dateB = b['datePublished'] ?? '';
            return dateB.compareTo(dateA);
          });

          setState(() {
            blogPosts = posts;
            filteredBlogPosts = List.from(posts);
            isLoading = false;
            retryCount = 0;
          });
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
      _handleClientError(e);
    } catch (e) {
      print('Generic error: $e');
      _handleGenericError(e);
    }
  }

  void _handleErrorResponse(int statusCode, String responseBody) {
    String errorMsg;
    switch (statusCode) {
      case 404:
        errorMsg = 'Blog API endpoint not found. Please check the server configuration.';
        break;
      case 500:
        errorMsg = 'Server error occurred. Please try again later.';
        break;
      case 401:
        errorMsg = 'Unauthorized access to blog posts.';
        break;
      case 403:
        errorMsg = 'Access forbidden to blog posts.';
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

  void _handleClientError(http.ClientException e) {
    setState(() {
      error = 'Connection failed: ${e.message}. Please check if the server is running.';
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
      _fetchBlogPosts();
    }
  }

  void _applyFilters() {
    if (blogPosts == null) return;

    List<dynamic> filtered = List.from(blogPosts!);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((post) {
        final query = searchQuery.toLowerCase();
        return (post['title']?.toLowerCase().contains(query) == true ||
            post['metaDescription']?.toLowerCase().contains(query) == true ||
            post['author']?.toLowerCase().contains(query) == true);
      }).toList();
    }


    // Apply category filter
    if (filterValue != 'all') {
      filtered = filtered.where((post) {
        return (post['category']?.toLowerCase() == filterValue.toLowerCase());
      }).toList();
    }

    // Apply sort
    if (sortValue == 'oldest') {
      filtered.sort((a, b) {
        String dateA = a['datePublished'] ?? '';
        String dateB = b['datePublished'] ?? '';
        return dateA.compareTo(dateB);
      });
    } else if (sortValue == 'title') {
      filtered.sort((a, b) {
        String titleA = a['title'] ?? '';
        String titleB = b['title'] ?? '';
        return titleA.compareTo(titleB);
      });
    } else { // latest (default)
      filtered.sort((a, b) {
        String dateA = a['datePublished'] ?? '';
        String dateB = b['datePublished'] ?? '';
        return dateB.compareTo(dateA);
      });
    }

    setState(() {
      filteredBlogPosts = filtered;
    });
  }

  List<dynamic> getLatestBlogs() {
    if (blogPosts == null || blogPosts!.isEmpty) return [];
    return blogPosts!.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SAT Prep Blog'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateBlogPage()),
              );
            },
            tooltip: 'Create New Post',
          ),
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
            Text('Loading blog posts...'),
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
                'Oops! Something went wrong',
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
                        setState(() {
                          retryCount = 0;
                        });
                        _retry();
                      },
                      icon: Icon(Icons.restart_alt),
                      label: Text('Start Over'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      )
          : blogPosts == null || blogPosts!.isEmpty
          ? Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.article_outlined,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No blog posts yet',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                'Be the first to create a blog post!',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateBlogPage()),
                  );
                },
                icon: Icon(Icons.add),
                label: Text('Create First Post'),
              ),
            ],
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchBlogPosts,
        child: CustomScrollView(
          slivers: [
            // Search and Filters Section
            SliverPadding(
              padding: EdgeInsets.all(12),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Search Bar
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by keyword...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              searchQuery = '';
                            });
                            _applyFilters();
                          },
                        )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                        _applyFilters();
                      },
                    ),
                    SizedBox(height: 12),

                    // Filter and Sort Row
                    Row(
                      children: [
                        // Category Filter
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: filterValue,
                            decoration: InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('All Categories'),
                              ),
                              DropdownMenuItem(
                                value: 'math',
                                child: Text('Math'),
                              ),
                              DropdownMenuItem(
                                value: 'reading',
                                child: Text('Reading'),
                              ),
                              DropdownMenuItem(
                                value: 'writing',
                                child: Text('Writing'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                filterValue = value!;
                              });
                              _applyFilters();
                            },
                          ),
                        ),
                        SizedBox(width: 12),

                        // Sort Dropdown
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: sortValue,
                            decoration: InputDecoration(
                              labelText: 'Sort By',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'latest',
                                child: Text('Latest First'),
                              ),
                              DropdownMenuItem(
                                value: 'oldest',
                                child: Text('Oldest First'),
                              ),
                              DropdownMenuItem(
                                value: 'title',
                                child: Text('Title (A-Z)'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                sortValue = value!;
                              });
                              _applyFilters();
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Latest Blogs Section
                    Text(
                      'Latest Posts',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Latest Blogs List
            if (getLatestBlogs().isNotEmpty)
              SliverToBoxAdapter(
                child: Container(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    itemCount: getLatestBlogs().length,
                    itemBuilder: (context, index) {
                      final post = getLatestBlogs()[index];
                      return _buildLatestBlogItem(post, context);
                    },
                  ),
                ),
              ),

            // Main Blogs List Header
            SliverPadding(
              padding: EdgeInsets.all(12),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'All Posts',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),

            // Main Blogs List
            filteredBlogPosts!.isEmpty
                ? SliverFillRemaining(
              child: Center(
                child: Text(
                  'No posts found matching your criteria',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            )
                : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final post = filteredBlogPosts![index];
                  return _buildBlogItem(post, context);
                },
                childCount: filteredBlogPosts!.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestBlogItem(dynamic post, BuildContext context) {
    return Container(
      width: 280,
      margin: EdgeInsets.only(right: 12),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/blog/${post['slug']}',
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover Image
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey[200],
                ),
                child: post['coverImageUrl'] != null &&
                    post['coverImageUrl'].toString().isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    post['coverImageUrl'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                )
                    : Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Icon(
                    Icons.article,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['title'] ?? 'Untitled',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(
                          _formatDate(post['datePublished']),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlogItem(dynamic post, BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/blog/${post['slug']}',
          );
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                child: post['coverImageUrl'] != null &&
                    post['coverImageUrl'].toString().isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post['coverImageUrl'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                )
                    : Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.article,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['title'] ?? 'Untitled',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      post['metaDescription'] ?? 'No description available',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(
                          post['author'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(
                          _formatDate(post['datePublished']),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown date';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else if (difference < 7) {
        return '$difference days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString.split('T')[0];
    }
  }
}