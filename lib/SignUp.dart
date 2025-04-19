import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'SignIn.dart';
import 'api.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Form keys for each step
  final _firstFormKey = GlobalKey<FormState>();
  final _secondFormKey = GlobalKey<FormState>();

  // Text controllers
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Role selection
  String _selectedRole = "guest"; // Default role
  bool _isLoading = false;
  bool _isCheckingUsername = false;
  String _errorMessage = '';

  // Username validation status
  bool _usernameExists = false;
  bool _usernameValid = false;

  // Form step tracking
  bool _isFirstStep = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Check if username exists using API
  Future<void> _checkUsernameExists(String username) async {
    if (username.isEmpty || username.length < 4) {
      setState(() {
        _usernameExists = false;
        _usernameValid = false;
      });
      return;
    }

    setState(() {
      _isCheckingUsername = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${Api.url}/backend/guest/usercheck/$username/'),
        headers: {'Content-Type': 'application/json'},
      );

      setState(() {
        _isCheckingUsername = false;
        _usernameExists = response.statusCode != 200;
        _usernameValid = username.length >= 4;
      });
    } catch (e) {
      setState(() {
        _isCheckingUsername = false;
        _usernameExists = false;
      });
      print('Error checking username: $e');
    }
  }

  // Go to next step after validating first form
  Future<void> _proceedToNextStep() async {
    if (!_firstFormKey.currentState!.validate()) {
      return;
    }

    // Final check for username existence
    if (_usernameExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username already exists. Please choose another one.')),
      );
      return;
    }

    setState(() {
      _isFirstStep = false;
    });
  }

  // Go back to first step
  void _goBackToFirstStep() {
    setState(() {
      _isFirstStep = true;
    });
  }

  // Register user
  Future<void> _registerUser() async {
    if (!_secondFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('${Api.url}/backend/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fullname': _fullNameController.text,
          'username': _usernameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'password': _passwordController.text,
          'role': 'guest',
        }),
      );

      if (response.statusCode == 201) {
        // Registration successful, navigate to sign in
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen())
        );

      } else {
        // Handle errors from backend
        final responseData = json.decode(response.body);
        setState(() {
          _errorMessage = responseData['message'] ?? 'Registration failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please check your connection.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          child: _isFirstStep ? _buildFirstStep(screenWidth, screenHeight) : _buildSecondStep(screenWidth, screenHeight),
        ),
      ),
    );
  }

  // First form step - User details
  Widget _buildFirstStep(double screenWidth, double screenHeight) {
    return Form(
      key: _firstFormKey,
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
          Text('Create Account', style: GoogleFonts.nunito(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
          SizedBox(height: screenHeight * 0.01),
          Text('Step 1 of 2: Personal Information', style: GoogleFonts.nunito(fontSize: screenWidth * 0.035, color: Colors.blueGrey[400])),
          SizedBox(height: screenHeight * 0.03),

          // Full Name
          _buildTextFormField(
            label: 'Full Name',
            hintText: 'Enter your full name',
            controller: _fullNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
            screenWidth: screenWidth,
          ),

          SizedBox(height: screenHeight * 0.02),

          // Username with async validation
          _buildTextFormField(
            label: 'Username',
            hintText: 'Choose a username',
            controller: _usernameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a username';
              }
              if (value.length < 4) {
                return 'Username must be at least 4 characters';
              }
              if (_usernameExists) {
                return 'Username already exists';
              }
              return null;
            },
            suffixIcon: _isCheckingUsername
                ? SizedBox(
              height: 12,
              width: 12,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.blueGrey,
                ),
              ),
            )
                : _usernameController.text.length >= 4
                ? Icon(
              _usernameExists ? Icons.close : Icons.check,
              color: _usernameExists ? Colors.red : Colors.green,
              size: 20,
            )
                : null,
            onChanged: (value) {
              // Check username after a short delay to prevent making too many API calls
              Future.delayed(Duration(milliseconds: 500), () {
                if (_usernameController.text == value) {
                  _checkUsernameExists(value);
                }
              });
            },
            screenWidth: screenWidth,
            errorColor: _usernameExists ? Colors.red : null,
            borderColor: _usernameExists
                ? Colors.red
                : (_usernameValid && !_usernameExists)
                ? Colors.green
                : null,
          ),

          SizedBox(height: screenHeight * 0.02),

          // Email
          _buildTextFormField(
            label: 'Email',
            hintText: 'Enter your email',
            controller: _emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            screenWidth: screenWidth,
          ),

          SizedBox(height: screenHeight * 0.02),

          // Phone
          _buildTextFormField(
            label: 'Phone Number',
            hintText: 'Enter your phone number',
            controller: _phoneController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
            screenWidth: screenWidth,
            keyboardType: TextInputType.phone,
          ),

          SizedBox(height: screenHeight * 0.02),

          // Next Button
          SizedBox(
            width: double.infinity,
            height: screenHeight * 0.06,
            child: ElevatedButton(
              onPressed: _isCheckingUsername ? null : _proceedToNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[600],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Next', style: GoogleFonts.nunito(fontSize: screenWidth * 0.04, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
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
          _buildFooter(screenWidth, screenHeight),
        ],
      ),
    );
  }

  // Second form step - Password
  Widget _buildSecondStep(double screenWidth, double screenHeight) {
    return Form(
      key: _secondFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 25),
          GestureDetector(
            onTap: _goBackToFirstStep,
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
          SizedBox(height: screenHeight * 0.01),
          Text('Step 2 of 2: Set Password', style: GoogleFonts.nunito(fontSize: screenWidth * 0.035, color: Colors.blueGrey[400])),
          SizedBox(height: screenHeight * 0.03),

          // User info summary
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account Information',
                    style: GoogleFonts.nunito(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700)),
                SizedBox(height: screenHeight * 0.01),
                _buildInfoRow('Username', _usernameController.text, screenWidth),
                _buildInfoRow('Full Name', _fullNameController.text, screenWidth),
                _buildInfoRow('Email', _emailController.text, screenWidth),
                _buildInfoRow('Phone', _phoneController.text, screenWidth),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.03),

          // Password
          _buildTextFormField(
            label: 'Password',
            hintText: '••••••••••',
            controller: _passwordController,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
            screenWidth: screenWidth,
          ),

          SizedBox(height: screenHeight * 0.02),

          // Confirm Password
          _buildTextFormField(
            label: 'Confirm Password',
            hintText: '••••••••••',
            controller: _confirmPasswordController,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            screenWidth: screenWidth,
          ),

          SizedBox(height: screenHeight * 0.02),

          // Error message
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                _errorMessage,
                style: GoogleFonts.nunito(color: Colors.red, fontSize: screenWidth * 0.03),
              ),
            ),

          // Sign Up Button
          SizedBox(
            width: double.infinity,
            height: screenHeight * 0.06,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _registerUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[600],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isLoading
                  ? SizedBox(
                height: screenWidth * 0.03,
                width: screenWidth * 0.03,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : Text('Sign Up', style: GoogleFonts.nunito(fontSize: screenWidth * 0.04, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          Center(child: Text('Or sign up with', style: GoogleFonts.nunito(fontSize: screenWidth * 0.03, color: Colors.grey.shade600))),
          SizedBox(height: screenHeight * 0.02),
/*
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
          _buildFooter(screenWidth, screenHeight),
        ],
      ),
    );
  }

  // Helper widget for info summary
  Widget _buildInfoRow(String label, String value, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ',
              style: GoogleFonts.nunito(fontSize: screenWidth * 0.03, color: Colors.blueGrey.shade600, fontWeight: FontWeight.w600)),
          Text(value,
              style: GoogleFonts.nunito(fontSize: screenWidth * 0.03, color: Colors.blueGrey.shade800)),
        ],
      ),
    );
  }

  // Reusable footer widget
  Widget _buildFooter(double screenWidth, double screenHeight) {
    return Column(
      children: [
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
    );
  }

  Widget _buildTextFormField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required FormFieldValidator<String> validator,
    required double screenWidth,
    bool isPassword = false,
    Widget? suffixIcon,
    Function(String)? onChanged,
    TextInputType? keyboardType,
    Color? errorColor,
    Color? borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.w600,
              color: errorColor ?? Colors.grey.shade700
          ),
        ),
        SizedBox(height: screenWidth * 0.01),
        TextFormField(
          controller: controller,
          cursorColor: Colors.blueGrey,
          style: GoogleFonts.nunito(),
          obscureText: isPassword,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.nunito(color: Colors.grey, fontSize: screenWidth * 0.03),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: borderColor ?? Colors.transparent,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: borderColor ?? Colors.transparent,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: borderColor ?? Colors.blueGrey.shade300,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorColor ?? Colors.red,
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.02),
            errorStyle: GoogleFonts.nunito(fontSize: screenWidth * 0.025, color: errorColor ?? Colors.red),
            suffixIcon: suffixIcon,
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

// Extension to capitalize first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}