import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'BookingHistoryPage.dart';
import 'EditProfile.dart';




class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 250,
                color: Colors.blueGrey,
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Positioned(
            top: 180,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: 40),
                  Text(
                    'Rahma Zen',
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                      onTap: () {
                        // Navigate to EditProfilePage
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditProfilePage()),
                        );
                      },
                      child: ProfileMenuItem(
                          icon: Icons.edit, text: 'Edit Account')
                  ),
                  GestureDetector(  onTap: () {
                    // Navigate to EditProfilePage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BookingHistoryPage()),
                    );
                  },child: ProfileMenuItem(icon: Icons.list, text: 'View Booking History')),
                  ProfileMenuItem(icon: Icons.settings, text: 'Settings'),

                  ProfileMenuItem(icon: Icons.logout, text: 'Logout', color: Colors.red),
                ],
              ),
            ),
          ),
          Positioned(
            top: 140,
            left: MediaQuery.of(context).size.width / 2 - 40,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/images/backgound2.jpg'),
              backgroundColor: Colors.blueGrey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  ProfileMenuItem({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.blueGrey),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color ?? Colors.black,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
