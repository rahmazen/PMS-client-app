import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'ReservationStorage.dart';

import 'package:clienthotelapp/QrScannerPage.dart';
import 'package:clienthotelapp/ReservationStorage.dart';
import 'package:http/http.dart' as http ;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'BasePage.dart';
import 'api.dart';
import 'providers/authProvider.dart'; // Add this import
class ReservationExpirationService {
  static const String _lastCheckDateKey = 'last_expiration_check_date';

  static Future<void> checkDailyExpiration() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastCheckDateStr = prefs.getString(_lastCheckDateKey);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastCheckDateStr == null) {
      // First time checking, save today and check expiration
      await prefs.setString(_lastCheckDateKey, today.toIso8601String());
      await ReservationStorage.checkAndClearExpiredReservation();
      return;
    }

    try {
      final lastCheckDate = DateTime.parse(lastCheckDateStr);
      final lastCheckDay = DateTime(lastCheckDate.year, lastCheckDate.month, lastCheckDate.day);

      // If last check was before today, do another check
      if (today.isAfter(lastCheckDay)) {
        await prefs.setString(_lastCheckDateKey, today.toIso8601String());
        await ReservationStorage.checkAndClearExpiredReservation();
      }
    } catch (e) {
      print('Error parsing last check date: $e');
      // Reset and check anyway
      await prefs.setString(_lastCheckDateKey, today.toIso8601String());
      await ReservationStorage.checkAndClearExpiredReservation();
    }
  }
}


class ClientRoomPage extends StatefulWidget {
  @override
  _ClientRoomPageState createState() => _ClientRoomPageState();
}


class _ClientRoomPageState extends State<ClientRoomPage> {

  // Variables to store room data


