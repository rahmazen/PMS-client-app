import 'package:clienthotelapp/BasePage.dart';
import 'package:clienthotelapp/BookingScreen.dart';
import 'package:clienthotelapp/CheckoutPage.dart';
import 'package:clienthotelapp/EditProfile.dart';
import 'package:clienthotelapp/HotelHomePage.dart';
import 'package:clienthotelapp/HotelBookingPage.dart';
import 'package:clienthotelapp/NewBookingPage.dart';
import 'package:clienthotelapp/ProfilePage.dart';
import 'package:clienthotelapp/RoomListingPage.dart';
import 'package:clienthotelapp/WelcomeScreen.dart';
import 'package:clienthotelapp/OnboardingScreens.dart';
import 'package:clienthotelapp/RoomDetailsScreen.dart';
import 'package:clienthotelapp/RoomSelection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'BookingHistoryPage.dart';
import 'SignIn.dart';
import 'SplashScreen.dart';
import 'HotelRoom.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: BasePage()
    );
  }
}

/////  RoomDetailScreen(
//         room:staticRoom)