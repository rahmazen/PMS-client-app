import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:clienthotelapp/providers/authProvider.dart';
import 'package:clienthotelapp/api.dart';
import 'package:http/http.dart' as http;

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final VoidCallback toggleLike;

  const PostCard({
    Key? key,
    required this.post,
    required this.toggleLike,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked = false;
  bool _isCommentSectionOpen = true;
  bool _isLoadingLike = false;
  bool _isLoadingComments = false;
  bool _isSendingComment = false;
  int _likesCount = 0;
  List<dynamic> _comments = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializePostData();
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the state if the post data changes from parent
    if (oldWidget.post != widget.post) {
      _initializePostData();
    }
  }

  void _initializePostData() {
    // Initialize likes count from post_likes array
    setState(() {
      _likesCount = widget.post['post_likes']?.length ?? 0;
      _comments = widget.post['post_comments'] ?? [];

      // Check if current user has liked the post
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && authProvider.authData?.username != null) {
        final String currentUsername = authProvider.authData!.username;
        _isLiked = widget.post['post_likes'].contains(currentUsername);
      }
    });
  }

  Future<void> _toggleLike() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to like posts')),
      );
      return;
    }

    final username = authProvider.authData?.username;
    if (username == null) return;

    setState(() {
      _isLoadingLike = true;
    });

    try {
      // Update UI immediately (optimistically)
      setState(() {
        _isLiked = !_isLiked;
        _likesCount = _isLiked ? _likesCount + 1 : _likesCount - 1;
      });

      // Trigger the parent's toggleLike callback to update the API
      widget.toggleLike();

      setState(() {
        _isLoadingLike = false;
      });
    } catch (e) {
      // Revert the optimistic update if there was an error
      setState(() {
        _isLiked = !_isLiked;
        _likesCount = _isLiked ? _likesCount + 1 : _likesCount - 1;
        _isLoadingLike = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error liking post: $e')),
      );
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to comment')),
      );
      return;
    }

    setState(() {
      _isSendingComment = true;
    });

    try {
      final String apiUrl = '${Api.url}/backend/guest/comment/${widget.post['id']}/';
      final String currentUsername = authProvider.authData?.username ?? 'current_user';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.authData?.accessToken}',
        },
        body: jsonEncode({
          'comment': _commentController.text,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Optimistically update the UI with new comment
        final newComment = {
          'comment': _commentController.text,
          'user': currentUsername,
          'created_at': DateTime.now().toIso8601String(),
          'userProfileImage': authProvider.authData?.image,
        };

        setState(() {
          _comments.add(newComment);
          widget.post['post_comments'] = _comments;
          _commentController.clear();
          _isSendingComment = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment posted successfully')),
        );
      } else {
        throw Exception('Failed to post comment');
      }
    } catch (e) {
      setState(() {
        _isSendingComment = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting comment: $e')),
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bool isLoggedIn = authProvider.isAuthenticated;

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),

            Row(
              children: [
                Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.blueGrey, size: 20),
                        onPressed: () => Navigator.pop(context)
                    ),
                    Text(
                      'Back',
                      style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Post Header with user info and time
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: (widget.post['userProfileImage'] != null)
                                ? NetworkImage('${Api.url}${widget.post['userProfileImage']}')
                                : const NetworkImage('https://randomuser.me/api/portraits/lego/1.jpg'),
                            radius: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.post['user'] ?? 'Anonymous',
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
                            widget.post['date'] != null ? _getTimeAgo(widget.post['date']) : 'Recently',
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

                  // Post content
                  if (widget.post['comment'] != null && widget.post['comment'].isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.post['comment'],
                      style: GoogleFonts.nunito(
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],

                  // Post image
                  if (widget.post['image'] != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '${Api.url}${widget.post['image']}',
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
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Like button
                  TextButton.icon(
                    onPressed: _isLoadingLike ? null : _toggleLike,
                    icon: _isLoadingLike
                        ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blue[700],
                      ),
                    )
                        : Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border_outlined,
                      size: 18,
                      color: _isLiked ? Colors.red : Colors.blueGrey,
                    ),
                    label: Text(
                      '${_likesCount} Like',
                      style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                          color: _isLiked ? Colors.red : Colors.blueGrey,
                        ),
                      ),
                    ),
                  ),

                  // Comment button
                  Text(
                    '${_comments.length} Comment',
                    style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                        color: _isCommentSectionOpen ? Colors.blue[700] : Colors.blueGrey,
                      ),
                    ),
                  ),

                  // Share button
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share functionality coming soon!')),
                      );
                    },
                    icon: Icon(Icons.ios_share, size: 18, color: Colors.blueGrey),
                    label: Text(
                      'Share',
                      style: GoogleFonts.nunito(
                        textStyle: const TextStyle(
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Comment section
            if (_isCommentSectionOpen) ...[
              Divider(color: Colors.grey[300], height: 1),
              SizedBox(height :2),

            if(isLoggedIn)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: authProvider.authData?.image != null
                          ? NetworkImage('${Api.url}${authProvider.authData?.image}')
                          : const NetworkImage('https://randomuser.me/api/portraits/lego/1.jpg'),
                    ),
                    const SizedBox(width: 8),

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Write a comment...',
                            border: InputBorder.none,
                            suffixIcon: _isSendingComment
                                ? Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.blue[700],
                                ),
                              ),
                            )
                                : IconButton(
                              icon: Icon(Icons.send, color: Colors.blue[700]),
                              onPressed: _submitComment,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Comments list with minimal spacing
              (_comments.isEmpty)
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'No comments yet. Be the first to comment!',
                    style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 10),
                physics: NeverScrollableScrollPhysics(),
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: comment['userProfileImage'] != null
                              ? NetworkImage('${Api.url}${comment['userProfileImage']}')
                              : const NetworkImage('https://randomuser.me/api/portraits/lego/1.jpg'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment['user'] ?? 'Anonymous',
                                  style: GoogleFonts.nunito(
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  comment['comment'] ?? '',
                                  style: GoogleFonts.nunito(
                                    textStyle: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment['created_at'] != null ? _getTimeAgo(comment['created_at']) : 'Recently',
                                  style: GoogleFonts.nunito(
                                    textStyle: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}