import 'dart:convert';
import 'dart:io';
import 'package:clienthotelapp/SignIn.dart';
import 'package:clienthotelapp/providers/authProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'PostDetailPage.dart';
import 'api.dart';

class HotelReviewPage extends StatefulWidget {
  const HotelReviewPage({Key? key}) : super(key: key);

  @override
  State<HotelReviewPage> createState() => _HotelReviewPageState();
}

class _HotelReviewPageState extends State<HotelReviewPage> {
  final TextEditingController _reviewController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  double _rating = 1.0;

  // Pagination variables
  int _currentPage = 1;
  int _totalPages = 1;
  int _limit = 20;

  // List to store reviews
  List<dynamic> reviews = [];

  Future<void> fetchReviews({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        reviews = [];
      });
    }

    if (_isLoadingMore || (_currentPage > _totalPages && !refresh)) {
      return;
    }

    setState(() {
      refresh ? _isLoading = true : _isLoadingMore = true;
    });

    try {
      print('Fetching reviews: ${Api.url}/backend/guest/posts/?page=$_currentPage&limit=$_limit');
      final response = await http.get(
        Uri.parse('${Api.url}/backend/guest/posts/?page=$_currentPage&limit=$_limit'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response data: $responseData');
        print('Response data types: pages=${responseData['pages'].runtimeType}, current_page=${responseData['current_page'].runtimeType}');

        setState(() {
          if (refresh) {
            reviews = responseData['data'];
          } else {
            reviews = [...reviews, ...responseData['data']];
          }

          // Ensure proper type conversion from dynamic JSON values
          _totalPages = responseData['pages'] is int ? responseData['pages'] : int.parse(responseData['pages'].toString());
          _currentPage = responseData['current_page'] is int ? responseData['current_page'] : int.parse(responseData['current_page'].toString());
          _isLoading = false;
          _isLoadingMore = false;
        });

      } else {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
        print('Failed to fetch reviews: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      print('Error fetching reviews: $e');
    }
  }

  void loadMore() {
    if (_currentPage < _totalPages && !_isLoadingMore) {
      setState(() {
        _currentPage++;
      });
      fetchReviews();
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchReviews(refresh: true);
  }

  Future<void> createReview() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = authProvider.authData;

    if (userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to create a Post')),
      );
      return;
    }

    await submitReview(userData.username);
  }

  Future<void> submitReview(String username) async {
    // Validate input
    if (_reviewController.text.trim().isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a caption or an image')),
      );
      return;
    }

    // Show loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Create multipart request
      var request = http.MultipartRequest(
          'POST',
          Uri.parse('${Api.url}/backend/guest/posts/')
      );

      // Add text fields
      request.fields['user'] = username;
      request.fields['comment'] = _reviewController.text;
      request.fields['rating'] = _rating.toString();
      request.fields['date'] = DateTime.now().toIso8601String();

      // Add image if selected
      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
        ));
      }

      // Send request
      var response = await request.send();

      if (response.statusCode == 201) {
        // Refresh reviews after successful submission
        fetchReviews(refresh: true);

        // Clear form
        setState(() {
          _reviewController.clear();
          _selectedImage = null;
          _rating = 5.0;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review posted successfully')),
        );
      } else {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post review: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting review: $e')),
      );
    }
  }

  String _getTimeAgo(String timestamp) {
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      final difference = DateTime.now().difference(dateTime);

      if (difference.inDays > 7) {
        return '${(difference.inDays / 7).floor()} weeks ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      print('Error parsing date: $e');
      return 'Recently';
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: FileImage(_selectedImage!),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.black),
            ),
            onPressed: () {
              setState(() {
                _selectedImage = null;
              });
            },
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }



  // Add these functions to your _HotelReviewPageState class

