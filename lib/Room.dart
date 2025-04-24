  class Room {
  final String id;
  final String type;
  final String bedType;
  final List<String> images;
  final String mainImage;
  final String description;
  final double price;
  final List<String> amenities;
  final bool isOccupied;
  final bool doNotDisturb;
  final bool requestCleaning;
  final bool requestMaintenance;

  Room({
    required this.id,
    required this.type,
    required this.bedType,
    required this.images,
    required this.mainImage,
    required this.description,
    required this.price,
    required this.amenities,
    required this.isOccupied,
    required this.doNotDisturb,
    required this.requestCleaning,
    required this.requestMaintenance,
  });

  // Calculate bed count based on bedType string
  int get beds {
    if (bedType.contains('double')) return 1;
    if (bedType.contains('two single')) return 2;
    if (bedType.contains('single')) {
      final regex = RegExp(r'(\d+)\s*single');
      final match = regex.firstMatch(bedType);
      if (match != null && match.groupCount >= 1) {
        return int.tryParse(match.group(1) ?? '1') ?? 1;
      }
    }
    return 1; // Default
  }

  // Calculate capacity based on bed types
  int get capacity {
    int count = 0;
    if (bedType.contains('double')) count += 2;
    if (bedType.contains('single')) {
      final regex = RegExp(r'(\d+)\s*single');
      final match = regex.firstMatch(bedType);
      if (match != null && match.groupCount >= 1) {
        count += int.tryParse(match.group(1) ?? '1') ?? 1;
      } else {
        count += 1;
      }
    }
    return count > 0 ? count : 2; // Default to 2 if calculation fails
  }

  // Factory method to create a Room from API JSON
  factory Room.fromJson(Map<String, dynamic> json) {
    // Extract amenities
    List<String> amenitiesList = [];
    if (json['amenities'] != null) {
      for (var amenity in json['amenities']) {
        if (amenity is List && amenity.length > 1) {
          amenitiesList.add(amenity[1].toString());
        }
      }
    }

    // Extract images
    List<String> imagesList = [];
    String mainImage = '';
    if (json['images'] != null && json['images'].isNotEmpty) {
      for (var image in json['images']) {
        if (image['image'] != null) {
          imagesList.add(image['image'].toString());
          if (mainImage.isEmpty) {
            mainImage = image['image'].toString();
          }
        }
      }
    }

    return Room(
      id: json['roomID']?.toString() ?? '',
      type: json['room_type']?.toString() ?? 'Standard Room',
      bedType: json['bed_type']?.toString() ?? 'Single bed',
      images: imagesList,
      mainImage: mainImage.isNotEmpty ? mainImage : 'assets/images/room_placeholder.jpg',
      description: json['description']?.toString() ?? 'No description available',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      amenities: amenitiesList,
      isOccupied: json['is_occupied'] == true,
      doNotDisturb: json['doNotDisturb'] == true,
      requestCleaning: json['requestCleaning'] == true,
      requestMaintenance: json['requestMaintenance'] == true,
    );
  }
}
