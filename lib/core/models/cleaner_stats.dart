class CleanerStats {
  final int todayEarnings;
  final int jobsCompleted;
  final int hoursWorked;
  final double averageRating;
  final int totalBookings;
  final int completedBookings;
  final int cancelledBookings;
  final DateTime lastUpdated;

  CleanerStats({
    required this.todayEarnings,
    required this.jobsCompleted,
    required this.hoursWorked,
    required this.averageRating,
    required this.totalBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.lastUpdated,
  });

  factory CleanerStats.fromJson(Map<String, dynamic> json) {
    return CleanerStats(
      todayEarnings: json['today_earnings'] ?? 0,
      jobsCompleted: json['jobs_completed'] ?? 0,
      hoursWorked: json['hours_worked'] ?? 0,
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      totalBookings: json['total_bookings'] ?? 0,
      completedBookings: json['completed_bookings'] ?? 0,
      cancelledBookings: json['cancelled_bookings'] ?? 0,
      lastUpdated: DateTime.parse(json['last_updated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today_earnings': todayEarnings,
      'jobs_completed': jobsCompleted,
      'hours_worked': hoursWorked,
      'average_rating': averageRating,
      'total_bookings': totalBookings,
      'completed_bookings': completedBookings,
      'cancelled_bookings': cancelledBookings,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  double get completionRate {
    if (totalBookings == 0) return 0.0;
    return (completedBookings / totalBookings) * 100;
  }

  double get cancellationRate {
    if (totalBookings == 0) return 0.0;
    return (cancelledBookings / totalBookings) * 100;
  }

  CleanerStats copyWith({
    int? todayEarnings,
    int? jobsCompleted,
    int? hoursWorked,
    double? averageRating,
    int? totalBookings,
    int? completedBookings,
    int? cancelledBookings,
    DateTime? lastUpdated,
  }) {
    return CleanerStats(
      todayEarnings: todayEarnings ?? this.todayEarnings,
      jobsCompleted: jobsCompleted ?? this.jobsCompleted,
      hoursWorked: hoursWorked ?? this.hoursWorked,
      averageRating: averageRating ?? this.averageRating,
      totalBookings: totalBookings ?? this.totalBookings,
      completedBookings: completedBookings ?? this.completedBookings,
      cancelledBookings: cancelledBookings ?? this.cancelledBookings,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'CleanerStats(todayEarnings: $todayEarnings, jobsCompleted: $jobsCompleted, hoursWorked: $hoursWorked, averageRating: $averageRating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CleanerStats &&
        other.todayEarnings == todayEarnings &&
        other.jobsCompleted == jobsCompleted &&
        other.hoursWorked == hoursWorked &&
        other.averageRating == averageRating &&
        other.totalBookings == totalBookings &&
        other.completedBookings == completedBookings &&
        other.cancelledBookings == cancelledBookings &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return todayEarnings.hashCode ^
        jobsCompleted.hashCode ^
        hoursWorked.hashCode ^
        averageRating.hashCode ^
        totalBookings.hashCode ^
        completedBookings.hashCode ^
        cancelledBookings.hashCode ^
        lastUpdated.hashCode;
  }
}