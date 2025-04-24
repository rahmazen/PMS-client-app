import 'dart:convert';

import 'package:clienthotelapp/BasePage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'RoomDetailPageNew.dart';
import 'api.dart';
import 'package:clienthotelapp/Room.dart';
class RoomListingPage extends StatefulWidget {
  final List<Room> rooms ;
  const RoomListingPage(
      this.rooms,
      {Key? key}
      ): super(key: key);
  @override
  State<RoomListingPage> createState() => _RoomListingPageState();
}

class _RoomListingPageState extends State<RoomListingPage> {


  String errorMessage = '';


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
              if (errorMessage.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                )
              else if (widget.rooms.isEmpty)
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
                      itemCount: widget.rooms.length,
                      itemBuilder: (context, index) {
                        return RoomCard(room: widget.rooms[index]);
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
                    '${room.price} DZD / night',
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