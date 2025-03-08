import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'RoomListingPage.dart';

class RoomDetailPage extends StatelessWidget {
  final Room room;

  const RoomDetailPage({required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stack for back button and image carousel
            Stack(
              children: [
                // Image carousel
                GestureDetector(
                  onTap: () {
                    // Navigate to full-screen image view
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImage(images: room.images),
                      ),
                    );
                  },
                  child: Container(
                    height: 250,
                    child: PageView.builder(
                      itemCount: room.images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          room.images[index],
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),

                // Back button
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                      //  color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back_ios_rounded, color: Colors.blueGrey),
                          SizedBox(width: 8),
                          Text(
                            'Back',
                            style: GoogleFonts.nunito(
                              textStyle: TextStyle(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Rest of the content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Room type
                      Text(
                        room.type,
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Price
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '\$${room.price.toStringAsFixed(2)} / night',
                          style: GoogleFonts.nunito(
                            textStyle: TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Room capacity
                      Row(
                        children: [
                          _buildInfoItem(Icons.king_bed, '${room.beds} Bed${room.beds > 1 ? 's' : ''}'),
                          SizedBox(width: 24),
                          _buildInfoItem(Icons.person, '${room.capacity} Person${room.capacity > 1 ? 's' : ''}'),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Description
                      Text(
                        'Description',
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        room.description,
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            color: Colors.blueGrey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Amenities
                      Text(
                        'Amenities',
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: room.amenities.map((amenity) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.blueGrey.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              amenity,
                              style: GoogleFonts.nunito(
                                color: Colors.blueGrey,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey),
        SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.nunito(
            textStyle: TextStyle(
              color: Colors.blueGrey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// Full-screen image view
class FullScreenImage extends StatelessWidget {
  final List<String> images;

  const FullScreenImage({required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  child: Image.network(
                    images[index],
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
            // Back button for full-screen image view
            Positioned(
              top: 16,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.arrow_back, color: Colors.blueGrey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}