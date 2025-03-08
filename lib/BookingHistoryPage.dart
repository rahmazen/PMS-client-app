import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class Booking {
  final int id;
  final String hotel;
  final String location;
  final String roomType;
  final String dates;
  final String guests;
  final double totalCost;
  final double originalCost;
  final String dueDate;
  final String imageUrl;

  Booking({
    required this.id,
    required this.hotel,
    required this.location,
    required this.roomType,
    required this.dates,
    required this.guests,
    required this.totalCost,
    required this.originalCost,
    required this.dueDate,
    required this.imageUrl,
  });
}

class BookingHistoryPage extends StatelessWidget {
  final List<Booking> bookings = [
    Booking(
      id: 1,
      hotel: "Standard Room",
      location: "Constantine",
      roomType: "",
      dates: "May 8-9",
      guests: "4 Adult",
      totalCost: 892,
      originalCost: 900,
      dueDate: "19 May 2024",
      imageUrl: "assets/images/background2.jpg",
    ),
    Booking(
      id: 2,
      hotel: "Deluxe Room",
      location: "Constantine",
      roomType: "",
      dates: "June 15-18",
      guests: "2 Adult",
      totalCost: 1250,
      originalCost: 1400,
      dueDate: "1 June 2024",
      imageUrl: "assets/images/background2.jpg",
    ),
    Booking(
      id: 3,
      hotel: "Family Room",
      location: "Family Room",
      roomType: "",
      dates: "July 22-26",
      guests: "3 Adult, 2 Children",
      totalCost: 1680,
      originalCost: 1800,
      dueDate: "10 July 2024",
      imageUrl: "assets/images/background2.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15,),
               GestureDetector(
                 onTap: () {
                   Navigator.pop(context);
                 },
                 child: Row(
                  children: [
                    Icon(Icons.arrow_back_ios_rounded, color: Colors.blueGrey[600], size: 15),
                    SizedBox(width: 5),
                    Text('Back', style: GoogleFonts.nunito(color: Colors.blueGrey[600], fontSize:18, fontWeight: FontWeight.bold)),
                  ],
                               ),
               ),

              SizedBox(height: 13,),
              Text(
                "Booking History",
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    return BookingCard(
                      booking: bookings[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingDetailsPage(booking: bookings[index]),
                          ),
                        );
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

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const BookingCard({
    Key? key,
    required this.booking,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  booking.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.hotel,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      booking.location,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      booking.dates,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.blueGrey[700],
                      ),
                    ),
                    Text(
                      booking.roomType,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.blueGrey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "\$${booking.totalCost.toStringAsFixed(2)}",
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Paid",
                    style:GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.blueGrey[400],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookingDetailsPage extends StatelessWidget {
  final Booking booking;

  const BookingDetailsPage({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            // Heade
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.blueGrey[700],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Review Booking",
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),

            // Hotel Info Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          booking.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.roomType,
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Colors.blueGrey[600],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              booking.hotel,
                              style: GoogleFonts.nunito(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Colors.blueGrey[600],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  booking.location,
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: Colors.blueGrey[600],
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
              ),
            ),

            SizedBox(height: 16),

            // Booking Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Booking",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.blueGrey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Dates",
                                      style: GoogleFonts.nunito(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey[800],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      booking.dates,
                                      style: GoogleFonts.nunito(
                                        fontSize: 16,
                                        color: Colors.blueGrey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Divider(height: 1, color: Colors.grey[200]),
                          SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Guest",
                                      style: GoogleFonts.nunito(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey[800],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      booking.guests,
                                      style: GoogleFonts.nunito(
                                        fontSize: 16,
                                        color: Colors.blueGrey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Payment Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment Information",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.blueGrey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Cost",
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[800],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "\$${booking.originalCost.toStringAsFixed(2)}",
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.blueGrey[400],
                                    ),
                                  ),
                                  Text(
                                    "\$${booking.totalCost.toStringAsFixed(2)}",
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey[800],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Due : ${booking.dueDate}",
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: Colors.blueGrey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
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