import 'package:clienthotelapp/BasePage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'RoomDetailPageNew.dart';



class Room {
  final String id;
  final String type;
  final String mainImage;
  final List<String> images;
  final String description;
  final int beds;
  final int capacity;
  final double price;
  final List<String> amenities;

  Room({
    required this.id,
    required this.type,
    required this.mainImage,
    required this.images,
    required this.description,
    required this.beds,
    required this.capacity,
    required this.price,
    required this.amenities,
  });
}

// Sample data
final List<Room> rooms = [
  Room(
    id: '1',
    type: 'Deluxe Room',
    mainImage: 'assets/images/background1.jpg',
    images: [
      'assets/images/background1.jpg',
      'assets/images/background1.jpg',
      'assets/images/background1.jpg',
    ],
    description: 'Our Deluxe Room offers a spacious and comfortable stay with modern amenities and a beautiful view of the city skyline.',
    beds: 1,
    capacity: 2,
    price: 150.00,
    amenities: ['Free Wi-Fi', 'Air Conditioning', 'Room Service'],
  ),
  Room(
    id: '2',
    type: 'Executive Suite',
    mainImage: 'assets/images/background2.jpg',
    images: [
      'assets/images/background2.jpg',
      'assets/images/background2.jpg',
      'assets/images/background2.jpg',
    ],
    description: 'The Executive Suite provides luxury and comfort with a separate living area, premium furnishings, and panoramic views.',
    beds: 1,
    capacity: 2,
    price: 250.00,
    amenities: ['Free Wi-Fi', 'Air Conditioning', 'Room Service', 'Living Area', 'Coffee Machine'],
  ),

];

class RoomListingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8,),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => BasePage()),
                  );
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
               Container(
                 margin: EdgeInsets.only(left: 10),
                 child: Text(
                    'Hotel Rooms',
                    style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                  ),
               ),

              SizedBox(height: 15,),
              Expanded(
                child: ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    return RoomCard(room: rooms[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final Room room;

  const RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      color: Colors.white, // White background as requested
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoomDetailPage(room: room),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                room.mainImage,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.type,
                    style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.king_bed, color: Colors.blueGrey),
                      SizedBox(width: 8),
                      Text(
                        '${room.beds} Bed${room.beds > 1 ? 's' : ''}',
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.person, color: Colors.blueGrey),
                      SizedBox(width: 8),
                      Text(
                        '${room.capacity} Person${room.capacity > 1 ? 's' : ''}',
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\$${room.price.toStringAsFixed(2)} / night',
                    style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
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
}

