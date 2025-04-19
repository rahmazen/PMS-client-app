import 'package:clienthotelapp/BasePage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'CheckoutPage.dart';
import 'HotelBookingPage.dart';
import 'NewBookingPage.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int selectedPaymentMethod = 0;

  @override
  Widget build(BuildContext context) {
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon:  Icon(Icons.arrow_back_ios_rounded),
                          onPressed: () {
                            print(Navigator.of(context).canPop()); // Check if a page exists before popping
                            Navigator.pop(context);
                          }


                      ),
                    ),
                     Text(
                      'Personal Information',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.ios_share_rounded),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Personal Information Form
                 Text(
                  'Name',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                 SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    border:
                    OutlineInputBorder( // Normal border
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                      borderSide: BorderSide(
                        color: Colors.black45, // Border color
                        width: 0.5, // Border thickness
                      ),
                    ),
                    enabledBorder: OutlineInputBorder( // Border when not focused
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey, // Light gray border
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder( // Border when focused
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey, // Blue border when selected
                        width: 0.5,
                      ),
                    ),
                    filled: false,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),

                 SizedBox(height: 16),
                 Text(
                  'Date of Birth',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'dd',
                          hintStyle: GoogleFonts.nunito(),
                          border:
                          OutlineInputBorder( // Normal border
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                            borderSide: BorderSide(
                              color: Colors.black45, // Border color
                              width: 0.5, // Border thickness
                            ),
                          ),
                          enabledBorder: OutlineInputBorder( // Border when not focused
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey, // Light gray border
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder( // Border when focused
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey, // Blue border when selected
                              width: 0.5,
                            ),
                          ),
                          filled: false,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                     SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'mm',
                          hintStyle: GoogleFonts.nunito(),
                          border:
                          OutlineInputBorder( // Normal border
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                            borderSide: BorderSide(
                              color: Colors.black45, // Border color
                              width: 0.5, // Border thickness
                            ),
                          ),
                          enabledBorder: OutlineInputBorder( // Border when not focused
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey, // Light gray border
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder( // Border when focused
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey, // Blue border when selected
                              width: 0.5,
                            ),
                          ),
                          filled: false,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'yyyy',
                          hintStyle: GoogleFonts.nunito(),
                          border:
                          OutlineInputBorder( // Normal border
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                            borderSide: BorderSide(
                              color: Colors.black45, // Border color
                              width: 0.5, // Border thickness
                            ),
                          ),
                          enabledBorder: OutlineInputBorder( // Border when not focused
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey, // Light gray border
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder( // Border when focused
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey, // Blue border when selected
                              width: 0.5,
                            ),
                          ),
                          filled: false,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),

                 SizedBox(height: 20),
                 Text(
                  'Email',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                 SizedBox(height: 15),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    border:
                    OutlineInputBorder( // Normal border
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                      borderSide: BorderSide(
                        color: Colors.black45, // Border color
                        width: 0.5, // Border thickness
                      ),
                    ),
                    enabledBorder: OutlineInputBorder( // Border when not focused
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey, // Light gray border
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder( // Border when focused
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey, // Blue border when selected
                        width: 0.5,
                      ),
                    ),
                    filled: false,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),

                 SizedBox(height: 20),
                 Text(
                  'Phone Number',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                 SizedBox(height: 15),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter your number',
                    hintStyle: GoogleFonts.nunito(),
                    border:
                    OutlineInputBorder( // Normal border
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                      borderSide: BorderSide(
                        color: Colors.black45, // Border color
                        width: 0.5, // Border thickness
                      ),
                    ),
                    enabledBorder: OutlineInputBorder( // Border when not focused
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey, // Light gray border
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder( // Border when focused
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey, // Blue border when selected
                        width: 0.5,
                      ),
                    ),

                    filled: false,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
               ////IntlPhoneField(
                 // decoration: InputDecoration(
                   // hintText: 'Enter your number',
                    //border: OutlineInputBorder(
                      //borderRadius: BorderRadius.circular(12),
                      //borderSide: BorderSide.none,
                  //  ),
                    //filled: true,
                    //fillColor: Colors.white,
                   // contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  //),
                //  initialCountryCode: 'US',
                //  onChanged: (phone) {
                //    print(phone.completeNumber);
               //   },
              //  ),
                 //////

                 SizedBox(height: 20),
                 Text(
                  'Add Your Address',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                 SizedBox(height: 12),
                ////// text field for adr
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter your address',
                    hintStyle: GoogleFonts.nunito(),
                    border:
                    OutlineInputBorder( // Normal border
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                      borderSide: BorderSide(
                        color: Colors.black45, // Border color
                        width: 0.5, // Border thickness
                      ),
                    ),
                    enabledBorder: OutlineInputBorder( // Border when not focused
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey, // Light gray border
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder( // Border when focused
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey, // Blue border when selected
                        width: 0.5,
                      ),
                    ),

                    filled: false,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),



                const SizedBox(height: 24),

                // Payment Methods
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:  EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.credit_card_outlined),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:  [
                              Text('Visa ****4325',
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
                            children:  [
                              Text('Master Card ****0087',
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
                        child:  Center(
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
                    children:  [
                      Text(
                        'Cancellation Policy',
                        style: GoogleFonts.nunito(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Cancellations for bookings on 8-9 May must be made at least 48 hours in advance to receive a refund.',
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
                  padding:  EdgeInsets.all(16),
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
                        children:  [
                          Icon(Icons.circle, color: Color(0xFF3F51B5), size: 8),
                          SizedBox(width: 8),
                          Text(
                            'No Smoking Policy',
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Smoking is prohibited...',
                            style: GoogleFonts.nunito(color: Colors.grey),
                          ),
                        ],
                      ),
                       SizedBox(height: 8),
                      Row(
                        children:  [
                          Icon(Icons.circle, color: Color(0xFF3F51B5), size: 8),
                          SizedBox(width: 8),
                          Text(
                            'Quiet Hours',
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'between 10 PM and 7...',
                            style: GoogleFonts.nunito(color: Colors.grey),
                          ),
                        ],
                      ),
                       SizedBox(height: 8),
                      Row(
                        children:  [
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

                // Price
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children:  [
                            Text(
                              '\$900',
                              style: GoogleFonts.nunito(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '\$892',
                              style: GoogleFonts.nunito(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '/Night',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                         Text(
                          'Includes taxes and other fees.',
                          style: GoogleFonts.nunito(
                            color: Colors.grey,
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
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => HotelRoomBookingPage()),
                    );
                    },
                  child:  Text(
                    'Confirm',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  Colors.blueGrey[600],
                    minimumSize:  Size(double.infinity, 56),
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
}