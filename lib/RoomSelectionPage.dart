import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clienthotelapp/Room.dart';

import 'api.dart';

class RoomSelectionPage extends StatefulWidget {
  final List<Room> availableRooms;

  const RoomSelectionPage(this.availableRooms, {Key? key}) : super(key: key);

  @override
  State<RoomSelectionPage> createState() => _RoomSelectionPageState();
}

class _RoomSelectionPageState extends State<RoomSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20,),
              Row(
                children: [
                  IconButton( onPressed: () {
                      Navigator.pop(context);
                       } ,
                      icon: Icon(Icons.arrow_back_ios),
                      color: Colors.blueGrey[600],
                  ),
                  Container(

                    child: Text(
                      'Available Rooms for Your Stay',
                      style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24,),
              Expanded(
                child: widget.availableRooms.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.hotel_outlined,
                        size: 60,
                        color: Colors.blueGrey[300],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No rooms available for your selected criteria',
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: widget.availableRooms.length,
                  itemBuilder: (context, index) {
                    return SelectableRoomCard(
                      room: widget.availableRooms[index],
                      onSelect: () {
                        // Return the selected room to the previous page
                        Navigator.pop(context, widget.availableRooms[index]);
                      },
                    );
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

class SelectableRoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onSelect;

  const SelectableRoomCard({
    required this.room,
    required this.onSelect,
    Key? key,
  }) : super(key: key);

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
        onTap: onSelect, // Call the provided callback when selected
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.blueGrey.withOpacity(0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    '${Api.url}${room.mainImage}',
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
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${room.price } DZD',
                      style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.king_bed, color: Colors.blueGrey, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '${room.beds} Bed${room.beds > 1 ? 's' : ''}',
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.person, color: Colors.blueGrey, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '${room.capacity} Person${room.capacity > 1 ? 's' : ''}',
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blueGrey, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          room.description.isNotEmpty ? room.description : 'No description available',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            textStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.blueGrey[600],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Add a visual indicator that this room can be selected

          ],
        ),
      ),
    );
  }
}