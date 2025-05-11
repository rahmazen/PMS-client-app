import 'dart:convert';
import 'dart:io';
import 'package:clienthotelapp/providers/authProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

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
  double _rating = 1.0;

  // Temporary dynamic list of reviews
  List<dynamic> reviews = [
    {
      'id': '0',
      'user': 'loading....',
      'userProfileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'comment': 'loading...',
      'image': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
      'rating': 0.0,
      'date': '2025-04-24T22:08:00.793Z',
    },
  ];

  Future<void> fetchReview() async {
    try {
      final response = await http.get(Uri.parse('${Api.url}/backend/guest/reviews/'));

      if (response.statusCode == 200) {
        setState(() {
          reviews = json.decode(response.body);
        });
        print(reviews);
      } else {
        print('Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
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
    fetchReview();
  }

  Future<void> createReview() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = authProvider.authData;

    if (userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to submit a review')),
      );
      return;
    }

    await submitReview(userData.username);
  }

  Future<void> submitReview(String username) async {
    // Validate input
    if (_reviewController.text.trim().isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a review or an image')),
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
          Uri.parse('${Api.url}/backend/guest/reviews/')
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
        await fetchReview();

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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userData = authProvider.authData;

    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.all(25.0),
              child: Text(
                'Explore',
                style: GoogleFonts.nunito(
                  textStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[600],
                  ),
                ),
              ),
            ),

            Provider.of<AuthProvider>(context , listen : true ).isAuthenticated?
            Container(
              padding: const EdgeInsets.all(16),
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

                  // Rating bar


                  // Selected image preview
                  _buildImagePreview(),



                  // Bottom action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Row(
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


                      // Submit button

                    ],
                  ),
                ],
              ),
            ): SizedBox.shrink(),

            // Reviews list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 10),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return Card(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    elevation: 3,
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
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage('${Api.url}${review['userProfileImage']}'),
                                radius: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review['user'],
                                      style: GoogleFonts.nunito(
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          _getTimeAgo(review['date']),
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
                              ),

                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            review['comment'],
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
                            children: [
                              Icon(Icons.thumb_up_outlined, size: 18, color: Colors.blueGrey),
                              const SizedBox(width: 4),
                              Text(
                                'Like',
                                style: GoogleFonts.nunito(
                                  textStyle: const TextStyle(
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Icon(Icons.comment_outlined, size: 18, color: Colors.blueGrey),
                              const SizedBox(width: 4),
                              Text(
                                'Comment',
                                style: GoogleFonts.nunito(
                                  textStyle: const TextStyle(
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Icon(Icons.share_outlined, size: 18, color: Colors.blueGrey),
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
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}