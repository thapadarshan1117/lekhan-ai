enum UserType {
  customer,
  cleaner;

  String get displayName {
    switch (this) {
      case UserType.customer:
        return 'Customer';
      case UserType.cleaner:
        return 'Cleaner';
    }
  }

  String get name {
    switch (this) {
      case UserType.customer:
        return 'customer';
      case UserType.cleaner:
        return 'cleaner';
    }
  }

  String get description {
    switch (this) {
      case UserType.customer:
        return 'Book cleaning services for your home or office';
      case UserType.cleaner:
        return 'Provide professional cleaning services to customers';
    }
  }

  static UserType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'customer':
        return UserType.customer;
      case 'cleaner':
        return UserType.cleaner;
      default:
        return UserType.customer; // Default fallback
    }
  }
}