class ApiConfigs {
  // static const String baseUrl =
  // 'https://ztzqs5b1-8001.inc1.devtunnels.ms/api/v1/';

  // static const String baseUrl = 'https://api.yatrifly.com/api/v1';
  static const String baseUrl = 'https://ai.mybanao.com/api/v1';
  // Server host root (no /api/v1) — used by endpoints that live outside the
  // versioned API, e.g. the LiveKit token endpoint.
  static const String serverRoot = 'https://ai.mybanao.com';
  static const String getAccessToken = '/auth/token/refresh/';
  static const String loginOtpVerify = '/user/otp-login/';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String saveDeviceToken = '/device-token';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password/';
  static const String forgotPassword = '/auth/forgot-password-resend-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String verifyForgotPasswordOtp =
      '/auth/verify-forgot-password-otp';
  static const String forgotPasswordResend = '/auth/forgot-password-resend-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String accountSetup = '/user/update-profile/';
  static const String termsAndConditions = '/terms';
  static const String privacyPolicy = '/privacy';
  static const String notifications = '/notifications';
  static const String readNotification = '/notification/markasread/';
  static const String authProfile = '/auth/profile/';
  // static const String uploadProfileImage = '/user/profile/image/';
  static const String updateProfile = '/auth/profile/update/';
  static const String getUser = '/auth/profile/';
  static const String todaysOverview = '/auth/todays-overview/';
  static const String notificationSetting = '/auth/notification-setting/';

  // Dynamic theme endpoint
  static const String appThemes = '/core/custom-themes/';
  static const String customFields = '/core/custom-fields/';


  // Payment endpoints
  static const String flightBookingPayment = '/flights/bookings/{id}/payment';
  static const String packageBookingPayment =
      '/package-bookings/{id}/payment';
  static const String paymentVerify = '/payments/{gateway}/verify';

  // Chatbot endpoints
  static const String chatbotMessage = '/chatbot/message';
  static const String chatbotMessageStream = '/chatbot/message/stream';

  // AI Chat feature endpoints
  static const String chatBaseUrl = baseUrl;
  static const String chatStart = '/chatbot/start';
  static const String chatBot = '/chatbot/message';
  static const String chatBotStream = '/chatbot/message/stream';
  // Sessions list: GET /chatbot/sessions?limit&offset&search&sort&pinned_first
  static const String chatSessions = '/chatbot/sessions';
  static const String chatSessionsPinned = '/chatbot/sessions/pinned';
  // Single session ops share the base + /{session_id}
  static const String chatSessionsDeleteBase = '/chatbot/sessions/';
  // Transcript: GET /chatbot/history/{session_id}?limit&offset
  static const String chatHistory = '/chatbot/history';
  static const String chatSessionPin = '/chatbot/sessions';
  static const String chatSessionRename = '/chatbot/sessions';
  // Image analysis: POST /chatbot/analyze-image
  static const String analyzeImage = '/analyze-image';

  // LiveKit voice token endpoint (lives at the server root, not under /api/v1)
  static const String liveKitTokenUrl =
      '$serverRoot/api/livekit/generate-token';
}
