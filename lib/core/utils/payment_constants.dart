
import 'dart:ui';

class PaymentConstants {
  static const primaryColor = Color(0xFF007E85);
  static const List<Map<String, dynamic>> paymentMethods = [
    {
      "name": "eSewa",
      "icon": "assets/icons/patient/esewaa.png",
      "enabled": true
    },
    {
      "name": "Khalti",
      "icon": "assets/icons/patient/khalti.png", 
      "enabled": true
    },
    {
      "name": "IME Pay",
      "icon": "assets/icons/patient/esewaa.png",
      "enabled": false
    },
  ];
}
