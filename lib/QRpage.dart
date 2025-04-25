import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';


class QRpage extends StatefulWidget {

  @override
  _QRpageState createState() => _QRpageState();
}

class _QRpageState extends State<QRpage> with WidgetsBindingObserver {
  final RoomAccessService _roomService = RoomAccessService();
  bool _hasAccess = false;
  String _roomNumber = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndClearExpiredAccess();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndClearExpiredAccess();
    }
  }

  Future<void> _checkAndClearExpiredAccess() async {
    setState(() {
      _isLoading = true;
    });

    final isExpired = await _roomService.isAccessExpired();
    if (isExpired) {
      await _roomService.clearAccess();
      setState(() {
        _hasAccess = false;
        _roomNumber = '';
      });
    } else {
      final details = await _roomService.getRoomDetails();
      setState(() {
        _hasAccess = details != null;
        _roomNumber = details?['roomNumber'] ?? '';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      body: Center(
        child: _hasAccess
            ? RoomKeyCard(roomNumber: _roomNumber)
            : const Text('No active room access. Please scan a QR code.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QRScannerScreen(
                onQRScanned: (roomData) async {
                  final roomNumber = roomData['roomNumber'] ?? '';
                  final reservationId = roomData['reservationId'] ?? '';
                  final checkoutDateStr = roomData['checkoutDate'];

                  if (roomNumber.isNotEmpty &&
                      reservationId.isNotEmpty &&
                      checkoutDateStr != null) {
                    await _roomService.saveRoomAccess(
                      roomNumber,
                      reservationId,
                      DateTime.parse(checkoutDateStr),
                    );
                    _checkAndClearExpiredAccess();
                  } else {
                    // Show an error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid QR code data'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}

class RoomKeyCard extends StatelessWidget {
  final String roomNumber;

  const RoomKeyCard({Key? key, required this.roomNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.hotel,
            size: 60,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            'Room $roomNumber',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap to unlock',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  final Function(Map<String, String>) onQRScanned;

  const QRScannerScreen({Key? key, required this.onQRScanned}) : super(key: key);

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Room QR Code'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (context, state, child) {
                switch (state as TorchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                }
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.cameraFacingState,
              builder: (context, state, child) {
                switch (state as CameraFacing) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (_isProcessing) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue == null) continue;

                _isProcessing = true;
                _processQRCode(barcode.rawValue!);
                break;
              }
            },
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  void _processQRCode(String data) {
    try {
      // The QR code should contain a JSON with roomNumber, reservationId, and checkoutDate
      final Map<String, dynamic> decodedData = jsonDecode(data);

      // Validate required fields
      if (!decodedData.containsKey('roomNumber') ||
          !decodedData.containsKey('reservationId') ||
          !decodedData.containsKey('checkoutDate')) {
        _showError('Invalid QR code format. Missing required data.');
        return;
      }

      // Validate checkout date
      try {
        final checkoutDate = DateTime.parse(decodedData['checkoutDate']);
        if (checkoutDate.isBefore(DateTime.now())) {
          _showError('This reservation has expired.');
          return;
        }
      } catch (e) {
        _showError('Invalid checkout date format.');
        return;
      }

      // Convert all values to String for storage
      final Map<String, String> roomData = {
        'roomNumber': decodedData['roomNumber'].toString(),
        'reservationId': decodedData['reservationId'].toString(),
        'checkoutDate': decodedData['checkoutDate'].toString(),
      };

      // Return the data to the parent widget
      widget.onQRScanned(roomData);
      Navigator.of(context).pop();

    } catch (e) {
      _showError('Failed to process QR code: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    setState(() {
      _isProcessing = false;
    });
  }
}

class RoomAccessService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Save room access after QR scan
  Future<void> saveRoomAccess(String roomNumber, String reservationId, DateTime checkoutDate) async {
    await _storage.write(key: 'room_number', value: roomNumber);
    await _storage.write(key: 'reservation_id', value: reservationId);
    await _storage.write(key: 'checkout_date', value: checkoutDate.toIso8601String());
  }

  // Check if room access is expired
  Future<bool> isAccessExpired() async {
    final checkoutDateStr = await _storage.read(key: 'checkout_date');
    if (checkoutDateStr == null) return true;

    final checkoutDate = DateTime.parse(checkoutDateStr);
    return DateTime.now().isAfter(checkoutDate);
  }

  // Get room details if access is valid
  Future<Map<String, String>?> getRoomDetails() async {
    if (await isAccessExpired()) {
      return null; // Access expired
    }

    final roomNumber = await _storage.read(key: 'room_number');
    final reservationId = await _storage.read(key: 'reservation_id');

    if (roomNumber == null || reservationId == null) {
      return null;
    }

    return {
      'roomNumber': roomNumber,
      'reservationId': reservationId,
    };
  }

  // Clear on checkout or expiration
  Future<void> clearAccess() async {
    await _storage.delete(key: 'room_number');
    await _storage.delete(key: 'reservation_id');
    await _storage.delete(key: 'checkout_date');
  }
}