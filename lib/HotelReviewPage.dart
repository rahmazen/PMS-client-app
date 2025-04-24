import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
  List<Map<String, dynamic>> _reviews = [
    {
      'id': '1',
      'username': 'Sarah Johnson',
      'userProfileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'description': 'Absolutely loved my stay! The room was clean and spacious with an amazing view. The staff were very friendly and helpful. Will definitely come back.',
      'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
      'rating': 5.0,
      'timestamp': DateTime.now().subtract(Duration(days: 2)),
    },
    {
      'id': '2',
      'username': 'Michael Clark',
      'userProfileImage': 'https://randomuser.me/api/portraits/men/32.jpg',
      'description': 'Good hotel but the breakfast options could be improved. Room service was prompt and the beds were comfortable.',
      'imageUrl': null,
      'rating': 4.0,
      'timestamp': DateTime.now().subtract(Duration(days: 5)),
    },
    {
      'id': '3',
      'username': 'Priya Patel',
      'userProfileImage': 'https://randomuser.me/api/portraits/women/67.jpg',
      'description': 'The spa facilities were amazing! Had a great time relaxing by the pool. The room was a bit small but well designed.',
      'imageUrl': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
      'rating': 4.5,
      'timestamp': DateTime.now().subtract(Duration(days: 7)),
    },
  ];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _submitReview() {
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

    // Simulate network delay
    Future.delayed(Duration(seconds: 1), () {
      // Create new review
      final newReview = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'username': 'You',
        'userProfileImage': 'https://randomuser.me/api/portraits/men/85.jpg',
        'description': _reviewController.text,
        'imageUrl': _selectedImage != null ? 'dummy_path_to_simulate_storage' : null,
        'rating': _rating,
        'timestamp': DateTime.now(),
      };

      // Add to reviews list
      setState(() {
        _reviews.insert(0, newReview);
        _reviewController.clear();
        _selectedImage = null;
        _rating = 5.0;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review posted successfully')),
      );
    });
  }

  String _getTimeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.all(16),
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/85.jpg'),
                          radius: 20,
                        ),
                        SizedBox(width: 12),
                       RatingBar.builder(
                            initialRating: _rating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 22,
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                _rating = rating;
                              });
                            },
                          ),

                      ],
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _reviewController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Share your experience...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blueGrey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blueGrey),
                        ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey), // Change this color to your desired focus color
                          )
                      ),
                    ),

                    SizedBox(height: 16),
                    if (_selectedImage != null)
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white.withOpacity(0.8),
                              child: IconButton(
                                icon: Icon(Icons.close, size: 16),
                                color: Colors.black,
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(Icons.image),
                            label: Text('Add Photo'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blueGrey,
                              side: BorderSide(color: Colors.blueGrey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitReview,
                            child: _isLoading
                                ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : Text('Post Review'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Reviews',
                      style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[600],
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
            ),
            // Reviews list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 16),
                itemCount: _reviews.length,
                itemBuilder: (context, index) {
                  final review = _reviews[index];
                  return Card(
                    margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    elevation: 3,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(review['userProfileImage']),
                                radius: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review['username'],
                                      style: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          _getTimeAgo(review['timestamp']),
                                          style: GoogleFonts.nunito(
                                            textStyle: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(Icons.public, size: 12, color: Colors.grey[600]),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    i < review['rating'] ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 18,
                                  );
                                }),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            review['description'],
                            style: GoogleFonts.nunito(
                              textStyle: TextStyle(fontSize: 14),
                            ),
                          ),
                          if (review['imageUrl'] != null) ...[
                            SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                review['imageUrl'],
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // For the selected image file (which won't have a valid URL)
                                  if (review['imageUrl'] == 'dummy_path_to_simulate_storage') {
                                    return Container(
                                      width: double.infinity,
                                      height: 200,
                                      color: Colors.blueGrey[100],
                                      child: Center(
                                        child: Icon(
                                          Icons.image,
                                          size: 50,
                                          color: Colors.blueGrey[300],
                                        ),
                                      ),
                                    );
                                  }
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
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.thumb_up_outlined, size: 18, color: Colors.blueGrey),
                              SizedBox(width: 4),
                              Text(
                                'Like',
                                style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                              SizedBox(width: 24),
                              Icon(Icons.comment_outlined, size: 18, color: Colors.blueGrey),
                              SizedBox(width: 4),
                              Text(
                                'Comment',
                                style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                              SizedBox(width: 24),
                              Icon(Icons.share_outlined, size: 18, color: Colors.blueGrey),
                              SizedBox(width: 4),
                              Text(
                                'Share',
                                style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
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
          ],
        ),
      ),
    );
  }
}