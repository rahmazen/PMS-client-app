import 'package:clienthotelapp/SignIn.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http ;
import 'RoomListingPage.dart';
import 'ServiceDetailPage.dart';
import 'api.dart';



class ServiceModel {
  final int id;
  final String title;
  final String subtitle;
  final String description;
  final String image;

  ServiceModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.image,
  });



  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['Id'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
    );
  }


}






class HotelHomePage extends StatefulWidget {
const HotelHomePage({Key? key}) : super(key: key);




  @override
  State<HotelHomePage> createState() => _HotelHomePageState();
}

class _HotelHomePageState extends State<HotelHomePage> {


  String _selectedLanguage = 'en'; // Default language

  // Language options with their respective codes and names
  final List<Map<String, dynamic>> _languages = [
    {'code': 'En', 'name': 'Engl', 'flag': 'assets/flags/uk.jfif'},
    {'code': 'Fr', 'name': 'Fr', 'flag': 'assets/flags/fr.jfif'},
    {'code': 'Ar', 'name': 'عربية', 'flag': 'assets/flags/alg.jfif'},
  ];
  List<dynamic> events = [];
  bool isLoading = true;

  List <dynamic> facilities =[];
  @override
  void initState() {
    super.initState();
    fetchEvents();
    fetchFacilities();
  }
  void _openMap(String place) async {
    String googleMapsUrl = Uri.encodeFull("https://www.google.com/maps/search/?api=1&query=$place");
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw "Could not open the map.";
    }
  }

  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    final Uri googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude",
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw "Could not launch $googleMapsUrl";
    }
  }


  Future<void> fetchEvents() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(Uri.parse('${Api.url}/backend/hotel_admin/event/') ,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=utf-8',
        },);

      if (response.statusCode == 200) {
        print(response.body);
        final eventData = json.decode(response.body);
        setState(() {
          events = eventData;
          isLoading = false; 
        });
        print('Events fetched successfully: $eventData');
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to fetch events: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching events: $e');
    }
  }



