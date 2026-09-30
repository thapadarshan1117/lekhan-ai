import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/booking.dart';

class BookingService extends ChangeNotifier {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Booking> get bookings => List.unmodifiable(_bookings);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Mock data for demo
  static List<Booking> get _mockBookings => [
    Booking(
      id: '1',
      customerId: 'user123',
      cleanerId: 'cleaner1',
      cleaner: const CleanerProfile(
        id: 'cleaner1',
        name: 'Rita Sharma',
        profilePicture: 'https://media.istockphoto.com/id/1350701180/photo/woman-cleaning-floor-with-mop.jpg?s=612x612&w=0&k=20&c=xZBxsNd-qIFKOcyMywRGIV2u9bp-HuWZSAk_OaWwzKc=',
        rating: 4.8,
        reviewCount: 127,
        phoneNumber: '+977-9841234567',
      ),
      serviceType: ServiceType.standardCleaning,
      serviceDuration: '2 hours',
      scheduledDateTime: DateTime.now().add(const Duration(hours: 2)),
      addressId: 'addr1',
      address: SavedAddress(
        id: 'addr1',
        name: 'Home',
        fullAddress: 'Baneshwor, Kathmandu 44600, Nepal',
        latitude: 27.6915,
        longitude: 85.3443,
        apartment: 'Flat 2B',
        landmark: 'Near City Mall',
        isDefault: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      status: BookingStatus.enRoute,
      estimatedAmount: 1500.0,
      paymentStatus: PaymentStatus.paid,
      specialInstructions: 'Please focus on the kitchen and bathroom',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      progressTimeline: ['Booking Confirmed', 'Cleaner Assigned', 'En Route'],
      trackingId: 'TRACK123',
    ),
    Booking(
      id: '2',
      customerId: 'user123',
      cleanerId: 'cleaner2',
      cleaner: const CleanerProfile(
        id: 'cleaner2',
        name: 'Sita Gurung',
        profilePicture: 'https://media.istockphoto.com/id/1350701180/photo/woman-cleaning-floor-with-mop.jpg?s=612x612&w=0&k=20&c=xZBxsNd-qIFKOcyMywRGIV2u9bp-HuWZSAk_OaWwzKc=',
        rating: 4.9,
        reviewCount: 89,
        phoneNumber: '+977-9851234567',
      ),
      serviceType: ServiceType.deepCleaning,
      serviceDuration: '4 hours',
      scheduledDateTime: DateTime.now().add(const Duration(days: 2)),
      addressId: 'addr2',
      address: SavedAddress(
        id: 'addr2',
        name: 'Office',
        fullAddress: 'Thamel, Kathmandu 44600, Nepal',
        latitude: 27.7172,
        longitude: 85.3240,
        landmark: 'Above Pizza Hut',
        isDefault: false,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      status: BookingStatus.scheduled,
      estimatedAmount: 3000.0,
      paymentStatus: PaymentStatus.pending,
      specialInstructions: 'Deep clean all rooms, especially carpets',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      progressTimeline: ['Booking Confirmed', 'Cleaner Assigned'],
    ),
    Booking(
      id: '3',
      customerId: 'user123',
      cleanerId: 'cleaner3',
      cleaner: const CleanerProfile(
        id: 'cleaner3',
        name: 'Maya Thapa',
        profilePicture: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
        rating: 4.7,
        reviewCount: 156,
        phoneNumber: '+977-9861234567',
      ),
      serviceType: ServiceType.standardCleaning,
      serviceDuration: '2 hours',
      scheduledDateTime: DateTime.now().subtract(const Duration(days: 5)),
      addressId: 'addr1',
      address: SavedAddress(
        id: 'addr1',
        name: 'Home',
        fullAddress: 'Baneshwor, Kathmandu 44600, Nepal',
        latitude: 27.6915,
        longitude: 85.3443,
        apartment: 'Flat 2B',
        landmark: 'Near City Mall',
        isDefault: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      status: BookingStatus.completed,
      estimatedAmount: 1500.0,
      finalAmount: 1500.0,
      paymentStatus: PaymentStatus.paid,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      completedAt: DateTime.now().subtract(const Duration(days: 5, hours: 2)),
      progressTimeline: ['Booking Confirmed', 'Cleaner Assigned', 'En Route', 'In Progress', 'Completed'],
      invoiceUrl: 'https://example.com/invoice/3.pdf',
      review: BookingReview(
        id: 'rev1',
        bookingId: '3',
        rating: 5,
        comment: 'Excellent service! Very thorough and professional.',
        photos: [],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ),
  ];

  // Fetch user bookings
  Future<List<Booking>> fetchUserBookings() async {
    _setLoading(true);
    _error = null;

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, this would be an HTTP request
      // final response = await http.get('/api/bookings?userId=$userId');
      // final bookings = (response.data as List).map((json) => Booking.fromJson(json)).toList();
      
      _bookings = _mockBookings;
      notifyListeners();
      return _bookings;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId, String reason) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // In a real app: POST /api/bookings/:id/cancel
      
      final bookingIndex = _bookings.indexWhere((b) => b.id == bookingId);
      if (bookingIndex != -1) {
        // Update the booking status
        final booking = _bookings[bookingIndex];
        final updatedBooking = Booking(
          id: booking.id,
          customerId: booking.customerId,
          cleanerId: booking.cleanerId,
          cleaner: booking.cleaner,
          serviceType: booking.serviceType,
          serviceDuration: booking.serviceDuration,
          scheduledDateTime: booking.scheduledDateTime,
          addressId: booking.addressId,
          address: booking.address,
          status: BookingStatus.cancelled,
          estimatedAmount: booking.estimatedAmount,
          finalAmount: booking.finalAmount,
          paymentStatus: PaymentStatus.refunded,
          specialInstructions: booking.specialInstructions,
          createdAt: booking.createdAt,
          completedAt: booking.completedAt,
          review: booking.review,
          progressTimeline: [...booking.progressTimeline, 'Cancelled by Customer'],
          invoiceUrl: booking.invoiceUrl,
          trackingId: booking.trackingId,
        );
        
        _bookings[bookingIndex] = updatedBooking;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Approve booking completion
  Future<void> approveBooking(String bookingId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // In a real app: POST /api/bookings/:id/approve
      
      final bookingIndex = _bookings.indexWhere((b) => b.id == bookingId);
      if (bookingIndex != -1) {
        final booking = _bookings[bookingIndex];
        final updatedBooking = Booking(
          id: booking.id,
          customerId: booking.customerId,
          cleanerId: booking.cleanerId,
          cleaner: booking.cleaner,
          serviceType: booking.serviceType,
          serviceDuration: booking.serviceDuration,
          scheduledDateTime: booking.scheduledDateTime,
          addressId: booking.addressId,
          address: booking.address,
          status: booking.status,
          estimatedAmount: booking.estimatedAmount,
          finalAmount: booking.estimatedAmount,
          paymentStatus: PaymentStatus.paid,
          specialInstructions: booking.specialInstructions,
          createdAt: booking.createdAt,
          completedAt: booking.completedAt,
          review: booking.review,
          progressTimeline: [...booking.progressTimeline, 'Approved by Customer'],
          invoiceUrl: booking.invoiceUrl,
          trackingId: booking.trackingId,
        );
        
        _bookings[bookingIndex] = updatedBooking;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Submit review
  Future<void> submitReview(String bookingId, int rating, String? comment, List<String> photos) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // In a real app: POST /api/bookings/:id/review
      
      final bookingIndex = _bookings.indexWhere((b) => b.id == bookingId);
      if (bookingIndex != -1) {
        final booking = _bookings[bookingIndex];
        final review = BookingReview(
          id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
          bookingId: bookingId,
          rating: rating,
          comment: comment,
          photos: photos,
          createdAt: DateTime.now(),
        );
        
        final updatedBooking = Booking(
          id: booking.id,
          customerId: booking.customerId,
          cleanerId: booking.cleanerId,
          cleaner: booking.cleaner,
          serviceType: booking.serviceType,
          serviceDuration: booking.serviceDuration,
          scheduledDateTime: booking.scheduledDateTime,
          addressId: booking.addressId,
          address: booking.address,
          status: booking.status,
          estimatedAmount: booking.estimatedAmount,
          finalAmount: booking.finalAmount,
          paymentStatus: booking.paymentStatus,
          specialInstructions: booking.specialInstructions,
          createdAt: booking.createdAt,
          completedAt: booking.completedAt,
          review: review,
          progressTimeline: [...booking.progressTimeline, 'Review Submitted'],
          invoiceUrl: booking.invoiceUrl,
          trackingId: booking.trackingId,
        );
        
        _bookings[bookingIndex] = updatedBooking;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Raise dispute
  Future<void> raiseDispute(String bookingId, String reason) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // In a real app: POST /api/bookings/:id/dispute
      
      final bookingIndex = _bookings.indexWhere((b) => b.id == bookingId);
      if (bookingIndex != -1) {
        final booking = _bookings[bookingIndex];
        final updatedBooking = Booking(
          id: booking.id,
          customerId: booking.customerId,
          cleanerId: booking.cleanerId,
          cleaner: booking.cleaner,
          serviceType: booking.serviceType,
          serviceDuration: booking.serviceDuration,
          scheduledDateTime: booking.scheduledDateTime,
          addressId: booking.addressId,
          address: booking.address,
          status: BookingStatus.disputed,
          estimatedAmount: booking.estimatedAmount,
          finalAmount: booking.finalAmount,
          paymentStatus: PaymentStatus.disputed,
          specialInstructions: booking.specialInstructions,
          createdAt: booking.createdAt,
          completedAt: booking.completedAt,
          review: booking.review,
          progressTimeline: [...booking.progressTimeline, 'Dispute Raised'],
          invoiceUrl: booking.invoiceUrl,
          trackingId: booking.trackingId,
        );
        
        _bookings[bookingIndex] = updatedBooking;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}