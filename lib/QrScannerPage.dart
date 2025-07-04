import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'Services.dart';

class QRCodeScanPage extends StatefulWidget {
  const QRCodeScanPage({Key? key}) : super(key: key);

  @override
  _QRCodeScanPageState createState() => _QRCodeScanPageState();
}

class _QRCodeScanPageState extends State<QRCodeScanPage> {
  final TextEditingController _reservationIdController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool _isScanning = false;

  @override
  void dispose() {
    _reservationIdController.dispose();
    _scannerController.dispose();
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

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _stopScanning();
        // Process the QR code data
        final String code = barcode.rawValue!;
        print('QR Code detected: $code');

        // Navigate to the room page with the scanned code
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ClientRoomPage()),
        );
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // QR Scanner Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(23),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Scan QR Code',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'You will receive a QR code when you visit our hotel reservation office.\nIt will help you easily manage your hotel room.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 24),
                    // QR Code Scanner Preview
                    Container(
                      width: 200.0,
                      height: 200.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blueGrey.shade600,
                          width: 2.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            _isScanning
                                ? MobileScanner(
                              controller: _scannerController,
                              onDetect: _onDetect,
                              fit: BoxFit.cover,
                            )
                                : Container(),
                            if (!_isScanning)
                              Stack(
                                children: [
                                  // QR code icon when not scanning
                                  Center(
                                    child: Icon(
                                      Icons.qr_code_2_rounded,
                                      size: 150.0,
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
                    // Scan Button
                    SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: _isScanning ? _stopScanning : _startScanning,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        child: Text(
                          _isScanning ? 'STOP' : 'SCAN',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // or divider
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
              // reservationid textfield
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
                  controller: _reservationIdController,
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ClientRoomPage()),
                        );
                      },
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ClientRoomPage()),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}