import 'package:clienthotelapp/HotelHomePage.dart';
import 'package:clienthotelapp/NewBookingPage.dart';
import 'package:clienthotelapp/ProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'HotelReviewPage.dart';
import 'QrScannerPage.dart';
import 'Services.dart';

class BasePage extends StatefulWidget {
  @override
  _BasePageState createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  int _selectedIndex = 0;

  final List<Widget> pages = [
    HotelHomePage(),
    RoomBookingPage(),
    HotelReviewPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          pages.isNotEmpty ? pages[_selectedIndex] : Container(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 60,
              margin:  EdgeInsets.only(bottom: 8, left: 7, right: 7),
              padding:  EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Left section
                  Row(
                    children: [
                      buildNavItem(0, Icons.home_rounded, Icons.home_rounded, 'Home'),
                      const SizedBox(width: 30),
                      buildNavItem(1, Icons.calendar_month_rounded, Icons.calendar_month_rounded, 'Booking'),
                    ],
                  ),
                  // Center QR scanner button
                  Transform.translate(
                    offset: Offset(0, -15), // Move the button upwards
                    child: GestureDetector(
                      onTap: () {
                        // Add your QR scanner functionality here
                        // launchQRScanner();
                      },
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to EditProfilePage
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ClientRoomPage()),
                          );
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child:  Icon(
                            Icons.qr_code_2_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Right section
                  Row(
                    children: [
                      buildNavItem(2, Icons.star_rounded, Icons.search, 'Explore'),
                      const SizedBox(width: 30),
                      buildNavItem(3, Icons.person, Icons.person, 'Profile'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNavItem(int index, IconData unselectedIcon, IconData selectedIcon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? selectedIcon : unselectedIcon,
            color: isSelected ? Colors.blueGrey : Colors.blueGrey,
            size: 24,
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              color: isSelected ? Colors.blueGrey : Colors.blueGrey,
              fontSize: 10,
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }
}

