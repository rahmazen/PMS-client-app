import 'dart:convert';import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:clienthotelapp/BookingScreen.dart';
import 'package:clienthotelapp/RoomListingPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:clienthotelapp/providers/authProvider.dart';
import 'RoomSelectionPage.dart';
import 'SignIn.dart';
import 'api.dart';
import 'Room.dart';


class RoomBookingPage extends StatefulWidget {
  @override
  _RoomBookingPageState createState() => _RoomBookingPageState();
}

class _RoomBookingPageState extends State<RoomBookingPage> {
  List<Room> fetchedRooms =[];
  DateTime checkInDate = DateTime.now();
  DateTime checkOutDate = DateTime.now().add(const Duration(days: 1));
  bool showCalendar = false;
  bool selectingCheckIn = true;
  int adults = 1;
 // int children = 0;
  String? selectedRoomType;
  String selectedRoomPrice = '';
  List<int> selectedAmenities = [];
  bool isLoading = true;

  List<dynamic> roomTypes = [{"roomID":"0","room_type":"loading","bed_type":"loading bed","price":"00","is_occupied":false,"doNotDisturb":false,"requestCleaning":false,"requestMaintenance":false,"description":"loading floor","maxOccupancy":1,"amenities":[7,8,9]},];
  List<dynamic> amenities = [
    { 'id' : '1' , 'name' :'loading...'}
  ];

