import 'package:clienthotelapp/BookingScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'HotelRoom.dart';

class RoomDetailScreen extends StatefulWidget {
  final HotelRoom room;

  const RoomDetailScreen({Key? key, required this.room}) : super(key: key);

  @override
  _RoomDetailScreenState createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  int adults = 1;
  int children = 0;
  DateTime? checkInDate;
  DateTime? checkOutDate;
  bool showCalendar = false;
  bool selectingCheckIn = true; // true for check-in, false for check-out
  int currentImageIndex = 0;



  @override
  void initState() {
    super.initState();
    // Initialize with default dates (current date + 2 days)
    checkInDate = DateTime.now().add(const Duration(days: 2));
    checkOutDate = checkInDate!.add(const Duration(days: 2));
  }

  int get numberOfNights {
    if (checkInDate == null || checkOutDate == null) return 0;
    return checkOutDate!.difference(checkInDate!).inDays;
  }

  double get totalPrice {
    return widget.room.price * numberOfNights;
  }

  void updateDate(DateTime selectedDate) {
    if (selectingCheckIn) {
      setState(() {
        checkInDate = selectedDate;
        // If check-out date is before the new check-in date, adjust it
        if (checkOutDate!.isBefore(selectedDate) ||
            checkOutDate!.isAtSameMomentAs(selectedDate)) {
          checkOutDate = selectedDate.add(const Duration(days: 1));
        }
        selectingCheckIn = false; // Switch to selecting check-out date
      });
    } else {
      if (selectedDate.isAfter(checkInDate!)) {
        setState(() {
          checkOutDate = selectedDate;
          showCalendar = false; // Hide calendar after both dates are selected
        });
      } else {
        // Show error or handle invalid date selection
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Check-out date must be after check-in date',
              style: GoogleFonts.nunito(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],

      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Carousel
                Container(
                  padding:  EdgeInsets.symmetric(vertical: 11),
                  color: Colors.white,
                  child: Column(
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 200,
                          viewportFraction: 0.85,
                          enlargeCenterPage: true,
                          enableInfiniteScroll: true,
                          onPageChanged: (index, reason) {
                            setState(() {
                              currentImageIndex = index;
                            });
                          },
                        ),
                        items: [
                          widget.room.imageUrl,
                          "assets/images/room_detail_1.jpg",
                          "assets/images/room_detail_2.jpg",
                          "assets/images/room_detail_3.jpg",
                        ].map((imageUrl) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                margin:  EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),

                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    imageUrl,
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
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                       SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [0, 1, 2, 3].map((index) {
                          return Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentImageIndex == index
                                  ? Colors.blueGrey[700]
                                  : Colors.blueGrey[200],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Room details
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.room.name,
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Max occupancy: ${widget.room.maxOccupancy} people',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.blueGrey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Room Description',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Experience luxury and comfort in our ${widget.room.name.toLowerCase()}. This spacious accommodation features modern amenities and elegant decor designed to make your stay memorable. Enjoy the panoramic views and premium bedding for a restful night\'s sleep. Our rooms are meticulously cleaned and sanitized for your safety and comfort.',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          color: Colors.blueGrey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Amenities',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.room.amenities.map((amenity) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blueGrey[200]!),
                            ),
                            child: Text(
                              amenity,
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: Colors.blueGrey[800],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

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
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[50],
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
                                      '12:00am',
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
                                        '12:00am',
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
                                color: Colors.blueGrey[50],
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
                                        onPressed: adults < widget.room.maxOccupancy
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
                                color: Colors.blueGrey[50],
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
                                        onPressed: adults + children < widget.room.maxOccupancy
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

                const SizedBox(height: 16),

                // Pricing card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
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
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Details',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${widget.room.price} × $numberOfNights nights',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: Colors.blueGrey[700],
                            ),
                          ),
                          Text(
                            '\$${(widget.room.price * numberOfNights).toStringAsFixed(2)}',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: Colors.blueGrey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Taxes & fees (10%)',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: Colors.blueGrey[700],
                            ),
                          ),
                          Text(
                            '\$${(totalPrice * 0.1).toStringAsFixed(2)}',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: Colors.blueGrey[700],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, thickness: 1),
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
                            '\$${(totalPrice + (totalPrice * 0.1)).toStringAsFixed(2)}',
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

                const SizedBox(height: 100), // Space for the bottom button
              ],
            ),
          ),

          // Book now button at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              /*
              child: SafeArea(
                top: false,
                child: ElevatedButton(
                  onPressed: () {

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                    elevation: 0,
                  ),
                  child: Text(
                    'Book Now',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
               */
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
final HotelRoom staticRoom = HotelRoom(
  name: "Deluxe Suite",
  description: "A luxurious suite with a stunning view of the city skyline.",
  price: 250.0,
  amenities: ["Free Wi-Fi", "Air Conditioning", "Room Service"],
  imageUrl: "https://example.com/deluxe-suite.jpg",
  maxOccupancy: 4,
);