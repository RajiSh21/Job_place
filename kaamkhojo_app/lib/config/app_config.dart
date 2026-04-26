class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:5000/api',
  );

  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  static const String googleMapsKey = String.fromEnvironment(
    'GOOGLE_MAPS_KEY',
    defaultValue: '',
  );

  // Platform commission displayed to users
  static const double commissionRate = 0.10;

  // Pagination defaults
  static const int defaultPageSize = 20;

  // Image upload constraints
  static const int maxJobPhotos = 5;
  static const int maxWorkPhotos = 10;

  // Nepal phone prefix
  static const String nepalPhonePrefix = '+977';
}
