import 'package:clienthotelapp/BasePage.dart';
import 'package:clienthotelapp/HotelHomePage.dart';
import 'package:clienthotelapp/WelcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

import 'SignIn.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _pages = [
    OnboardingItem(
      title: "Novotel Mobile App",
      description: "Receive real-time updates about booking in our hotel. Plan your trip accordingly and maximize efficiency.",
      image: "assets/images/1.png",
      backgroundColor: Colors.white,
      textColor: Colors.blueGrey.shade700,
    ),
    OnboardingItem(
      title: "Get to know our events",
      description: "Our app facilitates booking, checking updates, enjoying your vacation.",
      image: "assets/images/two.png",
      backgroundColor: Colors.white,
      textColor: Colors.blueGrey.shade700,
    ),
    OnboardingItem(
      title: "Book Now In NovoApp",
      description: "You can easily book your room in our mobile app ! ",
      image: "assets/images/1.png",
      backgroundColor: Colors.white,
      textColor: Colors.blueGrey.shade700,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AuthScreen(),
          transitionDuration: Duration.zero,
        ),
      );


    }
  }

  Widget _buildNextButton() {
    return Container(
      width: double.infinity,
      height: 50,
      margin:  EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: _goToNextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Next",
              style:GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              ), ),
             SizedBox(width: 8),
             Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page content
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),

          // Dots indicator
          Positioned(
            bottom: 130,
            left: 0,
            right: 0,
            child: Center(
              child: DotsIndicator(
                dotsCount: _pages.length,
                position: _currentPage.toDouble(),
                decorator: DotsDecorator(
                  color: Colors.grey.withOpacity(0.5),
                  activeColor: Colors.blueGrey,
                  size: Size.square(8),
                  activeSize: Size(20, 8),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),
          ),

          // next button positioned at bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: _buildNextButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(left:20 ,bottom: 20, top: 0, right: 20),
        child: Column(
          children: [
           // SizedBox(height: 60),
            Container(
              height: 350,
              width: 350,
              child: Image.asset(
                item.image,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 7),
            Text(
              item.title,
              style: GoogleFonts.nunito(
                color: item.textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,

              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              item.description,
              style: GoogleFonts.nunito(
                color: item.textColor.withOpacity(0.8),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
             SizedBox(height: 150),
          ],
        ),
      ),
    );
  }
}

// page for authentication (Sign In/Sign Up)


class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set a background image with a darker overlay
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Darker Overlay
          Container(
            color: Colors.black.withOpacity(0.8), // Adjust opacity for darkness
          ),
          // Content
          Column(
            children: [
              // Skip Button (Top Right)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding:  EdgeInsets.only(top: 40, right: 20),
                  child: TextButton(
                    onPressed: () {
                      // Navigate to HomeScreen
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => BasePage(),
                        ),
                      );
                    },
                    child:  Text(
                      'Skip',
                      style: GoogleFonts.nunito(
                        color: Colors.blueGrey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              // Spacer to push content to the center
              Spacer(),
              // Text in the Middle
               Container(
                 margin: EdgeInsets.all(16),
                 child: Text(
                  'Sign in or Register to Get Notifications and updates',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                               ),
               ),
               SizedBox(height: 5),
              // Sign In / Register Button
              ElevatedButton(
                onPressed: () {

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>  SignInScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  padding:  EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child:  Text(
                  'Sign In / Register',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 40),
              Spacer(), // Spacer to balance the layout
            ],
          ),
        ],
      ),
    );
  }
}



class OnboardingItem {
  final String title;
  final String description;
  final String image;
  final Color backgroundColor;
  final Color textColor;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
    required this.backgroundColor,
    required this.textColor,
  });
}