  String roomNumber = "";
   String? reservationId ;
  bool isLoading = true;
  List <dynamic> reservation= [] ;
  String meal_plan  = 'RO';
  Future<void>fetchReservation() async{

    final reservation = await ReservationStorage.getReservationId();
    setState(() {
      reservationId =reservation ;
    });
    print('we are in fetch reservation ');
    print('reservation id reteived from reservationstorage is ${reservationId}');
    if (reservationId == null) {

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => QRCodeScanPage()),
        );
      });
      return;
    }
    try {
      final response = await http.get(Uri.parse('${Api.url}/backend/receptionist/ManageReservation/${reservationId}/'));

      print('response of get request ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          final reservation = json.decode(response.body);
          meal_plan =reservation['meal_plan'];
          roomNumber=reservation['room'];
          print(meal_plan);
        });


      } else {
        print('Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  @override
  void initState() {
    super.initState();
    ReservationExpirationService.checkDailyExpiration();
    ReservationStorage.checkAndClearExpiredReservation().then((_) {
      // Then fetch reservation (if not expired)
      fetchReservation();
    });
  }
  bool isCleaningRequested = false;
  bool isDoNotDisturb = false;

  final Map<String, dynamic> service = {
    "serviceID": 43,
    "type": "roomservice",
    "amount": "1800.00",
    "status": "pending",
    "serviceDate": "2025-04-30T10:18:28.396129Z",
    "reservation": 27,
    "assigned_staff": null
  };


  // Get status color based on status text
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Format date to be more readable
  String _formatDate(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(


      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height : 20),
            GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BasePage()),
              ),
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
                          'Standard',
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

            // Room details



            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [

                    const SizedBox(width: 5),
                    SmallToggleSwitch(
                        value: isCleaningRequested,
                        onToggle: (value) {
                          setState(() {
                            isCleaningRequested = value;
                          });
                        },
                        activeColor: Colors.blue[100],
                        icon: Icons.cleaning_services,
                        message : 'requestCleaning',
                        room: roomNumber
                    ),

                    const SizedBox(width: 10),
                    const Text(
                      "Request Cleaning",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Do Not Disturb Toggle
                Row(
                  children: [

                    const SizedBox(width: 5),
                    SmallToggleSwitch(
                        value: isDoNotDisturb,
                        onToggle: (value) {
                          setState(() {
                            isDoNotDisturb = value;
                          });
                        },
                        activeColor: Colors.red[200],
                        icon: Icons.do_not_disturb_on,
                        message : 'doNotDisturb',
                        room: roomNumber
                    ),

                    const SizedBox(width: 10),
                    const Text(
                      "Do Not Disturb",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height : 20) ,
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

  void _showRoomServiceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RoomServiceModal( reservationId: reservationId, meal_plan: meal_plan,),
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
      builder: (context) => MaintenanceServiceModal(roomNumber : roomNumber),
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
  final String? reservationId; // Added to link with reservation
  final String meal_plan ;
  const RoomServiceModal({Key? key, required this.reservationId , required this.meal_plan}) : super(key: key);

  @override
  _RoomServiceModalState createState() => _RoomServiceModalState();
}

class _RoomServiceModalState extends State<RoomServiceModal> {
  List<dynamic> menuItems = [];
  bool isLoading = true;
  bool isSubmitting = false;
  String errorMessage = '';
  TextEditingController instructionsController = TextEditingController();

  // Map to track quantities of each item ordered
  Map<String, int> orderItems = {}; // Using item id as key

  @override
  void initState() {
    super.initState();
    getMenu();
  }

  Future<void> getMenu() async {
    setState(() {
      isLoading = true ;
      errorMessage = '' ;
    });

    try {
      final response = await http.get(Uri.parse('${Api.url}/backend/hotel_admin/menu/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          menuItems = data;
          isLoading = false;
        });
        print('Menu data loaded: ${menuItems.length} items');
      } else {
        setState(() {
          errorMessage = 'Failed to load menu: ${response.statusCode}';
          isLoading = false;
        });
        print('Failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading menu: $e';
        isLoading = false;
      });
      print('Error: $e');
    }
  }

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
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
                : menuItems.isEmpty
                ? Center(child: Text('No menu items available'))
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final itemId = item['id']?.toString() ?? index.toString();

                return DynamicMenuItemCard(
                  item: item,
                  quantity: orderItems[itemId] ?? 0,
                  onIncrement: () {
                    setState(() {
                      orderItems[itemId] = (orderItems[itemId] ?? 0) + 1;
                    });
                  },
                  onDecrement: () {
                    setState(() {
                      if ((orderItems[itemId] ?? 0) > 0) {
                        orderItems[itemId] = orderItems[itemId]! - 1;
                        if (orderItems[itemId] == 0) {
                          orderItems.remove(itemId);
                        }
                      }
                    });
                  },
                );
              },
            ),
          ),

          // Special Instructions - only show if items are selected
          if (orderItems.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: instructionsController,
                decoration: InputDecoration(
                  labelText: 'Special Instructions',
                  hintText: 'Any special requests?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 2,
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

                     (orderItems.length == 0) ?
                     Text(
                    "Add items to your order",
                    style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                    ),
                    ):


    calculateTotal(widget.meal_plan)==0 && calculateTotal(widget.meal_plan)!= null ?
                      Text(
                        "you are covered by meal plan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: Colors.green[400],
                        ),
                      )
                    :
                      Text(
                      "\$${calculateTotal(widget.meal_plan).toStringAsFixed(2)}",


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
                  onPressed: (orderItems.isEmpty || isSubmitting) ? null : () {
                    placeOrder();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isSubmitting
                      ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  )
                      : Text(
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

  double calculateTotal(String meal_plan) {
    double total = 0.0;
    print('Running calculateTotal with meal_plan: $meal_plan');
    bool isCoveredByMealPlan = false ;
    // Get current time
    final DateTime now = DateTime.now();
    final int currentHour = now.hour;
    print('Current hour: $currentHour');

    // Check if current time is within meal period (11:00 - 14:00)
    final bool isMealTime = currentHour >= 11 && currentHour < 14;
    print('Is meal time? $isMealTime');

    // Determine the current meal type based on time of day
    String currentMealType = '';
    if (currentHour >= 7 && currentHour < 10) {
      currentMealType = 'BB'; // breakfast
    } else if (currentHour >= 11 && currentHour < 14) {
      currentMealType = 'HB'; // half board (lunch)
    } else if (currentHour >= 18 && currentHour < 21) {
      currentMealType = 'FB'; // full board (dinner)
    }
    print('Current meal type: $currentMealType');

    // Print meal plan in uppercase for consistency in comparison
    print('Meal plan (uppercase): ${meal_plan.toUpperCase()}');

    orderItems.forEach((itemId, quantity) {
      print('\nProcessing item ID: $itemId, quantity: $quantity');

      // Find the menu item by ID
      final item = menuItems.firstWhere(
              (menuItem) => (menuItem['id']?.toString() ?? '') == itemId,
          orElse: () => menuItems.elementAt(int.tryParse(itemId) ?? 0)
      );

      print('Found menu item: ${item.toString()}');


        // Check if the resident's meal plan covers this meal type
        if (currentMealType.isNotEmpty) {
          print('Current meal type is not empty');
          print('Comparing: $meal_plan == currentMealType($currentMealType): ${meal_plan == currentMealType}');

          if (meal_plan.toUpperCase() == 'AI') {
            isCoveredByMealPlan = true;
            print('Covered by AI plan');
          } else if (meal_plan.toUpperCase() == 'FB' &&
              (currentMealType == 'BB' || currentMealType == 'HB' || currentMealType == 'FB')) {
            // Full board covers breakfast, lunch and dinner
            isCoveredByMealPlan = true;
            print('Covered by FB plan');
          } else if (meal_plan.toUpperCase() == 'HB' &&
              (currentMealType == 'BB' || currentMealType == 'HB')) {
            // Half board covers breakfast and lunch
            isCoveredByMealPlan = true;
            print('Covered by HB plan');
          } else if (meal_plan.toUpperCase() == 'BB' && currentMealType == 'BB') {
            // Bed & breakfast covers only breakfast
            isCoveredByMealPlan = true;
            print('Covered by BB plan');
          } else {
            print('Not covered by meal plan: ${meal_plan.toUpperCase()}');
          }
        } else {
          print('Current meal type is empty (not within meal hours)');
        }


      print('Is covered by meal plan? $isCoveredByMealPlan');

      // Parse the price (handle various formats)
      double price = 0;
      if (!isCoveredByMealPlan && item['price'] != null) {
        if (item['price'] is num) {
          price = (item['price'] as num).toDouble();
        } else if (item['price'] is String) {
          price = double.tryParse(item['price']) ?? 0;
        }
      }

      print('Item price: $price');
      print('Adding to total: ${price * quantity}');
      total += price * quantity;
    });

    print('Final total: $total');
    return total;
  }
  Future<void> placeOrder() async {
    // Don't do anything if no items are selected
    if (orderItems.isEmpty) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      // Prepare the order items
      List<Map<String, dynamic>> items = [];

      orderItems.forEach((itemId, quantity) {
        if (quantity > 0) {
          items.add({
            'menu_item': itemId,
            'quantity': quantity
          });
        }
      });

      // Create the request body
      final requestBody = {
        'reservation': widget.reservationId,
        'items': items,
        'instructions': instructionsController.text,
        'total_amount': calculateTotal(widget.meal_plan)
      };

      // Print the exact JSON data being sent to the API
      print('====================== REQUEST DATA ======================');
      print(const JsonEncoder.withIndent('  ').convert(requestBody));
      print('=========================================================');

      // Send the request
      final response = await http.post(
        Uri.parse('${Api.url}/backend/guest/order/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      // Log response details
      print('====================== RESPONSE DATA =====================');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('=========================================================');

      setState(() {
        isSubmitting = false;
      });

      if (response.statusCode == 201) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Your room service order has been placed successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        // Close the modal
        Navigator.pop(context);
      } else {
        // Show error message with response details
        String errorMsg = "Failed to place order";
        try {
          final data = json.decode(response.body);
          errorMsg = data['error'] ?? errorMsg;
        } catch (e) {
          errorMsg = "Response error: ${response.statusCode}";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });

      print('Exception during order placement: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Widget for displaying menu items dynamically
class DynamicMenuItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const DynamicMenuItemCard({
    Key? key,
    required this.item,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract item properties with null safety
    final String name = item['name']?.toString() ?? 'Unknown Item';

    // Handle price which could be different formats
    double price = 0;
    if (item['price'] != null) {
      if (item['price'] is num) {
        price = (item['price'] as num).toDouble();
      } else if (item['price'] is String) {
        price = double.tryParse(item['price']) ?? 0;
      }
    }

    final String description = item['description']?.toString() ?? 'No description available';

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
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "${price.toStringAsFixed(2)} DZD",
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

// Laundry Service Modal
class LaundryServiceModal extends StatefulWidget {


  @override
  _LaundryServiceModalState createState( ) => _LaundryServiceModalState();
}

class _LaundryServiceModalState extends State<LaundryServiceModal> {
  TimeOfDay? selectedTime;
  String selectedService = 'Wash_Fold';
  int itemCount = 1;
  TextEditingController descriptionController =TextEditingController();
  final Map<String, String> serviceMapping = {
    "Dry Cleaning": "dry_cleaning",
    "Wash and Fold": "wash_fold",
    "Wash and Iron": "wash_iron",
  };
  final List<String> serviceDisplayNames = ["Dry Cleaning", "Wash and Fold", "Wash and Iron"];
  String selectedServiceValue = 'wash_iron';
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
                      itemCount: serviceDisplayNames.length,
                      itemBuilder: (context, index) {
                        final displayName = serviceDisplayNames[index];

                        return RadioListTile<String>(
                          title: Text(displayName),
                          value: displayName,
                          groupValue: selectedService,
                          activeColor: Colors.blueGrey[700],
                          onChanged: (value) {
                            if(value != null) {
                              setState(() {

                                selectedService = value;
                                // Store the corresponding database value
                                selectedServiceValue = serviceMapping[value]!;
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 32),

                  /* Pickup Time
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

                   */
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blueGrey[200]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Items count',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      color: Colors.blueGrey[800],
                                    ),
                                  ),

                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline),
                                    color: Colors.blueGrey[700],
                                    onPressed: itemCount > 1
                                        ? () {
                                      setState(() {
                                        itemCount--;
                                      });
                                    }
                                        : null,
                                  ),
                                  Text(
                                    '$itemCount',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey[900],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add_circle_outline),
                                    color: Colors.blueGrey[700],
                                    onPressed: itemCount < 6
                                        ? () {
                                      setState(() {
                                        itemCount++;
                                      });
                                    }
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                    controller: descriptionController,
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
              onPressed: (selectedService != null)
                  ? () {
                requestLaundry(description :descriptionController.text  , itemCount: itemCount , laundry_type:  selectedServiceValue);
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

  Future<void> requestLaundry({ required String description, required int itemCount, required String laundry_type }) async {

    final reservationId = await ReservationStorage.getReservationId();
    
    try {

      final response = await http.post(
        Uri.parse('${Api.url}/backend/guest/laundry/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'reservationID': reservationId,
          'itemcount': itemCount,
          'description': description,
          'laundry_type': laundry_type
        }),
      );

      if (response.statusCode == 201) {
        print(response.body);
        setState(() {
          Navigator.pop(context);
        });
        // Show a white Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Request submitted successfully !',
              style: TextStyle(
                color: Colors.blueGrey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.white,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            action: SnackBarAction(
              label: 'DISMISS',
              textColor: Colors.blue,
              onPressed: () {},
            ),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        print('Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

}

// Maintenance Service Modal
class MaintenanceServiceModal extends StatefulWidget {

  final String roomNumber;

  const MaintenanceServiceModal({Key? key, required this.roomNumber}) : super(key: key);
  @override
  _MaintenanceServiceModalState createState() => _MaintenanceServiceModalState();
}

class _MaintenanceServiceModalState extends State<MaintenanceServiceModal> {
  String selectedIssue = 'other';
  final List<String> issueTypes = [
    "Plumbing",
    "Electrical",
    "HVAC",
    "Carpentry",
    "General repairs",
    "Other"
  ];
String urgency ='medium' ;
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
                            if (value != null) {
                              setState(() {
                                selectedIssue = value;
                              });
                            }
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
                          groupValue: urgency,
                          activeColor: Colors.blueGrey[700],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                urgency = value;
                              });
                            }

                          },
                        ),
                        RadioListTile<String>(
                          title: Text("Medium - Needs attention soon"),
                          value: "medium",
                          groupValue: urgency,
                          activeColor: Colors.blueGrey[700],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                urgency = value;
                              });
                            }

                          },
                        ),
                        RadioListTile<String>(
                          title: Text("High - Urgent issue"),
                          value: "high",
                          groupValue: urgency,
                          activeColor: Colors.blueGrey[700],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                urgency = value;
                              });
                            }

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
                  requestMaint(description: descriptionController.text ,urgency:  urgency , maintenance_type:selectedIssue );
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

  Future<void> requestMaint({ required String urgency, required String description, required String maintenance_type }) async {

    final authdata = Provider.of<AuthProvider>(context, listen: false).authData;

    try {

      final response = await http.post(
        Uri.parse('${Api.url}/backend/guest/maintenance/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user': authdata?.username,
          'room': widget.roomNumber,
          'urgency': urgency,
          'description': description,
          'maintenance_type': maintenance_type
        }),
      );

      if (response.statusCode == 201) {
        print(response.body);
        setState(() {
          Navigator.pop(context);
        });
        // Show a white Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Request submitted successfully !',
              style: TextStyle(
                color: Colors.blueGrey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.white,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            action: SnackBarAction(
              label: 'DISMISS',
              textColor: Colors.blue,
              onPressed: () {},
            ),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        print('Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

}


class SmallToggleSwitch extends StatefulWidget {
  final bool value;
  final Function(bool) onToggle;
  final Color? activeColor;
  final IconData icon;
  final String message ;
  final String room ;
  const SmallToggleSwitch({
    Key? key,
    required this.value,
    required this.onToggle,
    required this.activeColor,
    required this.icon,
    required this.message,
    required this.room
  }) : super(key: key);

  @override
  State<SmallToggleSwitch> createState() => _SmallToggleSwitchState();
}

Future<void> ToggleBack(bool val, String message, String room) async {
  try {
    final uri = Uri.parse('${Api.url}/backend/guest/toggle/');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'room': room,
        'message': message,
        'value': val.toString().replaceFirst(val.toString()[0], val.toString()[0].toUpperCase()),

      }),
    );

    if (response.statusCode == 200) {
      final event = json.decode(response.body);
      print('Data: $event');
    } else {
      print('Failed: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

class _SmallToggleSwitchState extends State<SmallToggleSwitch> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onToggle(!widget.value);
        ToggleBack(!widget.value , widget.message , widget.room );


      },
      child: Container(
        width: 50, // Much smaller width
        height: 25, // Small height as requested
        decoration: BoxDecoration(
          color: widget.value ? widget.activeColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // No text anymore, just the circle with icon
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(2), // Smaller padding
                child: Container(
                  width: 20, // Smaller circle
                  height: 20, // Smaller circle
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: widget.value ? widget.activeColor : Colors.grey[600],
                      size: 12, // Smaller icon
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


