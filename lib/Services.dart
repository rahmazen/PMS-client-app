import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Add this import

class RoomAccessService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Save room access details
  Future<void> saveRoomAccess(String roomNumber, String reservationId, DateTime checkoutDate, {String? roomType}) async {
    await _storage.write(key: 'room_number', value: roomNumber);
    await _storage.write(key: 'reservation_id', value: reservationId);
    await _storage.write(key: 'checkout_date', value: checkoutDate.toIso8601String());
    if (roomType != null) {
      await _storage.write(key: 'room_type', value: roomType);
    }
  }

  // Get room details
  Future<Map<String, String>> getRoomDetails() async {
    final roomNumber = await _storage.read(key: 'room_number') ?? '';
    final reservationId = await _storage.read(key: 'reservation_id') ?? '';
    final roomType = await _storage.read(key: 'room_type') ?? 'Standard Room';

    return {
      'roomNumber': roomNumber,
      'reservationId': reservationId,
      'roomType': roomType,
    };
  }

  // Check if access is expired
  Future<bool> isAccessExpired() async {
    final checkoutDateStr = await _storage.read(key: 'checkout_date');
    if (checkoutDateStr == null) return true;

    final checkoutDate = DateTime.parse(checkoutDateStr);
    return DateTime.now().isAfter(checkoutDate);
  }

  // Clear access data
  Future<void> clearAccess() async {
    await _storage.delete(key: 'room_number');
    await _storage.delete(key: 'reservation_id');
    await _storage.delete(key: 'checkout_date');
    await _storage.delete(key: 'room_type');
  }
}

class ClientRoomPage extends StatefulWidget {
  @override
  _ClientRoomPageState createState() => _ClientRoomPageState();
}

class _ClientRoomPageState extends State<ClientRoomPage> {
  final RoomAccessService _roomService = RoomAccessService();

