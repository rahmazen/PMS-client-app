import 'dart:ui';

import 'package:clienthotelapp/SignIn.dart';
import 'package:clienthotelapp/providers/authProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'BasePage.dart';
import 'BookingHistoryPage.dart';
import 'EditProfile.dart';
import 'api.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Add a flag to handle authentication redirect only once
  bool _redirectingToLogin = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check authentication status safely outside of the build method
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.authData == null && !_redirectingToLogin) {
      _redirectingToLogin = true;
      // Use Future.microtask to schedule navigation after the current build completes
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  SignInScreen(redirectToPage: ProfilePage())),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: true);

    // If we're already redirecting or auth is null, show a loading screen
    if (_redirectingToLogin || auth.authData == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Otherwise, show the profile page
    return Scaffold(
      body: Stack(
        children: [

          Column(
            children: [
              SizedBox(
                height: 250,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Profile background image
                    Image.network(
                      '${Api.url}${auth.authData!.image}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback for image load errors
                        return Container(
                          color: Colors.blueGrey[200],
                          child: Icon(
                            Icons.person,
                            size: 100,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    // Blur effect
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        color: Colors.black.withOpacity(0.3), // Optional dimming
                      ),
                    ),
                  ],
                ),
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
                    auth.authData!.fullname,
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    auth.authData!.username,
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.black26
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
                          icon: Icons.edit,
                          text: 'Edit Account'
                      )
                  ),
                  GestureDetector(
                      onTap: () {
                        // Navigate to EditProfilePage
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BookingHistoryPage()),
                        );
                      },
                      child: ProfileMenuItem(
                          icon: Icons.list,
                          text: 'View Booking History'
                      )
                  ),
                  GestureDetector(
                    onTap: () async {
                      // Show a confirmation dialog
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Logout'),
                          content: Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: Colors.blueGrey),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blueGrey,
                              ),
                            ),
                            TextButton(
                              onPressed: (){
                                Provider.of<AuthProvider>(context , listen: false).signOut();
                              },
                              child: Text(
                                'Logout',
                                style: TextStyle(color: Colors.red),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ) ?? false;

                      if (shouldLogout) {
                        // Get the provider without listening
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        await authProvider.signOut();

                        // Navigate to login screen
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) =>  SignInScreen(redirectToPage: ProfilePage())),
                              (route) => false, // This removes all previous routes
                        );
                      }
                    },
                    child: ProfileMenuItem(
                        icon: Icons.logout,
                        text: 'Logout',
                        color: Colors.red
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 140,
            left: MediaQuery.of(context).size.width / 2 - 40,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage('${Api.url}${auth.authData!.image}'),
              backgroundColor: Colors.blueGrey[600],
              onBackgroundImageError: (exception, stackTrace) {
                // Fallback for profile image errors
              },
            ),
          ),
          Positioned(
            top: 20 ,
            left :16 ,
            child:
            IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 30),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BasePage())),
            )

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