import 'dart:convert';

import 'package:clienthotelapp/BasePage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'RoomDetailPageNew.dart';
import 'api.dart';

class Room {
  final String id;
  final String type;
  final String bedType;
  final List<String> images;
  final String mainImage;
  final String description;
  final double price;
  final List<String> amenities;
  final bool isOccupied;
  final bool doNotDisturb;
  final bool requestCleaning;
  final bool requestMaintenance;

  Room({
    required this.id,
    required this.type,
    required this.bedType,
    required this.images,
    required this.mainImage,
    required this.description,
    required this.price,
    required this.amenities,
    required this.isOccupied,
    required this.doNotDisturb,
    required this.requestCleaning,
    required this.requestMaintenance,
  });

  // Calculate bed count based on bedType string
  int get beds {
    if (bedType.contains('double')) return 1;
    if (bedType.contains('two single')) return 2;
    if (bedType.contains('single')) {
      final regex = RegExp(r'(\d+)\s*single');
      final match = regex.firstMatch(bedType);
      if (match != null && match.groupCount >= 1) {
        return int.tryParse(match.group(1) ?? '1') ?? 1;
      }
    }
    return 1; // Default
  }

  // Calculate capacity based on bed types
  int get capacity {
    int count = 0;
    if (bedType.contains('double')) count += 2;
    if (bedType.contains('single')) {
      final regex = RegExp(r'(\d+)\s*single');
      final match = regex.firstMatch(bedType);
      if (match != null && match.groupCount >= 1) {
        count += int.tryParse(match.group(1) ?? '1') ?? 1;
      } else {
        count += 1;
      }
    }
    return count > 0 ? count : 2; // Default to 2 if calculation fails
  }

  // Factory method to create a Room from API JSON
  factory Room.fromJson(Map<String, dynamic> json) {
    // Extract amenities
    List<String> amenitiesList = [];
    if (json['amenities'] != null) {
      for (var amenity in json['amenities']) {
        if (amenity is List && amenity.length > 1) {
          amenitiesList.add(amenity[1].toString());
        }
      }
    }

    // Extract images
    List<String> imagesList = [];
    String mainImage = '';
    if (json['images'] != null && json['images'].isNotEmpty) {
      for (var image in json['images']) {
        if (image['image'] != null) {
          imagesList.add(image['image'].toString());
          if (mainImage.isEmpty) {
            mainImage = image['image'].toString();
          }
        }
      }
    }

    return Room(
      id: json['roomID']?.toString() ?? '',
      type: json['room_type']?.toString() ?? 'Standard Room',
      bedType: json['bed_type']?.toString() ?? 'Single bed',
      images: imagesList,
      mainImage: mainImage.isNotEmpty ? mainImage : 'assets/images/room_placeholder.jpg',
      description: json['description']?.toString() ?? 'No description available',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      amenities: amenitiesList,
      isOccupied: json['is_occupied'] == true,
      doNotDisturb: json['doNotDisturb'] == true,
      requestCleaning: json['requestCleaning'] == true,
      requestMaintenance: json['requestMaintenance'] == true,
    );
  }
}

class RoomListingPage extends StatefulWidget {
  @override
  State<RoomListingPage> createState() => _RoomListingPageState();
}

class _RoomListingPageState extends State<RoomListingPage> {
  List<Room> rooms = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await http.get(Uri.parse('${Api.url}/backend/hotel_admin/getRoom/'));

      if (response.statusCode == 200) {
        // Decode with utf8 to handle any special characters
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
        final List<Room> fetchedRooms = jsonData.map((data) => Room.fromJson(data)).toList();

        setState(() {
          rooms = fetchedRooms;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load rooms: ${response.statusCode}';
        });
        print('Failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => BasePage()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
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
              SizedBox(height: 15),
              if (isLoading)
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (errorMessage.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                )
              else if (rooms.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No rooms available',
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ),
                  )
                else
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

  // Helper function to capitalize room type
  String capitalizeRoomType(String type) {
    if (type.isEmpty) return '';
    return type.split(' ').map((word) =>
    word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      color: Colors.white,
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
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey[500],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        capitalizeRoomType(room.type),
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      if (room.isOccupied)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Occupied',
                            style: GoogleFonts.nunito(
                              textStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.red[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    room.bedType,
                    style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey[600],
                        fontStyle: FontStyle.italic,
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
                    '${(room.price / 1000).toStringAsFixed(2)} DZD / night',
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