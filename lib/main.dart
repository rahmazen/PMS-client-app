import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'EnhancedNotificationPage.dart';
import 'NotificationProvider.dart';

void main() {
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
    return ChangeNotifierProvider(
      create: (context) => NotificationProvider(),
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
        home: EnhancedNotificationPage(),
      ),
    );
  }
}