import 'package:clienthotelapp/SignIn.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HotelHomePage extends StatelessWidget {
  const HotelHomePage({Key? key}) : super(key: key);

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
                          SizedBox(width: 9),
                          Container(
                            height: 50,
                            width: 150,
                          decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/NovotelLogo.png'),
                            fit: BoxFit.contain,
                          ),
                          ),

                          ),
                           SizedBox(width: 6),

                        ],
                      ),
                    ),

                    // Menu Icon
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
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
                            Icons.menu,
                            color: Colors.blueGrey.shade800,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                SizedBox(height: 20,),
              // Welcome
              // Section



              // Hotel Image Carousel
               SizedBox(height: 5),
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  viewportFraction: 0.92,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                ),
                items: [1, 2, 3, 4, 5].map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade300,
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: AssetImage('assets/images/hotel_$i.jpg'),
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
                                    i == 1 ? "Luxury Suite" :
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
                    _buildQuickAction(Icons.hotel, "Rooms", Colors.blueGrey),
                    _buildQuickAction(Icons.restaurant, "Dining", Colors.blueGrey),
                    _buildQuickAction(Icons.spa, "Spa", Colors.blueGrey),
                    _buildQuickAction(Icons.nature_people_rounded, "Garden", Colors.blueGrey),
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
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20),
                  children: [
                    _buildEventCard(
                      "Chocolate Tasting",
                      "March 10, 7:00 PM",
                      "Explore premium chocolates with our chefs",
                      "wine_tasting.jpg",
                    ),
                    _buildEventCard(
                      "Live Jazz Night",
                      "March 15, 8:30 PM",
                      "Enjoy soothing jazz in our lounge",
                      "jazz_night.jpg",
                    ),
                    _buildEventCard(
                      "Cooking Class",
                      "March 20, 4:00 PM",
                      "Learn to cook with our chef",
                      "cooking_class.jpg",
                    ),
                  ],
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
                    _buildNearbyPlaceCard("Beach Club", "0.5 km", Icons.beach_access),
                    _buildNearbyPlaceCard("Shopping Mall", "1.2 km", Icons.shopping_bag),
                    _buildNearbyPlaceCard("Art Museum", "2.0 km", Icons.museum),
                    _buildNearbyPlaceCard("National Park", "5.5 km", Icons.park),
                  ],
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
                  _buildServiceItem("Room Service", Icons.room_service),
                  _buildServiceItem("Concierge", Icons.support_agent),
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

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return Column(
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
    );
  }

  Widget _buildEventCard(String title, String date, String description, String image) {
    return Container(
      width: 280,
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
            height: 110,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              color: Colors.blueGrey.shade300,
              image: DecorationImage(
                image: AssetImage('assets/images/$image'),
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

  Widget _buildServiceItem(String name, IconData icon) {
    return Column(
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
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.blueGrey.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}