// Check if the current user has liked a post
  bool isLiked(dynamic post) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final username = authProvider.authData?.username;

    if (username == null || post['post_likes'] == null) {
      return false;
    }

    // Check if the current user's username exists in the post_likes array
    return post['post_likes'].contains(username);

  }

  Future<void> toggleLike(int postId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if user is authenticated
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to like posts'))
      );
      return;
    }

    final username = authProvider.authData?.username;

    // First update the UI optimistically
    setState(() {
      // Find the post in the reviews list
      final postIndex = reviews.indexWhere((post) => post['id'] == postId);
      if (postIndex != -1) {
        // Check if the post is already liked by the user
        final isAlreadyLiked = reviews[postIndex]['post_likes'].contains(username);

        // Toggle the like status
        if (isAlreadyLiked) {
          // Remove the username from post_likes
          reviews[postIndex]['post_likes'].remove(username);
        } else {
          // Add the username to post_likes
          reviews[postIndex]['post_likes'].add(username);
        }
      }
    });

    try {
      // Then update the server
      final response = await http.post(
        Uri.parse('${Api.url}/backend/guest/like/$postId/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user': username,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        // Revert the optimistic update if the server request failed
        setState(() {
          final postIndex = reviews.indexWhere((post) => post['id'] == postId);
          if (postIndex != -1) {
            final isLikedNow = reviews[postIndex]['post_likes'].contains(username);

            if (isLikedNow) {
              reviews[postIndex]['post_likes'].remove(username);
            } else {
              reviews[postIndex]['post_likes'].add(username);
            }
          }
        });

        print('Failed to toggle like: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to like post: ${response.statusCode}'))
        );
      }
    } catch (e) {
      // Revert the optimistic update if there was an error
      setState(() {
        final postIndex = reviews.indexWhere((post) => post['id'] == postId);
        if (postIndex != -1) {
          final isLikedNow = reviews[postIndex]['post_likes'].contains(username);

          if (isLikedNow) {
            reviews[postIndex]['post_likes'].remove(username);
          } else {
            reviews[postIndex]['post_likes'].add(username);
          }
        }
      });

      print('Error toggling like: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error liking post: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userData = authProvider.authData;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.all(20.0),
                  child: Text(

                    'Explore Page',
                    style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                  ),
                ),
                /*
                Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.login_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        // Navigate to sign-in page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignInScreen(redirectToPage: HotelReviewPage(),)),
                        );;
                      },
                      tooltip: 'Sign In',
                    ),
                    SizedBox(width: 20,)

                  ],
                ),

                 */
              ],
            ),



            // Review input section - only visible when user is authenticated
            Provider.of<AuthProvider>(context, listen: true).isAuthenticated
                ? Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: userData?.image != null
                            ? NetworkImage('${Api.url}${userData?.image}')
                            : const NetworkImage('https://randomuser.me/api/portraits/lego/1.jpg'),
                      ),
                      const SizedBox(width: 12),

                      // Text field
                      Expanded(
                        child: TextField(
                          controller: _reviewController,
                          decoration: InputDecoration(
                            hintText: 'Share your experience...',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          maxLines: null,
                        ),
                      ),
                    ],
                  ),

                  // Selected image preview
                  _buildImagePreview(),

                  // Bottom action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        icon: Icon(Icons.photo_outlined, color: Colors.grey.shade600),
                        label: Text(
                          'Add Photo',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        onPressed: _pickImage,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _isLoading ? null : createReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text('Post'),
                      ),
                    ],
                  ),
                ],
              ),
            )
                : const SizedBox.shrink(),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0 , vertical: 5),
                  child: Text(
                    "new posts",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                ),
              ],
            )
,

            // Reviews list
            Expanded(
              child: _isLoading && reviews.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : reviews.isEmpty
                  ? const Center(child: Text('No posts yet , be the first '))
                  : RefreshIndicator(
                onRefresh: () => fetchReviews(refresh: true),
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: reviews.length + 1, // +1 for the "See More" button
                  itemBuilder: (context, index) {
                    // Show "See More" button at the end if there are more pages
                    if (index == reviews.length) {
                      if (_currentPage < _totalPages) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: _isLoadingMore
                                ? const CircularProgressIndicator()
                                : TextButton(
                              onPressed: loadMore,
                              child: Text(
                                'See More',
                                style: GoogleFonts.nunito(
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink(); // No more pages
                      }
                    }

                    // Display the review
                    final review = reviews[index];
                    return GestureDetector(
                      onTap: ()=> Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostCard(
                            post: review,
                            toggleLike: () => toggleLike(review['id']),
                          ),
                        ),
                      ),
                      child: Card(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        elevation: 2,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage:
                                        // First try with userProfileImage field
                                        (review['userProfileImage'] != null)
                                            ? NetworkImage('${Api.url}${review['userProfileImage']}')
                                        // If not available, fall back to default avatar
                                            : const NetworkImage('https://randomuser.me/api/portraits/lego/1.jpg'),
                                        radius: 20,
                                      ),
                                      const SizedBox(width: 12),

                                      Text(
                                        review['user'] ?? 'Anonymous',
                                        style: GoogleFonts.nunito(
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),


                                            Row(
                                              children: [
                                                Text(
                                                  review['date'] != null ? _getTimeAgo(review['date']) : 'Recently',
                                                  style: GoogleFonts.nunito(
                                                    textStyle: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(Icons.public, size: 12, color: Colors.grey[600]),

                                              ],
                                            ),

                                      ],

                              ),
                              const SizedBox(height: 12),
                              Text(
                                review['comment'] ?? '',
                                style: GoogleFonts.nunito(
                                  textStyle: const TextStyle(fontSize: 14),
                                ),
                              ),
                              if (review['image'] != null) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    '${Api.url}${review['image']}',
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: double.infinity,
                                        height: 200,
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: Icon(
                                            Icons.error_outline,
                                            size: 40,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => toggleLike(review['id']),
                                        child: Icon(
                                            isLiked(review) ? Icons.favorite : Icons.favorite_border_outlined,
                                            size: 18,
                                            color: isLiked(review) ? Colors.red : Colors.blueGrey
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${review['post_likes'].length?? 0}',
                                        style: GoogleFonts.nunito(
                                          textStyle: const TextStyle(
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),

                                      Text(
                                        'Like',
                                        style: GoogleFonts.nunito(
                                          textStyle: const TextStyle(
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),



                                  Row(
                                    children: [
                                      Icon(Icons.comment, size: 18, color: Colors.blueGrey),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${review['post_comments'].length}',
                                        style: GoogleFonts.nunito(
                                          textStyle: const TextStyle(
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width : 2),
                                      Text(
                                        'Comment',
                                        style: GoogleFonts.nunito(
                                          textStyle: const TextStyle(
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),



                                  Row(
                                    children: [
                                      Icon(Icons.ios_share, size: 18, color: Colors.blueGrey),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Share',
                                        style: GoogleFonts.nunito(
                                          textStyle: const TextStyle(
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),

                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}