  // Variables to store room data
  String roomNumber = "";
  String roomType = "";
  String reservationId ='';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoomData();
  }

  // Load room data from secure storage
  Future<void> _loadRoomData() async {
    final details = await _roomService.getRoomDetails();

    setState(() {
      roomNumber = details['roomNumber'] ?? "";
      roomType = details['roomType'] ?? "";
      roomType = details['reservationId'] ?? "";
      isLoading = false;
    });
  }

  // Sample data
  //final String roomNumber = "304";
  //final String roomType = "Deluxe Mall View";

  @override
  Widget build(BuildContext context) {
    if (roomNumber.isEmpty) {
      return _buildTestSetupScreen();
    }
    return Scaffold(


      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: [
                  Icon(Icons.arrow_back_ios_rounded, color: Colors.blueGrey[600], ),
                  SizedBox(width:5 ),
                  Text('Back', style: GoogleFonts.nunito(color: Colors.blueGrey[600], fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(height: 15,),
            // Room Information Card
            Container(
              margin: EdgeInsets.only(bottom: 24),
              child: Row(
                children: [
                  // Room number display
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[700],
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        roomNumber,
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Room details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Welcome to your room",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey[400],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          roomType,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.wifi, size: 16, color: Colors.blueGrey[600]),
                            SizedBox(width: 6),
                            Text(
                              "Free Wi-Fi",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey[600],
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.ac_unit, size: 16, color: Colors.blueGrey[600]),
                            SizedBox(width: 6),
                            Text(
                              "Climate Control",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Services Section
            Padding(
              padding: EdgeInsets.only(left: 8, bottom: 16),
              child: Text(
                "Services",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
            ),

            // Service Cards
            ServiceCard(
              icon: Icons.room_service,
              title: "Room Service",
              description: "Order food & beverages directly to your room",
              onTap: () => _showRoomServiceModal(context),
            ),
            SizedBox(height: 16),
            ServiceCard(
              icon: Icons.local_laundry_service,
              title: "Laundry Service",
              description: "Request laundry pickup and cleaning",
              onTap: () => _showLaundryModal(context),
            ),
            SizedBox(height: 16),
            ServiceCard(
              icon: Icons.build,
              title: "Maintenance",
              description: "Report any issues with your room",
              onTap: () => _showMaintenanceModal(context),
            ),
            SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }

  Widget _buildTestSetupScreen() {
    final TextEditingController roomNumberController = TextEditingController();
    final TextEditingController roomTypeController = TextEditingController(text: "Deluxe Mall View");
    final TextEditingController daysController = TextEditingController(text: "3");
    final TextEditingController reservationIdController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Set Test Room Access"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Enter Room Details for Testing",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            SizedBox(height: 24),

            // Room Number Field
            TextField(
              controller: roomNumberController,
              decoration: InputDecoration(
                labelText: "Room Number",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24),

            // Room Number Field
            TextField(
              controller: reservationIdController,
              decoration: InputDecoration(
                labelText: "reservation Number",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),


            // Room Type Field
            TextField(
              controller: roomTypeController,
              decoration: InputDecoration(
                labelText: "Room Type",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Days Until Checkout Field
            TextField(
              controller: daysController,
              decoration: InputDecoration(
                labelText: "Days Until Checkout",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 32),

            // Set Room Access Button
            ElevatedButton(
              onPressed: () async {
                if (roomNumberController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a room number")),
                  );
                  return;
                }

                // Calculate checkout date based on days entered
                int days = int.tryParse(daysController.text) ?? 3;
                DateTime checkoutDate = DateTime.now().add(Duration(days: days));

                // Save room data to secure storage
                await _roomService.saveRoomAccess(
                  roomNumberController.text,
                  reservationIdController.text, // Generate a test reservation ID
                  checkoutDate,
                  roomType: roomTypeController.text,
                );

                // Reload the page with the new data
                _loadRoomData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[700],
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                "Set Room Access",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showRoomServiceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RoomServiceModal(),
    );
  }

  void _showLaundryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LaundryServiceModal(),
    );
  }

  void _showMaintenanceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MaintenanceServiceModal(),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const ServiceCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 36,
              color: Colors.blueGrey[700],
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Room Service Modal
class RoomServiceModal extends StatefulWidget {
  @override
  _RoomServiceModalState createState() => _RoomServiceModalState();
}

class _RoomServiceModalState extends State<RoomServiceModal> {
  final List<MenuItem> menuItems = [
    MenuItem("Continental Breakfast", 18.50, "Pastries, fresh fruit, and coffee"),
    MenuItem("Continental Lunch", 18.50, "Main dish of the day, ceasar salad, and a drink"),
    MenuItem("Continental Dinner", 18.50, "Pasta, fresh fruit, and salad"),
    MenuItem("Classic Burger", 22.00, "Beef patty, lettuce, tomato, cheese"),
    MenuItem("Caesar Salad", 16.00, "Romaine lettuce, croutons, parmesan"),
    MenuItem("Margherita Pizza", 20.00, "Tomato sauce, mozzarella, basil"),
    MenuItem("Grilled Salmon", 32.00, "With seasonal vegetables"),
  ];

  Map<MenuItem, int> orderItems = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Modal Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Room Service Menu",
                  style: TextStyle(
                    color: Colors.blueGrey[700],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.blueGrey[700]),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return MenuItemCard(
                  item: item,
                  quantity: orderItems[item] ?? 0,
                  onIncrement: () {
                    setState(() {
                      orderItems[item] = (orderItems[item] ?? 0) + 1;
                    });
                  },
                  onDecrement: () {
                    setState(() {
                      if ((orderItems[item] ?? 0) > 0) {
                        orderItems[item] = orderItems[item]! - 1;
                      }
                    });
                  },
                );
              },
            ),
          ),

          // Order Summary
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    Text(
                      "\$${calculateTotal().toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: orderItems.isEmpty ? null : () {
                    // Place order logic here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Order placed successfully!")),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Confirm Order",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double calculateTotal() {
    double total = 0;
    orderItems.forEach((item, quantity) {
      total += item.price * quantity;
    });
    return total;
  }
}

// Laundry Service Modal
class LaundryServiceModal extends StatefulWidget {
  @override
  _LaundryServiceModalState createState() => _LaundryServiceModalState();
}

class _LaundryServiceModalState extends State<LaundryServiceModal> {
  TimeOfDay? selectedTime;
  String? selectedService;
  final List<String> services = ["Wash & Fold", "Dry Cleaning", "Wash & Iron"];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Modal Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Laundry Service",
                  style: TextStyle(
                    color: Colors.blueGrey[700],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.blueGrey[700]),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Request laundry pickup from your room",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey[600],
                    ),
                  ),
                  SizedBox(height: 32),

                  // Service Selection
                  Text(
                    "Select Service",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueGrey[200]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        return RadioListTile<String>(
                          title: Text(services[index]),
                          value: services[index],
                          groupValue: selectedService,
                          activeColor: Colors.blueGrey[700],
                          onChanged: (value) {
                            setState(() {
                              selectedService = value;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 32),

                  // Pickup Time
                  Text(
                    "Select Pickup Time",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          selectedTime = time;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueGrey[200]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.blueGrey[600]),
                          SizedBox(width: 16),
                          Text(
                            selectedTime != null
                                ? selectedTime!.format(context)
                                : "Select a time",
                            style: TextStyle(
                              color: selectedTime != null
                                  ? Colors.blueGrey[800]
                                  : Colors.blueGrey[400],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Special Instructions
                  Text(
                    "Special Instructions (Optional)",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Add any special instructions here...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blueGrey[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blueGrey[700]!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Button
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
             // color: Colors.white,

            ),
            child: ElevatedButton(
              onPressed: (selectedService != null && selectedTime != null)
                  ? () {
                // Submit laundry request logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Laundry request submitted!")),
                );
                Navigator.pop(context);
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[700],
                padding: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Submit Request",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// Maintenance Service Modal
class MaintenanceServiceModal extends StatefulWidget {
  @override
  _MaintenanceServiceModalState createState() => _MaintenanceServiceModalState();
}

class _MaintenanceServiceModalState extends State<MaintenanceServiceModal> {
  String? selectedIssue;
  final List<String> issueTypes = [
    "Plumbing",
    "Electrical",
    "HVAC",
    "Carpentry",
    "General repairs",
    "Other"
  ];
String? urgency ;
  @override
  Widget build(BuildContext context) {
    TextEditingController descriptionController =TextEditingController();
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Modal Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Maintenance Request",
                  style: TextStyle(
                    color: Colors.blueGrey[700],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.blueGrey[700]),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Report a maintenance issue in your room",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey[600],
                    ),
                  ),
                  SizedBox(height: 32),

                  // Issue Type Selection
                  Text(
                    "Issue Type",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueGrey[200]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: issueTypes.length,
                      itemBuilder: (context, index) {
                        return RadioListTile<String>(
                          title: Text(issueTypes[index]),
                          value: issueTypes[index],
                          groupValue: selectedIssue,
                          activeColor: Colors.blueGrey[700],
                          onChanged: (value) {
                            setState(() {
                              selectedIssue = value;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 32),

                  // Description
                  Text(
                    "Issue Description",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Describe the issue in detail...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blueGrey[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blueGrey[700]!),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Urgency
                  Text(
                    "Urgency Level",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueGrey[200]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: Text("Low - Not urgent"),
                          value: "low",
                          groupValue: "Medium",
                          activeColor: Colors.blueGrey[700],
                          onChanged: (value) {
                            setState(() {
                              urgency = value ;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Text("Medium - Needs attention soon"),
                          value: "medium",
                          groupValue: "Medium",
                          activeColor: Colors.blueGrey[700],
                          onChanged: (value) {
                            setState(() {
                              urgency = value ;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Text("High - Urgent issue"),
                          value: "high",
                          groupValue: "Medium",
                          activeColor: Colors.blueGrey[700],
                          onChanged: (value) {
                            setState(() {
                               urgency = value ;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Button
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
             // color: Colors.white,

            ),
            child: ElevatedButton(
              onPressed: selectedIssue != null
                  ? () {
                  requestMaint();
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[700],
                padding: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Submit Request",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> requestMaint({

    required String urgency,
    required String description,
    required String maintenance_type
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.example.com/data'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user': "user",
          'room': "room",
          'urgency': urgency,
          'description': description,
          'maintenance_type': maintenance_type
        }),
      );

      if (response.statusCode == 201) {
        // Do something with the data
      } else {
        print('Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }}}
// Room Service Menu Item
class MenuItem {
  final String name;
  final double price;
  final String description;

  MenuItem(this.name, this.price, this.description);
}

// Menu Item Card
class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const MenuItemCard({
    Key? key,
    required this.item,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey[100]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "\$${item.price.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey[700],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueGrey[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove, size: 18),
                  onPressed: quantity > 0 ? onDecrement : null,
                  color: Colors.blueGrey[700],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "$quantity",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, size: 18),
                  onPressed: onIncrement,
                  color: Colors.blueGrey[700],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}