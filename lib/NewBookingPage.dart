import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:clienthotelapp/BookingScreen.dart';
import 'package:clienthotelapp/RoomListingPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'api.dart';

class RoomBookingPage extends StatefulWidget {
  @override
  _RoomBookingPageState createState() => _RoomBookingPageState();
}

class _RoomBookingPageState extends State<RoomBookingPage> {
  DateTime? checkInDate = DateTime.now();
  DateTime? checkOutDate = DateTime.now().add(const Duration(days: 1));
  bool showCalendar = false;
  bool selectingCheckIn = true;
  int adults = 1;
  int children = 0;
  String? selectedRoomType;
  List<String> selectedAmenities = [];

  // Sample data
   List<dynamic> roomTypes = [
     { 'id': 'loading...',
       'name': 'loading...',
       'description': 'loading...',
       'price': 00,
       'image': 'images/1.jpg',
       'maxOccupancy': 4,}

  ];

  final List<dynamic> amenities = [
    {1, 'loading...'},
    {2, 'loading...'},

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

  void toggleAmenity(String amenity) {
    setState(() {
      if (selectedAmenities.contains(amenity)) {
        selectedAmenities.remove(amenity);
      } else {
        selectedAmenities.add(amenity);
      }
    });
  }

  Future<void> fetchAmenities() async{
    try {
      print('we are in fetch amenities');
      final response = await http.get(Uri.parse('${Api.url}/backend/receptionist/amenities/'));
      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          selectedAmenities = json.decode(response.body);
        });

        print('Data: $selectedAmenities');
        // Do something with the data
      } else {
        print('Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  Future<void> getRooms() async{
    try {
      print('we are in fetch getRooms');
      final response = await http.get(Uri.parse('${Api.url}/backend/receptionist/availableRooms/').replace(
        queryParameters: {
          'checkin': checkInDate,
          'checkout': checkOutDate,
          'amenities': selectedAmenities.join(',')
        },
      ),);

          print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          roomTypes = json.decode(response.body);
        });

      } else {
        print('Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }



  @override
  void initState(){
    super.initState();
    fetchAmenities();
    getRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
     
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Container(
             // color: Colors.red,
              margin: EdgeInsets.only(left: 30, top: 20),
              child: Container(
                //color: Colors.red,
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
                  //// here rahma
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => RoomListingPage()),
                  );
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
                  color: Colors.blueGrey[900],
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
                      padding:  EdgeInsets.all(16),
                      decoration: BoxDecoration(
                      //  color: Colors.blueGrey[50],
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
                          //  color: Colors.blueGrey[50],
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
                                    'Ages 13+',
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
                                    onPressed: adults < 4
                                        ? () {
                                      setState(() {
                                        adults++;
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
                                    'Children',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      color: Colors.blueGrey[800],
                                    ),
                                  ),
                                  Text(
                                    'Ages 0-12',
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
                                    onPressed: children > 0
                                        ? () {
                                      setState(() {
                                        children--;
                                      });
                                    }
                                        : null,
                                  ),
                                  Text(
                                    '$children',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey[900],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add_circle_outline),
                                    color: Colors.blueGrey[700],
                                    onPressed: adults + children < 4
                                        ? () {
                                      setState(() {
                                        children++;
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
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Room type selection
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select room type',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (var roomType in roomTypes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedRoomType = roomType.id;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedRoomType == roomType.id
                                  ? Colors.blueGrey[800]!
                                  : Colors.blueGrey[200]!,
                              width: selectedRoomType == roomType.id ? 2 : 1,
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
                              // Room image placeholder
                              Container(
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[100],
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                  image: DecorationImage(
                                    image: AssetImage(roomType.image),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: selectedRoomType == roomType.id
                                    ? Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey[800],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          roomType.name,
                                          style: GoogleFonts.nunito(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey[800],
                                          ),
                                        ),
                                        Text(
                                          '\$${roomType.price}/night',
                                          style: GoogleFonts.nunito(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      roomType.description,
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        color: Colors.blueGrey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Max occupancy: ${roomType.maxOccupancy} guests',
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
                    children: amenities.map((amenity) {
                      final isSelected = selectedAmenities.contains(amenity);
                      return InkWell(
                        onTap: () => toggleAmenity(amenity),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blueGrey[700]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blueGrey[800]!
                                  : Colors.blueGrey[200]!,
                            ),
                          ),
                          child: Text(
                            amenity,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.blueGrey[800],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Price summary
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
                              '\$${calculateRoomCharge()}',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Colors.blueGrey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Amenities',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Colors.blueGrey[800],
                              ),
                            ),
                            Text(
                              '\$${calculateAmenitiesCharge()}',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Colors.blueGrey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Taxes & fees',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Colors.blueGrey[800],
                              ),
                            ),
                            Text(
                              '\$${calculateTaxesAndFees()}',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Colors.blueGrey[800],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[900],
                              ),
                            ),
                            Text(
                              '\$${calculateTotal()}',
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[900],
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

            const SizedBox(height: 16),

            // Book now button
            Container(
              padding: EdgeInsets.all(5),
              child: SizedBox(
                width: 150, // Adjust width as needed
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedRoomType != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => BookingScreen()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select a room type'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[800],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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

            SizedBox(height: 85)
          ],
        ),
      ),
    );
  }

  int calculateRoomCharge() {
    if (selectedRoomType == null) return 0;

    // Find the selected room type
    final selectedRoom = roomTypes.firstWhere(
          (room) => room.id == selectedRoomType,
      orElse: () => roomTypes.first,
    );

    // Calculate the number of nights
    final nights = checkOutDate!.difference(checkInDate!).inDays;

    // Calculate the total room charge
    return selectedRoom.price * nights;
  }

  int calculateAmenitiesCharge() {
    // Example pricing for amenities
    return selectedAmenities.length * 10;
  }

  int calculateTaxesAndFees() {
    // Example calculation: 15% of room charge
    return (calculateRoomCharge() * 0.15).round();
  }

  int calculateTotal() {
    return calculateRoomCharge() + calculateAmenitiesCharge() + calculateTaxesAndFees();
  }
}