// Then modify your fetchFacilities function
Future<void> fetchFacilities() async {
  try {
    final response = await http.get(
      Uri.parse('${Api.url}/backend/guest/facility/'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        facilities =json.decode(response.body);
      });

      print('Data: $facilities');
    } else {
      print('Failed: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}



  String formatEventDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('MMMM d, h:mm a').format(date); // Example: March 15, 6:30 PM
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row with Logo and Menu Icon
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // Logo Container
                    Container(
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Container(
                            height: 60,
                            width: 160,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/NovotelLogo1.png'),
                                fit: BoxFit.contain,
                              ),
                            ),

                          ),
                          SizedBox(width: 6),

                        ],
                      ),
                    ),

                    // Menu Icon
                    Column(
                      children: [
                        SizedBox(height: 20,),
                        Row(
                          children: [

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // UK Flag circle
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: AssetImage('assets/images/uk.jfif'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // En text
                                  const Text(
                                    "En",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10,),
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                               /* boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],*/
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  // Navigate to EditProfilePage
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SignInScreen()),
                                  );
                                },
                                child: Center(
                                  child: Icon(
                                    Icons.notifications_active_outlined,
                                    color: Colors.blueGrey[700],
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 10,),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
                SizedBox(height: 20),
              // Welcome
              // Section



              ////// Hotel Image Carousel
               SizedBox(height: 5),
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  viewportFraction: 0.92,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                ),
                items: [1, 2, 3].map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade300,
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: AssetImage('assets/images/hotel_$i.jfif'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.7),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(
                                    i == 1 ? "Welcome to NOVOTEL" :
                                    i == 2 ? "Swimming Pool" :
                                    i == 3 ? "Restaurant" :
                                    i == 4 ? "Spa Retreat" : "Fitness Center",
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              ),

              // Quick Actions Section
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickAction(context ,Icons.hotel, "Rooms", Colors.blueGrey , () =>RoomListingPage()),
                    _buildQuickAction(context ,Icons.restaurant, "Dining", Colors.blueGrey, () =>RoomListingPage()),
                    _buildQuickAction(context ,Icons.spa, "Spa", Colors.blueGrey, () =>RoomListingPage()),
                    _buildQuickAction(context, Icons.nature_people_rounded, "Garden", Colors.blueGrey, () =>RoomListingPage()),
                  ],
                ),
              ),

              // Upcoming Events Section
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Upcoming Events",
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),
                    Text(
                      "View All",
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
        SizedBox(
          height: 190,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : events.isEmpty
              ? Center(child: Text('No events available'))
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return buildEventCard(
                event['name'] ?? 'Unnamed Event',
                formatEventDate(event['date'] ?? ''),
                event['location'] ?? 'No location',
                event['imageUrl'] ?? 'default_event.jpg',
              );
            },
          ),
        ),


              // Places Near You
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Places Near You",
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),
                    Text(
                      "View Map",
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20),
                  children: [
                    GestureDetector(
                      onTap: () => _openGoogleMaps(21.2791, -157.8375), // Waikiki Beach
                      child: _buildNearbyPlaceCard("Beach Club", "0.5 km", Icons.beach_access),
                    ),
      GestureDetector(
        onTap: () => _openGoogleMaps(34.0522, -118.2437), // Los Angeles (example)
        child: _buildNearbyPlaceCard("Shopping Mall", "1.2 km", Icons.shopping_bag),
      ),
      GestureDetector(
        onTap: () => _openGoogleMaps(40.7794, -73.9632), // Metropolitan Museum of Art
        child: _buildNearbyPlaceCard("Art Museum", "2.0 km", Icons.museum),
      ),
      GestureDetector(
        onTap: () => _openGoogleMaps(37.7749, -122.4194), // Golden Gate Park
        child: _buildNearbyPlaceCard("National Park", "5.5 km", Icons.park),
      ), ],
                ),
              ),

              // Special Offers
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blueGrey.shade800,
                        Colors.blueGrey.shade600,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 40,
                        bottom: -40,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      //////////weekend special ////////////
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "WEEKEND SPECIAL",
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "20% Off on Spa & Dining",
                              style: GoogleFonts.nunito(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Book Now",
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Hotel Services
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Our Services",
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildServiceItem("Concierge", Icons.support_agent ,),
                  _buildServiceItem("Wifi", Icons.wifi),
                  _buildServiceItem("Parking", Icons.local_parking),
                  _buildServiceItem("Pool", Icons.pool),
                  _buildServiceItem("Gym", Icons.fitness_center),
                  _buildServiceItem("Spa", Icons.spa),
                  _buildServiceItem("Restaurant", Icons.restaurant),
                ],
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildQuickAction(
      BuildContext context,
      IconData icon,
      String label,
      Color color,
      Widget Function() destination,
      ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination()),
            );
          },
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: color,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildEventCard(String title, String date, String location, String image) {
    return Container(
      width: 210,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              color: Colors.blueGrey.shade300,
              image: DecorationImage(
                image: NetworkImage('$image'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.blueGrey.shade500,
                    ),
                    const SizedBox(width: 5),

                    Text(
                      date,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.blueGrey.shade500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_pin,
                      size: 14,
                      color: Colors.blueGrey.shade500,
                    ),
                    const SizedBox(width: 5),

                    Text(
                      location,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.blueGrey.shade500,
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyPlaceCard(String name, String distance, IconData icon) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: Colors.blueGrey.shade600,
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            distance,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.blueGrey.shade500,
            ),
          ),
        ],
      ),
    );
  }
// In your first page where you have the GridView
// Assuming you already have the facilities list loaded

  Widget _buildServiceItem(String name, IconData icon) {
    return GestureDetector(
        onTap: () {
      // Find the matching facility based on the service name
      Map<String, dynamic>? matchingFacility;

      if (name == "Spa") {
        matchingFacility = facilities.firstWhere(
                (facility) => facility['title'].toString().contains("Spa"),
            orElse: () => facilities.isNotEmpty ? facilities[0] : null
        );
      } else if (name == "Gym" || name == "Fitness Center") {
        matchingFacility = facilities.firstWhere(
                (facility) => facility['title'].toString().contains("Fitness"),
            orElse: () => facilities.isNotEmpty ? facilities[0] : null
        );
      } else if (name == "Pool") {
        matchingFacility = facilities.firstWhere(
                (facility) => facility['title'].toString().contains("Swimming"),
            orElse: () => facilities.isNotEmpty ? facilities[0] : null
        );
      } else {
        // For other services without a direct match, use a default
        matchingFacility =null;
      }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServicesPage(service: matchingFacility),
          ),

        );


  },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.blueGrey.shade600,
                size: 24,               ),             ), ),
          const SizedBox(height: 8),
          Text(             name,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey.shade700,
            ),             textAlign: TextAlign.center,
          ),         ],       ),
    ) ;

  }
}