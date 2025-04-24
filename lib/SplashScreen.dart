import 'package:clienthotelapp/WelcomeScreen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'OnboardingScreens.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Animation duration
    );

    // Fade animation (opacity from 0 to 1)
    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    // Scale animation
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation
    _controller.forward();
    // Add a repeating animation for subtle pulsing effect
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    // Navigate to the OnboardingScreens after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
  }

  @override
  void dispose() {
    // Dispose the animation controller
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using a Container with gradient instead of a solid color background
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF0B1033),
         

        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // Clamp the opacity value to ensure it stays within the valid range
                  final opacity = _fadeAnimation.value.clamp(0.5, 1.0);
                  return Opacity(
                    opacity: opacity, // Apply clamped fade animation
                    child: Transform.scale(
                      scale: _scaleAnimation.value, // Apply scale animation
                      child: Container(
                        height: 250,
                        width: 250,
                        child: Center(
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn, // This will make the logo white
                            ),
                            child: Image.asset(
                              'assets/images/NovotelLogo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Adding a text below the logo
              SizedBox(height: 20),

              // Optional subtle tagline
              SizedBox(height: 8),

            ],
          ),
        ),
      ),
    );
  }
}