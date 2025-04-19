import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:clienthotelapp/HotelHomePage.dart';
import 'package:clienthotelapp/main.dart';
import 'package:clienthotelapp/providers/authProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'BasePage.dart';
import 'SignUp.dart';
import 'package:http/http.dart' as http;

import 'api.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State variables
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    // Validate inputs
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(Uri.parse('${Api.url}/backend/token/'),
        body: {
          'username': _emailController.text,
          'password': _passwordController.text,
        },
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        print(response.body);
        if (mounted) {
          final data = json.decode(response.body);
          context.read<AuthProvider>().signIn(data);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BasePage())
          );

        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

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
              Text('Welcome back', style: GoogleFonts.nunito(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
              SizedBox(height: screenHeight * 0.02),
              _buildTextField('Email', 'Enter your email', false, screenWidth, _emailController),
              SizedBox(height: screenHeight * 0.02),
              _buildTextField('Password', '••••••••••', true, screenWidth, _passwordController),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Checkbox(
                      value: _rememberMe,
                      onChanged: (val) {
                        setState(() {
                          _rememberMe = val ?? true;
                        });
                      },
                      activeColor: Colors.blueGrey
                  ),
                  Text('Remember me', style: GoogleFonts.nunito(fontSize: screenWidth * 0.03, color: Colors.grey.shade700)),
                  Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: Text('Forgot password?', style: GoogleFonts.nunito(fontSize: screenWidth * 0.03, color: Colors.blueGrey, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.06,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[600],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    disabledBackgroundColor: Colors.blueGrey[300],
                  ),
                  child: _isLoading
                      ? SizedBox(
                    width: screenWidth * 0.05,
                    height: screenWidth * 0.05,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text('Sign In', style: GoogleFonts.nunito(fontSize: screenWidth * 0.04, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              /*
              Center(child: Text('Sign in with', style: GoogleFonts.nunito(fontSize: screenWidth * 0.03, color: Colors.grey.shade600))),
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
              */

              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ", style: GoogleFonts.nunito(color: Colors.grey.shade600, fontSize: screenWidth * 0.03)),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context, PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const SignUpScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 300),
                    )),
                    child: Text('Sign up', style: GoogleFonts.nunito(color: Colors.blueGrey.shade700, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.03)),
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

  Widget _buildTextField(String label, String hintText, bool isPassword, double screenWidth, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.nunito(fontSize: screenWidth * 0.03, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        SizedBox(height: screenWidth * 0.01),
        TextField(
          controller: controller,
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