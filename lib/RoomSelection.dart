import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'RoomDetailsScreen.dart';

class RoomSelectionScreen extends StatefulWidget {
  const RoomSelectionScreen({Key? key}) : super(key: key);

  @override
  _RoomSelectionScreenState createState() => _RoomSelectionScreenState();
}

class _RoomSelectionScreenState extends State<RoomSelectionScreen> {
  final List<HotelRoom> rooms = [
    HotelRoom(
      name: 'Deluxe King Room',
      description: 'Spacious room with king-sized bed and city view',
      price: 199,
      amenities: ['Free Wi-Fi', 'Breakfast included', 'Air conditioning', 'meow'],
      imageUrl: 'assets/images/deluxe_king.jpg',
      maxOccupancy: 2,
    ),
    HotelRoom(
      name: 'Superior Twin Room',
      description: 'Comfortable room with two single beds',
      price: 159,
      amenities: ['Free Wi-Fi', 'Air conditioning', 'TV', 'Safe'],
      imageUrl: 'assets/images/superior_twin.jpg',
      maxOccupancy: 2,
    ),
    HotelRoom(
      name: 'Executive Suite',
      description: 'Luxury suite with separate living area and panoramic views',
      price: 299,
      amenities: ['Free Wi-Fi', 'Breakfast included', 'Minibar', 'Bathtub', 'Lounge access'],
      imageUrl: 'assets/images/executive_suite.jpg',
      maxOccupancy: 3,
    ),
    HotelRoom(
      name: 'Family Room',
      description: 'Spacious room perfect for families with children',
      price: 249,
      amenities: ['Free Wi-Fi', 'Breakfast included', 'Air conditioning', 'Extra beds available'],
      imageUrl: 'assets/images/family_room.jpg',
      maxOccupancy: 4,
    ),
  ];

  int? selectedRoomIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20,),
          Container(
            margin: EdgeInsets.only(left: 15),

            child: Text('hola choose ur room', style: GoogleFonts.nunito(),),

          ),
          SizedBox(height: 20,),


          Expanded(
            child: ListView.builder(
              padding:  EdgeInsets.all(16),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                final isSelected = selectedRoomIndex == index;

                return Column(
                  children: [

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRoomIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueGrey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: isSelected
                              ? Border.all(color: Colors.blueGrey[700]!, width: 2)
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.asset(
                                      room.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.blueGrey[200],
                                          child: Center(
                                            child: Icon(
                                              Icons.hotel,
                                              size: 50,
                                              color: Colors.blueGrey[800],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey[800],
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '\$${room.price}/night',
                                          style: GoogleFonts.nunito(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          room.name,
                                          style: GoogleFonts.nunito(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey[900],
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.blueGrey[700],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    room.description,
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: Colors.blueGrey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Max occupancy: ${room.maxOccupancy} people',
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: Colors.blueGrey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: room.amenities.map((amenity) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey[50],
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          amenity,
                                          style: GoogleFonts.nunito(
                                            fontSize: 12,
                                            color: Colors.blueGrey[800],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: selectedRoomIndex != null
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomDetailScreen(room: staticRoom),
                  ),
                );

              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
                elevation: 0,
                disabledBackgroundColor: Colors.blueGrey[300],
              ),
              child: Text(
                'Continue with Selection',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HotelRoom {
  final String name;
  final String description;
  final double price;
  final List<String> amenities;
  final String imageUrl;
  final int maxOccupancy;

  HotelRoom({
    required this.name,
    required this.description,
    required this.price,
    required this.amenities,
    required this.imageUrl,
    required this.maxOccupancy,
  });
}