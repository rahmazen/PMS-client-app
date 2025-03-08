import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Guest Information Section
            Text(
              'Guest Information',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildGuestForm(),
            const SizedBox(height: 24),

            // Payment Method Section
            Text(
              'Payment Method',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodSection(),
            const SizedBox(height: 24),

            // Confirm Booking Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Handle booking confirmation
                  _showConfirmationDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Confirm Booking',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestForm() {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Full Name of Guest 1 (Required)',
            labelStyle: GoogleFonts.nunito(
              color: Colors.blueGrey[600],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blueGrey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blueGrey[600]!),
            ),
            filled: true,
            fillColor: Colors.blueGrey[50],
          ),
          style: GoogleFonts.nunito(
            color: Colors.blueGrey[800],
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Full Name of Guest 2 (Optional)',
            labelStyle: GoogleFonts.nunito(
              color: Colors.blueGrey[600],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blueGrey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blueGrey[600]!),
            ),
            filled: true,
            fillColor: Colors.blueGrey[50],
          ),
          style: GoogleFonts.nunito(
            color: Colors.blueGrey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Select Payment Method',
            labelStyle: GoogleFonts.nunito(
              color: Colors.blueGrey[600],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blueGrey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blueGrey[600]!),
            ),
            filled: true,
            fillColor: Colors.blueGrey[50],
          ),
          items: const [
            DropdownMenuItem(
              value: 'Visa',
              child: Text('Visa'),
            ),
            DropdownMenuItem(
              value: 'MasterCard',
              child: Text('MasterCard'),
            ),
            DropdownMenuItem(
              value: 'PayPal',
              child: Text('PayPal'),
            ),
          ],
          onChanged: (value) {
            // Handle payment method selection
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Card Number',
            labelStyle: GoogleFonts.nunito(
              color: Colors.blueGrey[600],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blueGrey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blueGrey[600]!),
            ),
            filled: true,
            fillColor: Colors.blueGrey[50],
          ),
          style: GoogleFonts.nunito(
            color: Colors.blueGrey[800],
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Security Code',
            labelStyle: GoogleFonts.nunito(
              color: Colors.blueGrey[600],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blueGrey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blueGrey[600]!),
            ),
            filled: true,
            fillColor: Colors.blueGrey[50],
          ),
          style: GoogleFonts.nunito(
            color: Colors.blueGrey[800],
          ),
          obscureText: true,
        ),
      ],
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Booking',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
          ),
        ),
        content: Text(
          'Are you sure you want to confirm this booking?',
          style: GoogleFonts.nunito(
            color: Colors.blueGrey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.nunito(
                color: Colors.blueGrey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Booking Confirmed!',
                    style: GoogleFonts.nunito(),
                  ),
                  backgroundColor: Colors.green[700],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[700],
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Confirm',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}