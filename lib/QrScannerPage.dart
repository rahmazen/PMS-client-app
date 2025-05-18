import 'dart:convert';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BasePage.dart';
import 'ReservationStorage.dart';
import 'Services.dart';
import 'api.dart';

class QRCodeScanPage extends StatefulWidget {
  const QRCodeScanPage({Key? key}) : super(key: key);

  @override
  _QRCodeScanPageState createState() => _QRCodeScanPageState();
}

class _QRCodeScanPageState extends State<QRCodeScanPage> {
  final TextEditingController reservationIdController = TextEditingController();
  bool isLoading = false;
  bool isCheckingStorage = true; // Flag for initial storage check
  String? errorMessage;

  // Mobile Scanner controller
  final MobileScannerController _mobileScannerController = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    // Check and clear expired reservation before checking stored reservation
    ReservationStorage.checkAndClearExpiredReservation().then((_) {
      _checkStoredReservation();
    });
  }

  @override
  void dispose() {
    _mobileScannerController.dispose();
    reservationIdController.dispose();
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
  }

  void toggleScanner() {
    setState(() {
      _isScanning = !_isScanning;
    });
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _stopScanning();
        // Process the QR code data
        final String code = barcode.rawValue!;
        print('QR Code detected: $code');
        /////////////////////// Handle reservation access with the scanned code///////////////////////////////////

          final cleanedCode = code.trim().replaceAll('\uFEFF', '');
          final Map<String, dynamic> data = json.decode(cleanedCode);

          print('code decoded  $data');
          final reservationId = data['reservationId'];
          print('reservation id :  $reservationId');
          if (reservationId != null) {
            handleReservationAccess(reservationId.toString());
          } else {
            showErrorMessage('Invalid QR code: missing reservationId');
          }

      }
    }
  }

  Future<void> _checkStoredReservation() async {
    setState(() {
      isCheckingStorage = true;
    });

    try {
      // Get stored reservation
      final reservation = await ReservationStorage.getReservation();

      if (reservation != null) {
        // Check if we should refresh data from API
        final shouldRefresh = await ReservationStorage.shouldRefreshData();

        if (shouldRefresh) {
          // If we need fresh data, get the stored ID and fetch again
          final storedId = await ReservationStorage.getReservationId();
          if (storedId != null && storedId.isNotEmpty) {
            // Auto-fill the input field
            reservationIdController.text = storedId;

            // Fetch fresh data (optional - you can skip this and just use stored data)
            await handleReservationAccess(storedId, checkStoredDataFirst: false);
          }
        } else {
          // Use cached data directly
          final bool hasAccess = checkRoomAccess(reservation);

          if (hasAccess) {
            // Grant access with stored data
            navigateToRoomPage(reservation);
          } else {
            // Access expired based on stored data
            showErrorMessage('Access denied: Your reservation has expired');
          }
        }
      }
    } catch (e) {
      print('Error checking stored reservation: $e');
    } finally {
      setState(() {
        isCheckingStorage = false;
      });
    }
  }

  void handleManualInput() {
    final reservationId = reservationIdController.text.trim();
    if (reservationId.isEmpty) {
      showErrorMessage('Please enter a reservation ID');
      return;
    }
    handleReservationAccess(reservationId);
  }

  Future<void> handleReservationAccess(String reservationId, {bool checkStoredDataFirst = true}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // First check stored data if requested
      if (checkStoredDataFirst) {
        final storedReservation = await ReservationStorage.getReservation();
        final storedId = await ReservationStorage.getReservationId();

        // If we have stored data and it matches the ID
        if (storedReservation != null &&
            storedId != null &&
            storedId == reservationId) {
          // Check if we should refresh data from API
          bool shouldRefresh = await ReservationStorage.shouldRefreshData();

          if (!shouldRefresh) {
            // Use stored data if recent enough
            final bool hasAccess = checkRoomAccess(storedReservation);
            if (hasAccess) {
              navigateToRoomPage(storedReservation);
              return;
            } else {
              showErrorMessage('Access denied: Your reservation has expired');
              return;
            }
          }
          // If we need fresh data, continue to API call
        }
      }

      // Fetch from API if no valid cached data
      final reservation = await fetchReservation(reservationId);

      if (reservation != null) {
        // Store the fetched reservation
        await ReservationStorage.saveReservation({
          ...reservation,
          'id': reservationId, // Ensure ID is included for storage
        });

        final bool hasAccess = checkRoomAccess(reservation);

        if (hasAccess) {
          // Grant access and navigate to room page
          navigateToRoomPage(reservation);
        } else {
          // Deny access - reservation has expired
          showErrorMessage('Access denied: Your reservation has expired');
        }
      } else {
        showErrorMessage('Reservation not found');
      }
    } catch (e) {
      showErrorMessage('Error: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> fetchReservation(String reservationId) async {
    try {
      final response = await http.get(
          Uri.parse('${Api.url}/backend/receptionist/ManageReservation/$reservationId/')
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to fetch reservation: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching reservation: $e');
      throw e;
    }
  }

  // Check if the current date is within the reservation period
  bool checkRoomAccess(Map<String, dynamic> reservation) {
    try {
      // Parse check-out date from reservation
      final checkOutString = reservation['check_out'];
      final checkOutDate = DateTime.parse(checkOutString);

      // Get the current date (without time)
      final now = DateTime.now();
      final currentDate = DateTime(now.year, now.month, now.day);

      // Access is granted if current date is BEFORE or ON the check-out date
      // Access is denied if current date is AFTER the check-out date
      return currentDate.isBefore(checkOutDate) || currentDate.isAtSameMomentAs(checkOutDate);
    } catch (e) {
      print('Error checking room access: $e');
      // Default to denying access if there's an error
      return false;
    }
  }

  void navigateToRoomPage(Map<String, dynamic> reservation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientRoomPage(),
      ),
    );
  }

  void showErrorMessage(String message) {
    setState(() {
      errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isCheckingStorage) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => BasePage()),
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back_ios_rounded, color: Colors.blueGrey[600]),
                    SizedBox(width: 5),
                    Text('Back', style: GoogleFonts.nunito(color: Colors.blueGrey[600], fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // QR Scanner Card
                  Container(
                    width: double.infinity,
                    child: Column(
                      children: [
                        const Text(
                          'Scan QR Code',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'You will receive a QR code when you visit our hotel reservation office.\nIt will help you easily manage your hotel room.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // QR Code Scanner
                        Container(
                          width: 200.0,
                          height: 200.0,
                          /*
                          decoration: BoxDecoration(
                            border: _isScanning ? null : Border.all(
                              color: Colors.blueGrey.shade600,
                              width: 2.0,
                            ),
                          ), */
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              children: [
                                // Show mobile scanner when scanning
                                if (_isScanning)
                                  MobileScanner(
                                    controller: _mobileScannerController,
                                    onDetect: _onDetect,
                                    fit: BoxFit.cover,
                                  ),

                                // Show QR code icon when not scanning
                                if (!_isScanning)
                                  Stack(
                                    children: [
                                      Center(
                                        child: Icon(
                                          Icons.qr_code_2_rounded,
                                          size: 180.0,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      // Corner indicators
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide(color: Colors.blueGrey.shade600, width: 3),
                                              left: BorderSide(color: Colors.blueGrey.shade600, width: 3),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide(color: Colors.blueGrey.shade600, width: 3),
                                              right: BorderSide(color: Colors.blueGrey.shade600, width: 3),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(color: Colors.blueGrey.shade600, width: 3),
                                              left: BorderSide(color: Colors.blueGrey.shade600, width: 3),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(color: Colors.blueGrey.shade600, width: 3),
                                              right: BorderSide(color: Colors.blueGrey.shade600, width: 3),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32.0),

                        // Error message if any
                        if (errorMessage != null)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Scan Button
                        SizedBox(
                          width: double.infinity,
                          height: 50.0,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : toggleScanner,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                              _isScanning ? 'STOP' : 'SCAN',
                              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // OR divider
                  Row(
                    children: const [
                      Expanded(
                        child: Divider(
                          thickness: 1.0,
                          color: Colors.grey,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Reservation ID textfield
                  Container(
                    width: 240,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: reservationIdController,
                      decoration: InputDecoration(
                        hintText: 'Enter Reservation ID',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16.0,
                        ),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.blueGrey.shade600,
                            size: 18.0,
                          ),
                          onPressed: isLoading ? null : handleManualInput,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (_) => handleManualInput(),
                    ),
                  ),
                  SizedBox(height: 150,)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}