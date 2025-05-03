import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class HotelDetailPage extends StatefulWidget {
  const HotelDetailPage({Key? key}) : super(key: key);

  @override
  _HotelDetailPageState createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  int _currentImageIndex = 0;
  bool _showAppBar = true;
  final List<Review> reviews = []; // Your initial reviews
  final TextEditingController _commentController = TextEditingController();

  final List<String> hotelImages = [
    'assets/images/background1.jpg',
    'assets/images/background2.jpg',
    'assets/images/background3.jpg',

  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 250 && _showAppBar) {
      setState(() {
        _showAppBar = false;
      });
    } else if (_scrollController.offset <= 250 && !_showAppBar) {
      setState(() {
        _showAppBar = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 350,
                floating: false,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),

                flexibleSpace: FlexibleSpaceBar(

                  background: Column(
                    children: [
                      SizedBox(height: 56),
                      SizedBox(
                        height: 250,
                        child: Stack(
                          children: [
                            CarouselSlider.builder(
                              itemCount: hotelImages.length,
                              itemBuilder: (context, index, realIndex) {
                                return Container(
                                  margin:  EdgeInsets.all(2),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    image: DecorationImage(
                                      image: NetworkImage(hotelImages[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                height: 190,

                                enlargeCenterPage: true,
                                autoPlay: true,
                                aspectRatio: 10 / 9,
                                autoPlayCurve: Curves.fastOutSlowIn,
                                enableInfiniteScroll: true,
                                autoPlayAnimationDuration: Duration(milliseconds: 800),
                                viewportFraction: 0.8,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentImageIndex = index;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),


                    ],
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: Colors.blueGrey.shade800,
                  unselectedLabelColor: Colors.blueGrey.shade400,
                  indicatorColor: Colors.blueGrey.shade800,
                  dividerColor: Colors.white,
                  tabs: const [
                    Tab(text: 'About'),
                    Tab(text: 'Services'),
                    Tab(text: 'Reviews'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              SingleChildScrollView(
                padding:  EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                     SizedBox(height: 12),
                     Text(
                      'Hi, we’re Novotel — your home away from home. With modern rooms, friendly service, and everything you need right at your fingertips, we’re here to make your stay easy and comfortable. Whether you are traveling for work or play, welcome to a place where you can relax, recharge, and feel right at home.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey.shade700,
                        height: 1.5,
                      ),
                    ),
                     SizedBox(height: 34),
                    //herree

                    // GRID SECTION


                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 15,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Card 1
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Card background
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade400,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),



                               Padding(
                                 padding: EdgeInsets.only(top:16 , left: 16),
                                 child: Text(
                                  'More than \n1000 \nusers',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,

                                    color: Colors.white,
                                  ),
                                                               ),
                               ),


                            Positioned(
                              bottom: 1,
                              //left: -3,
                              right:-69,
                              child: Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),

                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/images/handphone.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.blue[100],
                                        child: const Icon(Icons.diamond, size: 48, color: Colors.blue),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Card 2
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade200,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                             Padding(
                               padding:  EdgeInsets.only(top:16 , left: 16),
                               child: Text(
                                  '3000 bookings\n yearly',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                             ),

                            Positioned(
                              bottom: -1,
                              right: -15,
                              child: Container(
                                width: 145,
                                height: 145,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),

                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/images/girltravel.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.orange[100],
                                        child: const Icon(Icons.shopping_bag, size: 48, color: Colors.orange),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),



                        // Card 3
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top:16 ,left: 16),
                              child: Text(
                                  'Bookers from\nmore than\n50 country',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                            ),

                            Positioned(
                              bottom: 1,
                              right: -16,
                              child: Container(
                                width: 115,
                                height: 115,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),

                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/images/thumbsup.png',
                                    fit: BoxFit.cover,

                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Card 4
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top:16 , left: 16),
                              child: Text(
                                'More than\n1000 positive\nreviews',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -20,
                              right: -5,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),

                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/images/like.png',
                                    fit: BoxFit.cover,

                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // SOCIAL MEDIA (CONTACT US) SECTION
                    const SizedBox(height: 24),
                    const Text(
                      'Contact Us',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Facebook
                              SocialMediaButton(
                                icon: Icons.facebook,
                                color: Colors.blueGrey.shade700,
                                label: 'Facebook',
                                onTap: () {
                                  // Facebook link
                                },
                              ),
                              // Instagram
                              SocialMediaButton(
                                icon: Icons.camera_alt,
                                color: Colors.blueGrey.shade600,
                                label: 'Instagram',
                                onTap: () {
                                  // Instagram link
                                },
                              ),
                              // Twitter/X
                              SocialMediaButton(
                                icon: Icons.tag,
                                color: Colors.blueGrey.shade500,
                                label: 'Twitter',
                                onTap: () {
                                  // Twitter link
                                },
                              ),
                              // LinkedIn
                              SocialMediaButton(
                                icon: Icons.business_center,
                                color: Colors.blueGrey.shade400,
                                label: 'LinkedIn',
                                onTap: () {
                                  // LinkedIn link
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.email,
                                  color: Colors.blueGrey.shade700,
                                  size: 28,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Email Us',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'contact@novotel.com',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blueGrey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.blueGrey.shade400,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Colors.blueGrey.shade700,
                                  size: 28,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Call Us',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '+231 66798660',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blueGrey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.blueGrey.shade400,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),




                  ],
                ),
              ),
             ////////
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Welcome Header
                  Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: NetworkImage('assets/images/novotelrecep.jpg',),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.blueGrey[900]!.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to Luxury',
                              style: TextStyle(
                                color: Colors.blueGrey[50],
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Experience exceptional service and unforgettable moments',
                              style: TextStyle(
                                color: Colors.blueGrey[100],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Services Section
                Text(
                  'Our Services',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Indulge in our premium offerings designed for your comfort',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey[600],
                  ),
                ),
                const SizedBox(height: 16),

                // Featured Services Cards
                _buildFeaturedServiceCard(
                  'Fine Dining',
                  'Experience culinary excellence with our award-winning chefs who blend local ingredients with international techniques.',
                  Icons.restaurant,
                  'assets/images/restaurant.webp',
                ),

                _buildFeaturedServiceCard(
                  'Premium Spa',
                  'Rejuvenate your body and mind with our range of therapeutic treatments in a serene environment.',
                  Icons.spa,
                  'assets/images/spa.jpg',
                ),

                _buildFeaturedServiceCard(
                  'State-of-the-Art Fitness Center',
                  'Maintain your fitness routine with our modern equipment and optional personal training sessions.',
                  Icons.fitness_center,
                  'assets/images/gym.jpg',
                ),

                const SizedBox(height: 24),

                // Room Service Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(
                  children: [
                  Icon(
                  Icons.room_service,
                    color: Colors.blueGrey[800],
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '24/7 Room Service',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Our dedicated staff is available around the clock to ensure your stay is as comfortable as possible. From late-night snacks to early morning breakfast, were always at your service.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey[700],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Amenities Grid
        Text(
          'All Amenities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            _buildAmenityItem(Icons.wifi, 'Free WiFi'),
            _buildAmenityItem(Icons.pool, 'Swimming Pool'),
            _buildAmenityItem(Icons.ac_unit, 'Air Conditioning'),
            _buildAmenityItem(Icons.local_parking, 'Free Parking'),
            _buildAmenityItem(Icons.fitness_center, 'Fitness Center'),
            _buildAmenityItem(Icons.restaurant, 'Restaurant'),
            _buildAmenityItem(Icons.spa, 'Spa Services'),
            _buildAmenityItem(Icons.meeting_room, 'Conference Room'),
          ],
        ),

        const SizedBox(height: 24),

        // Reception Info
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blueGrey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.support_agent,
                color: Colors.blueGrey[50],
                size: 50,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reception & Concierge',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[50],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Our multilingual staff is available 24/7 to assist with any requests, from local recommendations to special arrangements.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey[200],
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                      child: const Text('Contact Reception'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Scenic View Section
        Text(
          'Breathtaking Views',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildViewCard('assets/images/viewone.jpg', 'Night View'),
              _buildViewCard('assets/images/view2.jpg', 'Ocean Night'),
              _buildViewCard('assets/images/view3.jpg', 'Sunset View'),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Footer
        Center(
          child: Column(
            children: [
              Text(
                'Novotel Hotel Chain',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Where luxury meets comfort',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.blueGrey[600],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.facebook),
                    color: Colors.blueGrey[700],
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    color: Colors.blueGrey[700],
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.email),
                    color: Colors.blueGrey[700],
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        ],
      ),
    ),

             ////////////

              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30,),
                      Row(
                        children: [
                           Text(
                            'Reviews',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                           Spacer(),
                          Text(
                            'See all',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                       SizedBox(height: 30),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.blueGrey.shade200),
                        ),
                        child: Row(
                          children: [
                            // Profile picture placeholder
                            Container(
                              margin: const EdgeInsets.only(left: 12),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Icon(
                                  Icons.person,
                                  size: 18,
                                  color: Colors.blueGrey.shade50,
                                ),
                              ),
                            ),

                            // Comment text field
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                decoration: InputDecoration(
                                  hintText: 'Write your Review...',
                                  hintStyle: TextStyle(
                                    color: Colors.blueGrey.shade400,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),
                            ),

                            // Action icons
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.emoji_emotions_outlined,
                                    color: Colors.blueGrey.shade400,
                                    size: 20,
                                  ),
                                  onPressed: () {},
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  splashRadius: 20,
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    Icons.attach_file,
                                    color: Colors.blueGrey.shade400,
                                    size: 20,
                                  ),
                                  onPressed: () {},
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  splashRadius: 20,
                                ),
                                 SizedBox(width: 8),

                                Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.arrow_upward,
                                      color: Colors.blueGrey.shade600,
                                      size: 14,
                                    ),
                                    onPressed: () {
                                      if (_commentController.text.isNotEmpty) {
                                        setState(() {
                                          reviews.add(
                                            Review(
                                              name: "You", // Default name since no name field
                                              date: '${_getCurrentMonth()} ${_getCurrentYear()}',
                                              rating: 5.0, // Default 5-star rating
                                              comment: _commentController.text,
                                            ),
                                          );
                                          // Clear comment field
                                          _commentController.clear();
                                        });
                                      }
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    splashRadius: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Existing reviews
                      buildReviewItem(
                          'Rahma Zen',
                          'March 2025',
                          5.0,
                          'This place was amazing! The location is perfect and the room was clean and comfortable. Would definitely stay here again.'
                      ),
                      buildReviewItem(
                          'Sarah Johnson',
                          'April 2025',
                          4.5,
                          'The location is amazing, with stunning views of the city. Staff was very friendly and helpful. Rooms were clean and comfortable.'
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmenityItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.blueGrey.shade700),
            ),
          ),
        ],
      ),
    );
  }


}

class SocialMediaButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const SocialMediaButton({
    Key? key,
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
// Review Model
class Review {
  final String name;
  final String date;
  final double rating;
  final String comment;

  Review({
    required this.name,
    required this.date,
    required this.rating,
    required this.comment,
  });
}


String _getCurrentMonth() {
  final months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return months[DateTime.now().month - 1];
}

String _getCurrentYear() {
  return DateTime.now().year.toString();
}


Widget buildReviewItem(String name, String date, double rating, String comment) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.blueGrey.shade100),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.blueGrey.shade800,
              ),
            ),
            Text(
              date,
              style: TextStyle(
                color: Colors.blueGrey.shade400,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Display star rating
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating.floor()
                  ? Icons.star_rounded
                  : (index < rating ? Icons.star_half_rounded : Icons.star_outline_rounded),
              color: Colors.amber,
              size: 18,
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          comment,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: Colors.blueGrey.shade700,
          ),
        ),
      ],
    ),
  );
}



Widget _buildFeaturedServiceCard(
    String title,
    String description,
    IconData icon,
    String imageUrl,
    ) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.blueGrey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Image.network(
            imageUrl,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.blueGrey[700]),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey[600],
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: Colors.blueGrey[700],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Learn More'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}



// Add these helper methods to your class:

Widget _buildAmenityItem(IconData icon, String title) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.blueGrey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey[700], size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.blueGrey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}



Widget _buildViewCard(String imageUrl, String viewName) {
  return Container(
    width: 300,
    margin: const EdgeInsets.only(right: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      image: DecorationImage(
        image: NetworkImage(imageUrl),
        fit: BoxFit.cover,
      ),
    ),
    child: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          left: 12,
          child: Text(
            viewName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
