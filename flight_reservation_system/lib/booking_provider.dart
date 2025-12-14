import 'package:flutter/material.dart';
import 'dart:math';
import 'data.dart';

class BookingProvider extends ChangeNotifier {
  // --- SANAL VERİTABANI (KAYITLI KULLANICILAR) ---
  // Varsayılan olarak bir tane test kullanıcısı ekleyelim
  final List<User> _registeredUsers = [
    User(name: "Test Kullanıcı", email: "test@gmail.com", password: "123456")
  ];

  bool _isLoggedIn = false;
  User? _currentUser; // Şu an giriş yapmış kullanıcı

  // --- UÇUŞ & OTOPARK DEĞİŞKENLERİ ---
  String? _selectedOrigin = "Istanbul (IST)";
  String? _selectedDestination = "London (LHR)";
  DateTime _selectedDate = DateTime.now();

  Flight? _selectedFlight;
  Seat? _selectedSeat;
  bool _addParking = false;
  bool _payAtLocation = false;
  String? _parkingSpot;
  final double _baseParkingDailyRate = 250.0;
  String _vehicleType = "Otomobil";
  DateTime _parkingStartDate = DateTime.now();
  DateTime _parkingEndDate = DateTime.now().add(const Duration(days: 3));

  final Map<String, double> _vehicleMultipliers = {
    "Motosiklet": 0.8,
    "Otomobil": 1.0,
    "SUV": 1.3,
    "Kamyonet": 1.5,
  };

  // --- YOLCU BİLGİLERİ (Giriş yapınca otomatik dolacak) ---
  final TextEditingController nameController = TextEditingController(text: "");
  final TextEditingController passportController =
      TextEditingController(text: "");
  final TextEditingController emailController = TextEditingController(text: "");
  final TextEditingController phoneController = TextEditingController(text: "");

  // --- GETTERS ---
  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;

  String? get selectedOrigin => _selectedOrigin;
  String? get selectedDestination => _selectedDestination;
  DateTime get selectedDate => _selectedDate;
  Flight? get selectedFlight => _selectedFlight;
  Seat? get selectedSeat => _selectedSeat;
  bool get addParking => _addParking;
  bool get payAtLocation => _payAtLocation;
  String? get parkingSpot => _parkingSpot;
  String get vehicleType => _vehicleType;
  DateTime get parkingStartDate => _parkingStartDate;
  DateTime get parkingEndDate => _parkingEndDate;

  int get parkingDays {
    int days = _parkingEndDate.difference(_parkingStartDate).inDays;
    return days <= 0 ? 1 : days;
  }

  double get totalParkingPrice {
    if (!_addParking) return 0;
    double multiplier = _vehicleMultipliers[_vehicleType] ?? 1.0;
    return _baseParkingDailyRate * multiplier * parkingDays;
  }

  double get parkingDailyRate => _baseParkingDailyRate;

  double get totalPrice {
    double total = 0;
    if (_selectedFlight != null) total += _selectedFlight!.basePrice;
    if (_selectedSeat != null) {
      total +=
          (_selectedFlight!.basePrice * (_selectedSeat!.priceMultiplier - 1));
    }
    if (_addParking && !_payAtLocation) {
      total += totalParkingPrice;
    }
    return total;
  }

  // --- AUTH METOTLARI (GÜNCELLENDİ) ---

  // 1. Kayıt Ol
  String register(String name, String email, String password) {
    // E-posta kontrolü (Var mı?)
    bool exists = _registeredUsers.any((u) => u.email == email);
    if (exists) {
      return "Bu e-posta adresi zaten kayıtlı!";
    }

    // Yeni kullanıcıyı listeye ekle (Kaydet)
    _registeredUsers.add(User(name: name, email: email, password: password));

    // Otomatik giriş yap
    login(email, password);
    return "success";
  }

  // 2. Giriş Yap
  String login(String email, String password) {
    try {
      // Listede bu mail ve şifreye sahip biri var mı?
      User user = _registeredUsers
          .firstWhere((u) => u.email == email && u.password == password);

      // Varsa giriş başarılı
      _currentUser = user;
      _isLoggedIn = true;

      // Formları kullanıcının bilgileriyle doldur
      nameController.text = user.name;
      emailController.text = user.email;
      // Diğerleri şimdilik boş veya varsayılan kalsın, kullanıcı tamamlasın
      phoneController.text = "";
      passportController.text = "";

      notifyListeners();
      return "success";
    } catch (e) {
      return "E-posta veya şifre hatalı!";
    }
  }

  // 3. Çıkış Yap
  void logout() {
    _isLoggedIn = false;
    _currentUser = null;

    // Formları temizle
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    passportController.clear();

    notifyListeners();
  }

  // --- DİĞER SETTERS & LOGIC ---
  void setOrigin(String? val) {
    _selectedOrigin = val;
    notifyListeners();
  }

  void setDestination(String? val) {
    _selectedDestination = val;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    _parkingStartDate = date;
    _parkingEndDate = date.add(const Duration(days: 3));
    notifyListeners();
  }

  void setQuickTrip(String destinationCityCode) {
    _selectedOrigin = "Istanbul (IST)";
    _selectedDestination = destinationCityCode;
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    notifyListeners();
  }

  void _generateParkingSpot() {
    final random = Random();
    String block = ['A', 'B', 'C'][random.nextInt(3)];
    int number = random.nextInt(100) + 1;
    _parkingSpot = "$block-$number";
  }

  void toggleParking(bool value) {
    _addParking = value;
    if (value) {
      _generateParkingSpot();
    } else {
      _payAtLocation = false;
      _parkingSpot = null;
    }
    notifyListeners();
  }

  void setPayAtLocation(bool value) {
    _payAtLocation = value;
    notifyListeners();
  }

  void setVehicleType(String type) {
    _vehicleType = type;
    notifyListeners();
  }

  void setParkingDates(DateTime start, DateTime end) {
    _parkingStartDate = start;
    _parkingEndDate = end;
    notifyListeners();
  }

  List<Flight> getFilteredFlights() {
    List<Flight> allFlights = MockData.getFlights();
    return allFlights.where((flight) {
      bool dateMatch = flight.departureTime.year == _selectedDate.year &&
          flight.departureTime.month == _selectedDate.month &&
          flight.departureTime.day == _selectedDate.day;
      return dateMatch;
    }).toList();
  }

  String getMinPriceForDate(DateTime date) {
    List<Flight> allFlights = MockData.getFlights();
    List<Flight> flightsOnDate = allFlights
        .where((flight) =>
            flight.departureTime.year == date.year &&
            flight.departureTime.month == date.month &&
            flight.departureTime.day == date.day)
        .toList();
    if (flightsOnDate.isEmpty) return "-";
    double minPrice =
        flightsOnDate.map((e) => e.basePrice).reduce((a, b) => a < b ? a : b);
    return "₺${minPrice.toStringAsFixed(0)}";
  }

  void selectFlight(Flight flight) {
    _selectedFlight = flight;
    _selectedSeat = null;
    _addParking = false;
    notifyListeners();
  }

  void selectSeat(Seat seat) {
    _selectedSeat = seat;
    notifyListeners();
  }

  List<Flight> getAllFlights() {
    return MockData.getFlights();
  }
}
