import '../models/cleaner_profile.dart' as cp;
import '../models/cleaner_booking.dart';
import '../models/cleaner_stats.dart';
import '../models/customer_review.dart';

class CleanerService {

  // Simulated API calls - in real app these would be HTTP requests
  
  Future<cp.CleanerProfile?> getCleanerProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock data - in real app this would come from API
    return cp.CleanerProfile(
      id: '1',
      name: 'Rita Shrestha',
      profileImageUrl: 'https://example.com/profile.jpg',
      rating: 4.9,
      reviewCount: 230,
      distance: 2.5,
      hourlyRate: 400,
      services: ['Deep Cleaning', 'Standard Cleaning', 'Move-in/out'],
      isVerified: true,
      isAvailable: true,
      isTopRated: true,
      bio: 'Professional cleaner with 3+ years of experience.',
      experienceYears: 3,
      certifications: ['Certified Professional Cleaner'],
      phoneNumber: '+977 9812345678',
      location: {
        'address': 'Baneshwor, Kathmandu',
        'latitude': 27.695,
        'longitude': 85.335,
      },
    );
  }

  Future<CleanerBooking?> getNextBooking() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Mock data - in real app this would come from API
    return CleanerBooking(
      id: '1203',
      customerName: 'Pratikshya Thapa',
      customerPhone: '+977 9876543210',
      serviceName: 'Deep Cleaning',
      addOns: ['Kitchen Clean'],
      timeSlot: '10:00 AM - 1:00 PM',
      duration: '3 hrs',
      address: 'Baneshwor, Kathmandu',
      status: 'Confirmed',
      price: 1200,
      bookingDate: DateTime.now(),
      serviceDate: DateTime.now().add(const Duration(hours: 2)),
      paymentStatus: 'Paid',
      specialInstructions: 'Please focus on kitchen area',
    );
  }

  Future<CleanerStats> getTodayStats() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Mock data - in real app this would come from API
    return CleanerStats(
      todayEarnings: 2400,
      jobsCompleted: 3,
      hoursWorked: 6,
      averageRating: 4.8,
      totalBookings: 245,
      completedBookings: 238,
      cancelledBookings: 5,
      lastUpdated: DateTime.now(),
    );
  }

  Future<Map<String, dynamic>> getWeeklyPerformance() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Mock data - in real app this would come from API
    return {
      'earnings': [1200, 2400, 1800, 0, 2200, 2600, 1900],
      'days': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      'completion_rate': 98,
      'average_rating': 4.9,
      'cancel_rate': 1,
    };
  }

  Future<List<CleanerBooking>> getTodayBookings() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Mock data - in real app this would come from API
    return [
      CleanerBooking(
        id: '1203',
        customerName: 'Pratikshya Thapa',
        customerPhone: '+977 9876543210',
        serviceName: 'Deep Cleaning',
        addOns: [],
        timeSlot: '10:00 AM - 1:00 PM',
        duration: '3 hrs',
        address: 'Baneshwor, Kathmandu',
        status: 'Upcoming',
        price: 1200,
        bookingDate: DateTime.now(),
        serviceDate: DateTime.now().add(const Duration(hours: 2)),
        paymentStatus: 'Paid',
        specialInstructions: '',
      ),
      CleanerBooking(
        id: '1204',
        customerName: 'Aayush Poudel',
        customerPhone: '+977 9812345678',
        serviceName: 'Standard Cleaning',
        addOns: [],
        timeSlot: '2:00 PM - 4:00 PM',
        duration: '2 hrs',
        address: 'Lalitpur, Nepal',
        status: 'In Progress',
        price: 800,
        bookingDate: DateTime.now(),
        serviceDate: DateTime.now().add(const Duration(hours: 6)),
        paymentStatus: 'Paid',
        specialInstructions: '',
      ),
    ];
  }

  Future<List<CustomerReview>> getRecentReviews() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Mock data - in real app this would come from API
    return [
      CustomerReview(
        id: '1',
        customerName: 'Pratikshya Thapa',
        rating: 5,
        reviewText: 'Rita was so professional and kind! The cleaning was thorough and she paid attention to every detail.',
        location: 'Baneshwor, Kathmandu',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        serviceType: 'Deep Cleaning',
        isVerified: true,
      ),
      CustomerReview(
        id: '2',
        customerName: 'Aayush Poudel',
        rating: 4,
        reviewText: 'Good service, quick response. Would definitely book again.',
        location: 'Lalitpur, Nepal',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        serviceType: 'Standard Cleaning',
        isVerified: true,
      ),
      CustomerReview(
        id: '3',
        customerName: 'Sita Sharma',
        rating: 5,
        reviewText: 'Excellent work! Very satisfied with the cleaning quality.',
        location: 'Kathmandu, Nepal',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        serviceType: 'Move-in/out',
        isVerified: true,
      ),
    ];
  }

  Future<int> getNotificationCount() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Mock data - in real app this would come from API
    return 3;
  }

  Future<bool> updateAvailability(bool isAvailable) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock API call - in real app this would update backend
    // For demo purposes, always return success
    return true;
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    // This would be a single API call in real app that returns all dashboard data
    await Future.delayed(const Duration(milliseconds: 800));
    
    return {
      'profile': await getCleanerProfile(),
      'next_booking': await getNextBooking(),
      'today_stats': await getTodayStats(),
      'weekly_performance': await getWeeklyPerformance(),
      'today_bookings': await getTodayBookings(),
      'recent_reviews': await getRecentReviews(),
      'notification_count': await getNotificationCount(),
    };
  }

  // Analytics methods
  Future<Map<String, dynamic>> getEarningsAnalytics({
    String period = 'weekly',
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    return {
      'total_earnings': 15600,
      'this_period': 2400,
      'last_period': 2100,
      'growth_percentage': 14.3,
      'chart_data': [1200, 1800, 2400, 1600, 2200, 2600, 1900],
    };
  }

  Future<List<CleanerBooking>> getBookingHistory({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock paginated data
    return List.generate(limit, (index) {
      return CleanerBooking(
        id: '${1000 + index}',
        customerName: 'Customer ${index + 1}',
        customerPhone: '+977 98123456${index.toString().padLeft(2, '0')}',
        serviceName: ['Deep Cleaning', 'Standard Cleaning', 'Move-in/out'][index % 3],
        addOns: [],
        timeSlot: '${9 + (index % 8)}:00 AM - ${11 + (index % 8)}:00 AM',
        duration: '${2 + (index % 3)} hrs',
        address: 'Address ${index + 1}',
        status: status ?? ['Completed', 'Cancelled', 'Upcoming'][index % 3],
        price: 800 + (index % 5) * 200,
        bookingDate: DateTime.now().subtract(Duration(days: index)),
        serviceDate: DateTime.now().subtract(Duration(days: index - 1)),
        paymentStatus: 'Paid',
        specialInstructions: '',
      );
    });
  }
}