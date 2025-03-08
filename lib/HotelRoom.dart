class HotelRoom {
  final String name;
  final String description;
  final double price;
  final List<String> amenities;
  final List<String> imageUrls;
  final int maxOccupancy;

  HotelRoom({
    required this.name,
    required this.description,
    required this.price,
    required this.amenities,
    required this.imageUrls,
    required this.maxOccupancy,
  });
}
