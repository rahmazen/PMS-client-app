import 'dart:convert';

import 'package:clienthotelapp/BasePage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:clienthotelapp/providers/authProvider.dart';
import 'CheckoutPage.dart';
import 'HotelBookingPage.dart';
import 'NewBookingPage.dart';
import 'SignIn.dart';
import 'package:http/http.dart' as http ;
import 'package:provider/provider.dart';

import 'api.dart';
class BookingScreen extends StatefulWidget {
  final String? selectedRoomType;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String selectedRoomPrice;
  final int adults ;
  final String selectedMealPlan ;

  const BookingScreen(
      this.selectedRoomType,
      this.checkInDate,
      this.checkOutDate,
      this.selectedRoomPrice,
      this.adults,
      this.selectedMealPlan ,
      {Key? key}
      ) : super(key: key);
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {

  Future<void> createReservation() async {
    double price = calculateTotal();
    String checkInStr = DateFormat('yyyy-MM-dd').format(widget.checkInDate);
    String checkOutStr = DateFormat('yyyy-MM-dd').format(widget.checkOutDate);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = authProvider.authData;

    try {

      // Calculate nights between dates (assuming you need this)
      final nights = widget.checkOutDate!.difference(widget.checkInDate!).inDays;

      // Create request body
      final Map<String, dynamic> requestBody = {
        'guest': userData?.username,
        'NationalID': _nationalIdController.text, // Assuming this is a TextEditingController
        'room': widget.selectedRoomType, // Assuming room expects an ID
        'check_in': checkInStr,
        'check_out': checkOutStr,
        'num_of_nights': nights,
        'total_price': price.toString(),
        'meal_plan' : widget.selectedMealPlan ,
      };

      print(requestBody);
      final response = await http.post(
        Uri.parse('${Api.url}/backend/guest/reservations/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final reservation = json.decode(response.body);
        print('Reservation created: $reservation');

      } else {
        print('Failed to create reservation: ${response.statusCode}');
        print('Response: ${response.body}');
        // Show error message
      }
    } catch (e) {
      print('Error creating reservation: $e');
      // Show error message
    }
  }

  int selectedPaymentMethod = 0;
  final TextEditingController _nationalIdController = TextEditingController();

  @override
  void dispose() {
    _nationalIdController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<AuthProvider>(context);
    final userData = userProvider.authData;

    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      });
      return SizedBox();
    }




    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar
                Row(
                  children: [
                    IconButton( onPressed: () {
                      Navigator.pop(context);
                    } ,
                      icon: Icon(Icons.arrow_back_ios),
                      color: Colors.blueGrey[600],
                    ),
                    Text(
                      'Personal Information',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 20),

                // Display user information from provider
                _buildInfoSection("Name", userData?.fullname ?? "Not available"),
                _buildInfoSection("Email", userData?.email ?? "Not available"),
                _buildInfoSection("Phone Number", userData?.phone ?? "Not available"),

                const SizedBox(height: 20),

                // National ID field - kept as editable
                Text(
                  'National ID',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _nationalIdController,
                  decoration: InputDecoration(
                    hintText: 'Enter your National ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.black45,
                        width: 0.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                    filled: false,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'This will be your identifier on the checkout date. Please ensure it\'s correct.',
                  style: GoogleFonts.nunito(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),




                SizedBox(height: 16),

                // Cancellation Policy
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cancellation Policy',
                        style: GoogleFonts.nunito(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Cancellations for bookings must be made at least 48 hours in advance to receive a refund.',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Hotel Rules
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rules',
                        style: GoogleFonts.nunito(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Please adhere to the following hotel rules for a pleasant stay:',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.circle, color: Color(0xFF3F51B5), size: 8),
                          SizedBox(width: 8),
                          Text(
                            'No Smoking Policy',
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                          ),

                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.circle, color: Color(0xFF3F51B5), size: 8),
                          SizedBox(width: 8),
                          Text(
                            'Quiet Hours',
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '12 AM to 7PM',
                            style: GoogleFonts.nunito(color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.circle, color: Color(0xFF3F51B5), size: 8),
                          SizedBox(width: 8),
                          Text(
                            'Guest Behavior',
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Respect staff and guests',
                            style: GoogleFonts.nunito(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),
                // Payment Methods
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.credit_card_outlined),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('EDAHABIA ****4325',
                                style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                              ),
                              Text('Exp: 26/04/27',
                                style: GoogleFonts.nunito(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Radio(
                            value: 0,
                            groupValue: selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                selectedPaymentMethod = 0;
                              });
                            },
                            activeColor: Colors.blue[800],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.credit_card_outlined),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CIB  ****0087',
                                style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                              ),
                              Text('Exp: 12/01/25',
                                style: GoogleFonts.nunito(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Radio(
                            value: 1,
                            groupValue: selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                selectedPaymentMethod = 1;
                              });
                            },
                            activeColor: Colors.blue[800],
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      OutlinedButton(
                        onPressed: () {},
                        child: Center(
                          child: Text(
                            'Add Payment Method',
                            style: GoogleFonts.nunito(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Price
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                          child: Text(
                            'Bill Summary ',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 8,),
                        Row(
                          children: [
                            Text(
                              'Stay cost: ',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${calculateStayCost()} DZD',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        // Meal plan cost
                        Row(
                          children: [
                            Text(
                              'Meal plan: ',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${calculateMealPlanCost()} DZD',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        // Total price
                        SizedBox(height: 10,),
                        Container(
                        //  margin: EdgeInsets.symmetric(horizontal: 10),
                          height: 1,
                          width: 350,
                          color: Colors.blueGrey,
                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Text(
                              '${calculateTotal()} DZD',
                              style: GoogleFonts.nunito(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Price breakdown

                        SizedBox(height: 10),
                        // Note about taxes
                        Text(
                          'Includes taxes and other fees.',
                          style: GoogleFonts.nunito(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Continue Button
                ElevatedButton(
                  onPressed: () {
                    // Check if nationalID field is empty
                    if (_nationalIdController.text.trim().isEmpty) {
                      // Show error message using a SnackBar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('National ID is required'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      // Proceed with reservation
                      createReservation();
                    }
                  },
                  child: Text(
                    'Confirm',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[600],
                    minimumSize: Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildInfoSection(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  double calculateStayCost(){
    if (widget.selectedRoomType == null) return 0;
    final nights = widget.checkOutDate!.difference(widget.checkInDate!).inDays;
    return double.parse(widget.selectedRoomPrice) * nights ;
  }
  final Map<String, double> _mealPlanPrices = {
    'RO': 0.0,
    'BB': 500.0,
    'HB': 1000.0,
    'FB': 2000.0,
    'AI': 4000.0,
  };

  double calculateMealPlanCost(){
    final nights = widget.checkOutDate!.difference(widget.checkInDate!).inDays;

    final double mealPlanPricePerNight = _mealPlanPrices[widget.selectedMealPlan] ?? 0.0;
    return  mealPlanPricePerNight * widget.adults * nights;
      }

  double calculateTotal() {
    if (widget.selectedRoomType == null) return 0;

    // Calculate the number of nights
    final stay = calculateStayCost();
    final double mealPlanTotalCost = calculateMealPlanCost() ;
    return   mealPlanTotalCost+ stay ;

  }

}