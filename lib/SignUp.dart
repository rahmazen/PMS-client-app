import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'SignIn.dart'; // Import the SignInScreen for navigation

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 25,),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back_ios_rounded, color: Colors.blueGrey[600], size: screenWidth * 0.05),
                    SizedBox(width: screenWidth * 0.02),
                    Text('Back', style: GoogleFonts.nunito(color: Colors.blueGrey[600], fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              Text('Create Account', style: GoogleFonts.nunito(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
              SizedBox(height: screenHeight * 0.02),
              _buildTextField('Full Name', 'Enter your full name', false, screenWidth),
              SizedBox(height: screenHeight * 0.02),
              _buildTextField('Email', 'Enter your email', false, screenWidth),
              SizedBox(height: screenHeight * 0.02),
              _buildTextField('Password', '••••••••••', true, screenWidth),
              SizedBox(height: screenHeight * 0.02),
              _buildTextField('Confirm Password', '••••••••••', true, screenWidth),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.06,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[600],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Sign Up', style: GoogleFonts.nunito(fontSize: screenWidth * 0.04, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Center(child: Text('Or sign up with', style: GoogleFonts.nunito(fontSize: screenWidth * 0.03, color: Colors.grey.shade600))),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(Icons.facebook, Colors.blue, screenWidth),
                  SizedBox(width: screenWidth * 0.02),
                  _buildSocialButton(Icons.flutter_dash, Colors.lightBlue, screenWidth),
                  SizedBox(width: screenWidth * 0.02),
                  _buildSocialButton(Icons.g_mobiledata, Colors.red, screenWidth),
                  SizedBox(width: screenWidth * 0.02),
                  _buildSocialButton(Icons.apple, Colors.black, screenWidth),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ", style: GoogleFonts.nunito(color: Colors.grey.shade600, fontSize: screenWidth * 0.03)),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context, PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const SignInScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 300),
                    )),
                    child: Text('Sign in', style: GoogleFonts.nunito(color: Colors.blueGrey.shade700, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.03)),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),

              SizedBox(height: screenHeight * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.copyright_rounded, size: screenWidth * 0.03, color: Colors.grey),
                  SizedBox(width: screenWidth * 0.01),
                  Text('2025 Novotel. All rights reserved.', style: GoogleFonts.nunito(fontSize: screenWidth * 0.03, color: Colors.grey)),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              Container(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline_rounded, size: screenWidth * 0.03, color: Colors.grey),
                    SizedBox(width: screenWidth * 0.01),
                    Text('Version 1.0.0', style: GoogleFonts.nunito(fontSize: screenWidth * 0.03, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hintText, bool isPassword, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.nunito(fontSize: screenWidth * 0.03, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        SizedBox(height: screenWidth * 0.01),
        TextField(
          cursorColor: Colors.blueGrey,
          style: GoogleFonts.nunito(),
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.nunito(color: Colors.grey, fontSize: screenWidth * 0.03),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.02),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, Color color, double screenWidth) {
    return CircleAvatar(
      radius: screenWidth * 0.04,
      backgroundColor: Colors.white,
      child: Icon(icon, color: color, size: screenWidth * 0.05),
    );
  }
}