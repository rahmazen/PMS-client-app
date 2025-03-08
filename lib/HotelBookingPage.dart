import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HotelRoomBookingPage extends StatefulWidget {
  const HotelRoomBookingPage({Key? key}) : super(key: key);

  @override
  _HotelRoomBookingPageState createState() => _HotelRoomBookingPageState();
}

class _HotelRoomBookingPageState extends State<HotelRoomBookingPage> {
  DateTime _checkInDate = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 3));
  int _adultCount = 2;
  int _childrenCount = 0;
  bool _showAllAmenities = false;
  final TextEditingController _specialRequestsController = TextEditingController();

  // Static room data
  final Map<String, dynamic> _roomData = {
    'name': 'Deluxe Room',
    'price': 150.0,
    'description': 'A spacious room with modern amenities, perfect for a comfortable stay.',
    'capacity': 2,
    'size': 30,
    'bedType': 'King',
    'images': [
      'assets/images/background2.jpg',
      'assets/images/background2.jpg',
    ],
  };

  int get _nightsCount {
    return _checkOutDate.difference(_checkInDate).inDays;
  }

  double get _totalPrice {
    return _roomData['price'] * _nightsCount;
  }

  double get _taxesAndFees {
    return _totalPrice * 0.12;
  }

  double get _grandTotal {
    return _totalPrice + _taxesAndFees;
  }

  // Format date as a string
  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context).copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey,
        primary: Colors.blueGrey,
        secondary: Colors.blueGrey[300]!,
      ),
    );

    return Theme(
      data: theme,
      child: Scaffold(

        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room Images Carousel
              CarouselSlider(
                options: CarouselOptions(
                  height: 250,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  autoPlay: true,
                  enableInfiniteScroll: true,
                ),
                items: (_roomData['images'] as List<String>).map<Widget>((image) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),

              // Room Description Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _roomData['name'],
                          style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        Text(
                          '\$${_roomData['price']}/night',
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _roomData['description'],
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.blueGrey[700],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Room Details
                    _buildSectionTitle('Room Details'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildDetailItem(Icons.people, '${_roomData['capacity']} Guests'),
                        SizedBox(width: 4,),
                        _buildDetailItem(Icons.aspect_ratio, '${_roomData['size']} m²'),
                        SizedBox(width: 4,),
                        _buildDetailItem(Icons.king_bed, '${_roomData['bedType']} Bed'),
                      ],
                    ),

                    // Amenities Section
                    const SizedBox(height: 16),
                    _buildSectionTitle('Amenities'),
                    const SizedBox(height: 8),
                    _buildAmenitiesList(),

                    // Booking Details Section
                    const SizedBox(height: 24),
                    _buildSectionTitle('Booking Details'),
                    const SizedBox(height: 16),

                    // Date Selection
                    Row(
                      children: [
                        Expanded(
                          child: _buildDatePicker(
                            'Check-in',
                            _checkInDate,
                                (date) {
                              setState(() {
                                _checkInDate = date;
                                if (_checkOutDate.isBefore(_checkInDate.add(const Duration(days: 1)))) {
                                  _checkOutDate = _checkInDate.add(const Duration(days: 1));
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDatePicker(
                            'Check-out',
                            _checkOutDate,
                                (date) {
                              setState(() {
                                _checkOutDate = date;
                              });
                            },
                            minDate: _checkInDate.add(const Duration(days: 1)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Guests Selection
                    Row(
                      children: [
                        Expanded(
                          child: _buildGuestCounter(
                            'Adults',
                            _adultCount,
                                (value) {
                              setState(() {
                                _adultCount = value;
                              });
                            },
                            1, // Minimum adults
                            2, // Maximum adults
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildGuestCounter(
                            'Children',
                            _childrenCount,
                                (value) {
                              setState(() {
                                _childrenCount = value;
                              });
                            },
                            0, // Minimum children
                            3, // Maximum children
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Special Requests
                    _buildSectionTitle('Special Requests'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _specialRequestsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Let us know if you have any special requests...',
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
                    ),

                    const SizedBox(height: 24),

                    // Price Summary
                    _buildSectionTitle('Price Summary'),
                    const SizedBox(height: 12),
                    _buildPriceSummary(),

                    const SizedBox(height: 32),

                    // Check Out Now Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // Implement checkout logic

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
                          'Check Out Now',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey[800],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding:  EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.blueGrey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.blueGrey[700],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenitiesList() {
    final List<Map<String, dynamic>> amenities = [
      {'icon': Icons.wifi, 'name': 'Free WiFi'},
      {'icon': Icons.ac_unit, 'name': 'Air Conditioning'},
      {'icon': Icons.tv, 'name': 'Smart TV'},
      {'icon': Icons.coffee, 'name': 'Coffee Maker'},
      {'icon': Icons.bathtub, 'name': 'Bathtub'},
      {'icon': Icons.local_laundry_service, 'name': 'Laundry'},
      {'icon': Icons.room_service, 'name': 'Room Service'},
      {'icon': Icons.pool, 'name': 'Swimming Pool Access'},
    ];

    final displayedAmenities = _showAllAmenities
        ? amenities
        : amenities.sublist(0, 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: displayedAmenities.map((amenity) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.blueGrey[50]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    amenity['icon'],
                    size: 16,
                    color: Colors.blueGrey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    amenity['name'],
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: Colors.blueGrey[700],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        if (amenities.length > 4)
          TextButton(
            onPressed: () {
              setState(() {
                _showAllAmenities = !_showAllAmenities;
              });
            },
            child: Text(
              _showAllAmenities ? 'Show Less' : 'Show All Amenities',
              style: GoogleFonts.nunito(
                color: Colors.blueGrey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDatePicker(
      String label,
      DateTime selectedDate,
      Function(DateTime) onDateSelected, {
        DateTime? minDate,
        DateTime? maxDate,
      }) {
    return GestureDetector(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: minDate ?? DateTime.now(),
          lastDate: maxDate ?? DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.blueGrey[700]!,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.blueGrey[900]!,
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blueGrey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.blueGrey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.blueGrey[700],
                ),
                const SizedBox(width: 8),
                Text(
                  formatDate(selectedDate), // Using our custom date format function
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey[800],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestCounter(
      String label,
      int count,
      Function(int) onCountChanged,
      int minCount,
      int maxCount,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blueGrey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.blueGrey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: count > minCount
                    ? () => onCountChanged(count - 1)
                    : null,
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: count > minCount
                      ? Colors.blueGrey[700]
                      : Colors.blueGrey[300],
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(
                count.toString(),
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              IconButton(
                onPressed: count < maxCount
                    ? () => onCountChanged(count + 1)
                    : null,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: count < maxCount
                      ? Colors.blueGrey[700]
                      : Colors.blueGrey[300],
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (label == 'Adults' && count >= maxCount) // Show a warning if the limit is reached
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Maximum of $maxCount adults allowed.',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.red[700],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey[200]!),
      ),
      child: Column(
        children: [
          _buildPriceRow(
            'Room Rate',
            '\$${_roomData['price']} × $_nightsCount night${_nightsCount > 1 ? 's' : ''}',
            '\$${_totalPrice.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          _buildPriceRow(
            'Taxes & Fees',
            '12%',
            '\$${_taxesAndFees.toStringAsFixed(2)}',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(thickness: 1),
          ),
          _buildPriceRow(
            'Total',
            '',
            '\$${_grandTotal.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
      String label,
      String description,
      String amount, {
        bool isTotal = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: isTotal ? 18 : 16,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: Colors.blueGrey[800],
              ),
            ),
            if (description.isNotEmpty)
              Text(
                description,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.blueGrey[600],
                ),
              ),
          ],
        ),
        Text(
          amount,
          style: GoogleFonts.nunito(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? Colors.blueGrey[800] : Colors.blueGrey[700],
          ),
        ),
      ],
    );
  }


}