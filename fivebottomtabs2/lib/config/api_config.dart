class ApiConfig {
  // Chrome/Windows on the same computer as the Node.js backend:
  static const String baseUrl = 'http://localhost:5000/api';

  // Android emulator: use http://10.0.2.2:5000/api instead.
  // Physical phone: use your computer's LAN IPv4, e.g. http://192.168.1.10:5000/api.
  static const Duration timeout = Duration(seconds: 20);
}
