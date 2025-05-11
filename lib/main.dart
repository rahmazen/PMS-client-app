import 'package:clienthotelapp/BasePage.dart';
import 'package:clienthotelapp/BookingScreen.dart';
import 'package:clienthotelapp/CheckoutPage.dart';
import 'package:clienthotelapp/EditProfile.dart';
import 'package:clienthotelapp/HotelHomePage.dart';
import 'package:clienthotelapp/HotelBookingPage.dart';
import 'package:clienthotelapp/HotelReviewPage.dart';
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
import 'package:google_fonts/google_fonts.dart';
import 'BookingHistoryPage.dart';

import 'QrScannerPage.dart';
import 'RestaurantPage.dart';
import 'ServiceDetailPage.dart';
import 'Services.dart';
import 'SignIn.dart';
import 'SplashScreen.dart';
import 'HotelRoom.dart';
import 'package:provider/provider.dart';
import 'providers/authProvider.dart';
import 'providers/roomProvider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'EnhancedNotificationPage.dart';
import 'NotificationProvider.dart';


void main() async{
 // WidgetsFlutterBinding.ensureInitialized();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // enables only in debug/profile mode
      builder: (context) => const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});



@override
Widget build(BuildContext context) {
  return  MultiProvider(
    providers: [

      ChangeNotifierProvider(create: (_) => AuthProvider()),
      // ChangeNotifierProvider(create: (_) => RoomProvider()),
      ChangeNotifierProvider(create: (_) => NotificationProvider()),
    ],
    child: GetMaterialApp(
      useInheritedMediaQuery: true,
      builder: DevicePreview.appBuilder,
      locale: DevicePreview.locale(context),
      debugShowCheckedModeBanner: false,
      title: 'Hotel App',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Colors.white,
        ),
        colorScheme: const ColorScheme.light(
          primary: Colors.white,
        ),
        textTheme: GoogleFonts.nunitoTextTheme(
          Theme.of(context).textTheme,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: BasePage(),
    ),
  );
}
}