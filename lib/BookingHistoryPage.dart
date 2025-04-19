import 'dart:convert';
import 'package:clienthotelapp/providers/authProvider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'api.dart';
import 'providers/authProvider.dart';

class Booking {
  final int id;
  final String roomNumber;
  final String checkIn;
  final String checkOut;
  final int nights;
  final double totalPrice;
  final bool isCheckedIn;
  final bool isCheckedOut;
  final bool isCancelled;
  final List<Map<String, dynamic>> payments;
  final List<Map<String, dynamic>> companions;

  Booking({
    required this.id,
    required this.roomNumber,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.totalPrice,
    required this.isCheckedIn,
    required this.isCheckedOut,
    required this.isCancelled,
    required this.payments,
    required this.companions,
  });

  // Helper properties for UI display
  String get dates {
    final startDate = DateTime.parse(checkIn);
    final endDate = DateTime.parse(checkOut);
    final formatter = DateFormat('MMM dd, yyyy');
    return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
  }

  String get guests {
    if (companions.isEmpty) {
      return 'No companions';
    }
    return '${companions.length + 1} Guests';
  }

  String get dueDate {
    if (isCancelled) {
      return 'Cancelled';
    } else if (isCheckedOut) {
      return 'Completed';
    } else if (isCheckedIn) {
      return 'Checked In';
    } else {
      final checkInDate = DateTime.parse(checkIn);
      final formatter = DateFormat('MMM dd, yyyy');
      return formatter.format(checkInDate);
    }
  }

  // Placeholder values for hotel details (since they're not in the JSON)
  String get hotel => 'RES-$id';
  String get location => 'Room $roomNumber';
  String get imageUrl => 'https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80';
  double get originalCost => totalPrice * 1.2; // Just for display purposes
}

class BookingHistoryPage extends StatefulWidget {
  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  List<Booking> bookings = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Get the username from the auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final username = authProvider.authData?.username;

      final response = await http.get(
        Uri.parse('${Api.url}/backend/guest/userreservation/$username/'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');

        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          bookings = jsonData.map((item) => Booking(
            id: item['reservationID'],
            roomNumber: item['room'],
            checkIn: item['check_in'],
            checkOut: item['check_out'],
            nights: item['num_of_nights'],
            totalPrice: double.parse(item['total_price']),
            isCheckedIn: item['is_checked_in'],
            isCheckedOut: item['is_checked_out'],
            isCancelled: item['is_cancelled'],
            payments: List<Map<String, dynamic>>.from(item['payments']),
            companions: List<Map<String, dynamic>>.from(item['guest_companions']),
          )).toList();
          isLoading = false;
        });

        print('Bookings fetched successfully: ${bookings.length}');
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to fetch bookings: ${response.statusCode}';
        });
        print('Failed to fetch bookings: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching bookings: $e';
      });
      print('Error fetching bookings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    Icon(Icons.arrow_back_ios_rounded, color: Colors.blueGrey[600], size: 15),
                    SizedBox(width: 5),
                    Text('Back', style: GoogleFonts.nunito(color: Colors.blueGrey[600], fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Booking History",
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[800],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: _buildBookingsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.blueGrey[600],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchBookings,
              child: Text('Try Again'),
              style: ElevatedButton.styleFrom(

                textStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hotel_outlined, size: 64, color: Colors.blueGrey[300]),
            SizedBox(height: 16),
            Text(
              'No Bookings Found',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You don\'t have any bookings yet.\nStart exploring and book your first stay!',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.blueGrey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
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
              /*
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  booking.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported, color: Colors.grey[500]),
                    );
                  },
                ),
              ),
              */
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
                    Row(
                      children: [

                        SizedBox(width: 8),
                        if (booking.isCancelled)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Cancelled',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: Colors.red[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "\$${booking.totalPrice.toStringAsFixed(2)}",
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    booking.isCheckedOut ? "Completed" : (booking.isCheckedIn ? "Checked In" : "Reserved"),
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: booking.isCheckedOut ? Colors.green[600] : Colors.blueGrey[400],
                      fontWeight: booking.isCheckedOut ? FontWeight.w400 : FontWeight.normal,
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              SizedBox(height: 20),
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
                          "Booking Details",
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 24), // Balance the header
                  ],
                ),
              ),

              // Status banner for cancelled bookings
              if (booking.isCancelled)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  color: Colors.red[50],
                  child: Center(
                    child: Text(
                      "This booking has been cancelled",
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ),

              // Hotel Info Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
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
                        /*
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            "assets/images/hotel_1.jfif",
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: Icon(Icons.image_not_supported, color: Colors.grey[500]),
                              );
                            },
                          ),
                        ), */
                        SizedBox(width: 16),
                        Expanded(
                          child :Row(

                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                           Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

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
                              Text(

                                booking.isCheckedOut ? "Completed" : (booking.isCheckedIn ? "Checked In" : "Reserved"),
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  color: booking.isCheckedOut ? Colors.red  :(booking.isCheckedIn ? Colors.green : Colors.blueGrey[400]),
                                  fontWeight: booking.isCheckedOut ? FontWeight.w400 : FontWeight.normal,
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
                                      Text(
                                        "${booking.nights} night${booking.nights > 1 ? 's' : ''}",
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
                                        "Guest Information",
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
                                      if (booking.companions.isNotEmpty) ...[
                                        SizedBox(height: 8),
                                        Text(
                                          "Companions:",
                                          style: GoogleFonts.nunito(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blueGrey[700],
                                          ),
                                        ),
                                        ...booking.companions.map((companion) => Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            companion['fullname'],
                                            style: GoogleFonts.nunito(
                                              fontSize: 14,
                                              color: Colors.blueGrey[700],
                                            ),
                                          ),
                                        )),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (booking.payments.isNotEmpty) ...[
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
                                          "Payment History",
                                          style: GoogleFonts.nunito(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey[800],
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        ...booking.payments.map((payment) {
                                          final paymentDate = DateTime.parse(payment['date']);
                                          final formatter = DateFormat('MMM dd, yyyy');

                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      payment['type'] == 'stay' ? 'Room Payment' : 'Service Payment',
                                                      style: GoogleFonts.nunito(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.blueGrey[700],
                                                      ),
                                                    ),
                                                    Text(
                                                      '${payment['payment_method']} - ${formatter.format(paymentDate)}',
                                                      style: GoogleFonts.nunito(
                                                        fontSize: 12,
                                                        color: Colors.blueGrey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  '\$${double.parse(payment['amount']).toStringAsFixed(2)}',
                                                  style: GoogleFonts.nunito(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blueGrey[800],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
                                      "\$${booking.totalPrice.toStringAsFixed(2)}",
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

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}