  void updateDate(DateTime selectedDay) {
    setState(() {
      if (selectingCheckIn) {
        checkInDate = selectedDay;
        // If check-in date is after check-out date, update check-out date
        if (checkInDate!.isAfter(checkOutDate!)) {
          checkOutDate = checkInDate!.add(const Duration(days: 1));
        }
        selectingCheckIn = false;
      } else {
        // Ensure check-out date is after check-in date
        if (selectedDay.isAfter(checkInDate!) ||
            selectedDay.isAtSameMomentAs(checkInDate!)) {
          checkOutDate = selectedDay;
          showCalendar = false;
        } else {
          // Show error message if attempting to select check-out before check-in
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Check-out date must be after check-in date'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  void toggleAmenity(int amenityId) {
    setState(() {
      if (selectedAmenities.contains(amenityId)) {
        selectedAmenities.remove(amenityId);
      } else {
        selectedAmenities.add(amenityId);
      }
      getRooms();
    });
  }

  Future<void> fetchAmenities() async {
    setState(() {
      isLoading = true;
    });

    try {
      print('Fetching amenities');
      final response = await http.get(Uri.parse('${Api.url}/backend/receptionist/amenities/'));
      print(response.body);

      if (response.statusCode == 200) {
        setState(() {
          // Transform the API response into our amenities structure
          amenities = json.decode(response.body);
        });

        print('Amenities: $amenities');
        // Fetch rooms after amenities
        getRooms();
      } else {
        print('Failed to fetch amenities: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching amenities: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getRooms() async {
    try {
      print('Fetching available rooms');

      // Format dates for API
      String checkinStr = DateFormat('yyyy-MM-dd').format(checkInDate!);
      String checkoutStr = DateFormat('yyyy-MM-dd').format(checkOutDate!);

      String amenitiesStr = selectedAmenities.join(',');

      final queryParams = {
        'checkin': checkinStr,
        'checkout': checkoutStr,
        'maxOccupancy' : adults.toString(),
      };

      if (selectedAmenities.isNotEmpty) {
        queryParams['amenities'] = amenitiesStr;
      }

      final uri = Uri.parse('${Api.url}/backend/receptionist/availableRooms/')
          .replace(queryParameters: queryParams);

      print('API call: $uri');
      final response = await http.get(uri);
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          roomTypes = json.decode(response.body);
          fetchedRooms = roomTypes.map((data) => Room.fromJson(data)).toList();
          isLoading = false;
        });
      } else {
        print('Failed to fetch rooms: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching rooms: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Inside your reservation page where you need to select a room
  Future<void> _selectRoom() async {
    final Room? selectedRoom = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomSelectionPage(fetchedRooms),
      ),
    );

    if (selectedRoom != null) {
      setState(() {
        // Update your reservation with the selected room
        selectedRoomType = selectedRoom.id;

      });
    }
  }
  @override
  void initState() {
    super.initState();
    fetchAmenities();
  }


  @override
  Widget build(BuildContext context) {
    /*
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      });
      return SizedBox(); // avoid building the rest of the widget
    }

     */
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.blueGrey[800],
        ),
      )


          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 50) ,
            Container(
              margin: EdgeInsets.only(left: 30, top: 20),
              child: Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(left: 10),
                height: 50,
                width: 50,
                child: Image.asset(
                  'assets/images/NovotelLogo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // View Rooms Button
            Container(
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(right: 0),
              child: ElevatedButton(
                onPressed: () {
                  _selectRoom();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                child: Text(
                  'View Rooms',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              margin: EdgeInsets.only(left: 30, top: 10, right: 30, bottom: 10),
              padding: EdgeInsets.all(16),
              child: Text(
                "Book Your Stay in our hotel and enjoy our \nour unlimited services !",
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[800],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 8),

            // Date selection
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select dates',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      setState(() {
                        showCalendar = true;
                        selectingCheckIn = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueGrey[200]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Check in',
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: Colors.blueGrey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd MMM, yyyy').format(checkInDate!),
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[900],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('HH:00').format(checkInDate!),
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: Colors.blueGrey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.blueGrey[800],
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Check Out',
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: Colors.blueGrey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('dd MMM, yyyy').format(checkOutDate!),
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey[900],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('HH:00').format(checkOutDate!),
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: Colors.blueGrey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (showCalendar) ...[
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueGrey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectingCheckIn ? 'Select Check-in Date' : 'Select Check-out Date',
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[900],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.blueGrey[800],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      showCalendar = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          TableCalendar(
                            firstDay: DateTime.now(),
                            lastDay: DateTime.now().add(const Duration(days: 365)),
                            focusedDay: selectingCheckIn ? checkInDate! : checkOutDate!,
                            selectedDayPredicate: (day) {
                              return selectingCheckIn
                                  ? isSameDay(day, checkInDate)
                                  : isSameDay(day, checkOutDate);
                            },
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: Colors.blueGrey[300],
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: Colors.blueGrey[800],
                                shape: BoxShape.circle,
                              ),
                              rangeStartDecoration: BoxDecoration(
                                color: Colors.blueGrey[800],
                                shape: BoxShape.circle,
                              ),
                              rangeEndDecoration: BoxDecoration(
                                color: Colors.blueGrey[800],
                                shape: BoxShape.circle,
                              ),
                              rangeHighlightColor: Colors.blueGrey[100]!,
                            ),
                            headerStyle: HeaderStyle(
                              titleCentered: true,
                              formatButtonVisible: false,
                              titleTextStyle: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[900],
                              ),
                            ),
                            onDaySelected: (selectedDay, focusedDay) {
                              updateDate(selectedDay);
                            },
                            rangeStartDay: checkInDate,
                            rangeEndDay: checkOutDate,
                            rangeSelectionMode: RangeSelectionMode.enforced,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  Text(
                    'Guest count',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blueGrey[200]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Adults',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      color: Colors.blueGrey[800],
                                    ),
                                  ),
                                  Text(
                                    'Ages 10+',
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: Colors.blueGrey[600],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline),
                                    color: Colors.blueGrey[700],
                                    onPressed: adults > 1
                                        ? () {
                                      setState(() {
                                        adults--;
                                        getRooms();
                                      });
                                    }
                                        : null,
                                  ),
                                  Text(
                                    '$adults',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey[900],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add_circle_outline),
                                    color: Colors.blueGrey[700],
                                    onPressed: adults < 6
                                        ? () {
                                      setState(() {
                                        adults++;
                                        getRooms();
                                      });
                                    }
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),

                          child: Text(
                            'You are allowed to have your child under 10 years old stay with you in the room ,no extra tax will be applied',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
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

            const SizedBox(height: 8),

            // Amenities selection

            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select amenities',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),

                  const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: amenities.map<Widget>((amenity) {
                    final isSelected = selectedAmenities.contains(amenity['id'].toString());

                    return GestureDetector(
                      onTap: () {
                        toggleAmenity(amenity['id']);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue[100] : Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              amenity['name'],
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: isSelected ? Colors.blue[800] : Colors.blueGrey[700],
                              ),
                            ),
                            if (isSelected)
                              Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: Colors.blue[800],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                ],
              ),
            ),

            const SizedBox(height: 8),

            // Room type selection - Updated to handle the API response format
              Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available rooms',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    roomTypes.isEmpty
                        ? Center(
                      child: Text(
                        'No rooms available for selected criteria',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.blueGrey[600],
                        ),
                      ),
                    )
                        : Column(
                      children: roomTypes.take(2).map<Widget>((room) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedRoomType = room['roomID'];
                                selectedRoomPrice = room['price'];
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedRoomType == room['roomID']
                                      ? Colors.blueGrey[700]!
                                      : Colors.blueGrey[200]!,
                                  width: selectedRoomType == room['roomID'] ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueGrey.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Room image
                                  Container(
                                    height: 160,
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey[100],
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(10),
                                      ),
                                      image: DecorationImage(
                                        image: room['images'] != null && room['images'].isNotEmpty
                                            ? NetworkImage('${Api.url}${room['images'][0]['image']}')
                                            : const AssetImage('/images/background1.jpg') as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: selectedRoomType == room['roomID']
                                        ? Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        margin: const EdgeInsets.all(8),
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey[600],
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    )
                                        : null,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Room ${room['roomID']} - ${room['room_type'].toString().toUpperCase()}',
                                          style: GoogleFonts.nunito(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey[700],
                                          ),
                                        ),
                                        Text(
                                          '${double.parse(room['price']).toStringAsFixed(2)} DZD',
                                          style: GoogleFonts.nunito(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Bed type: ${room['bed_type']}',
                                          style: GoogleFonts.nunito(
                                            fontSize: 14,
                                            color: Colors.blueGrey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    GestureDetector(
                      onTap: () {
                        _selectRoom();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 8),
                        child: Text(
                          'See all rooms',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey[700],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ),



            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: Text(
                      'Meal Plan',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                     // border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildMealPlanOption('RO', 'Room Only', 'No meals included'),
                       // Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                        _buildMealPlanOption('BB', 'Bed & Breakfast', 'Breakfast included'),
                      //  Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                        _buildMealPlanOption('HB', 'Half Board', 'Breakfast and dinner included'),
                      //  Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                        _buildMealPlanOption('FB', 'Full Board', 'Breakfast, lunch and dinner included'),
                       // Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                        _buildMealPlanOption('AI', 'All Inclusive', 'All meals and selected drinks included'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Price summary
            /*
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price Summary',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:  EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueGrey[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Room charge',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Colors.blueGrey[800],
                              ),
                            ),
                            Text(
                              '${calculateTotal()} DZD',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Colors.blueGrey[800],
                              ),
                            ),
                          ],
                        ),


                      ],
                    ),
                  ),
                ],
              ),
            ),

             */

            const SizedBox(height: 10),

            // Book now button
            Container(
              padding: EdgeInsets.all(20),
              child: SizedBox(
                width: 150, // Adjust width as needed
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedRoomType != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => BookingScreen(selectedRoomType , checkInDate , checkOutDate , selectedRoomPrice , adults , selectedMealPlan)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select a room'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Container(

                    child: Text(
                      'Book Now',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 85)
          ],
        ),
      ),
    );
  }
  String selectedMealPlan = 'RO'; // Default to Room Only
  final Map<String, double> _mealPlanPrices = {
    'RO': 0.0,
    'BB': 500.0,
    'HB': 1000.0,
    'FB': 2000.0,
    'AI': 4000.0,
  };
  Widget _buildMealPlanOption(String value, String title, String description) {
    final pricePerNight = _mealPlanPrices[value] ?? 0.0;
    final nights = checkOutDate.difference(checkInDate).inDays;
    final totalMealPrice = pricePerNight * adults * nights;

    return RadioListTile<String>(
      title: Text(
        title,
        style: GoogleFonts.nunito(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (pricePerNight > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '+${totalMealPrice.toStringAsFixed(2)} DZD/person',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[700],
                ),
              ),
            ),
        ],
      ),
      value: value,
      groupValue: selectedMealPlan,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            selectedMealPlan = newValue;
            // Recalculate total here or call your pricing method
          });
        }
      },
      activeColor: Colors.blueGrey[600],
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      dense: true,
    );
  }

}


