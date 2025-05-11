import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReservationStorage {
  // Keys for stored data
  static const String _reservationKey = 'stored_reservation';
  static const String _reservationIdKey = 'stored_reservation_id';
  static const String _lastFetchTimeKey = 'last_fetch_time';


  static Future<bool> isReservationExpired() async {
    final reservation = await getReservation();
    if (reservation == null) {
      return false; // No reservation to expire
    }

    try {
      // Parse check-out date from reservation
      final checkOutString = reservation['check_out'];
      final checkOutDate = DateTime.parse(checkOutString);

      // Get the current date (without time)
      final now = DateTime.now();
      final currentDate = DateTime(now.year, now.month, now.day);

      // Reservation is expired if current date is AFTER the check-out date
      return currentDate.isAfter(checkOutDate);
    } catch (e) {
      print('Error checking if reservation expired: $e');
      return false;
    }
  }

// Add this method to check and clear expired reservation
  static Future<void> checkAndClearExpiredReservation() async {
    bool isExpired = await isReservationExpired();
    if (isExpired) {
      print('Reservation expired - clearing stored data');
      await clearReservation();
    }
  }

  // Save reservation data
  static Future<void> saveReservation(Map<String, dynamic> reservation) async {
    final prefs = await SharedPreferences.getInstance();

    // Store the full reservation data as JSON string
    await prefs.setString(_reservationKey, jsonEncode(reservation));

    // Store the reservation ID separately for quick access
    String reservationId = reservation['id']?.toString() ?? '';
    await prefs.setString(_reservationIdKey, reservationId);

    // Store the fetch time
    await prefs.setInt(_lastFetchTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Get stored reservation data
  static Future<Map<String, dynamic>?> getReservation() async {
    final prefs = await SharedPreferences.getInstance();

    final String? reservationJson = prefs.getString(_reservationKey);
    if (reservationJson == null) {
      return null;
    }

    try {
      return jsonDecode(reservationJson) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding reservation data: $e');
      return null;
    }
  }

  // Get stored reservation ID
  static Future<String?> getReservationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_reservationIdKey);
  }

  // Check if we should refresh the data (optional feature)
  // Returns true if data is older than specified duration
  static Future<bool> shouldRefreshData({Duration threshold = const Duration(hours: 2)}) async {
    final prefs = await SharedPreferences.getInstance();

    final int? lastFetchTime = prefs.getInt(_lastFetchTimeKey);
    if (lastFetchTime == null) {
      return true;
    }

    final lastFetch = DateTime.fromMillisecondsSinceEpoch(lastFetchTime);
    final now = DateTime.now();

    return now.difference(lastFetch) > threshold;
  }

  // Clear stored reservation data
  static Future<void> clearReservation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_reservationKey);
    await prefs.remove(_reservationIdKey);
    await prefs.remove(_lastFetchTimeKey);
  }
}