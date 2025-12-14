import 'package:flutter/material.dart';

class Flight {
  final String id;
  final String airlineName;
  final String flightNumber;
  final String originCode;
  final String originCity;
  final String destCode;
  final String destCity;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double basePrice;
  final String gate;

  Flight({
    required this.id,
    required this.airlineName,
    required this.flightNumber,
    required this.originCode,
    required this.originCity,
    required this.destCode,
    required this.destCity,
    required this.departureTime,
    required this.arrivalTime,
    required this.basePrice,
    this.gate = "A1",
  });

  String get duration {
    final diff = arrivalTime.difference(departureTime);
    return "${diff.inHours}sa ${diff.inMinutes.remainder(60)}dk";
  }

  int get durationInMinutes => arrivalTime.difference(departureTime).inMinutes;
}

class Seat {
  final String seatID;
  final String seatNumber;
  final bool isBooked;
  final String classType;
  final double priceMultiplier;

  Seat(
      {required this.seatID,
      required this.seatNumber,
      required this.isBooked,
      required this.classType,
      this.priceMultiplier = 1.0});
}

class MockData {
  static List<String> getCities() {
    return [
      "Istanbul (IST)",
      "London (LHR)",
      "Paris (CDG)",
      "New York (JFK)",
      "Berlin (BER)"
    ];
  }

  static List<Flight> getFlights() {
    DateTime today = DateTime.now();
    DateTime tomorrow = today.add(const Duration(days: 1));

    return [
      Flight(
          id: "1",
          airlineName: "Pegasus",
          flightNumber: "PC 101",
          originCode: "SAW",
          originCity: "Istanbul",
          destCode: "LHR",
          destCity: "London",
          departureTime: DateTime(today.year, today.month, today.day, 06, 00),
          arrivalTime: DateTime(today.year, today.month, today.day, 11, 30),
          basePrice: 2500.0,
          gate: "304"),
      Flight(
          id: "2",
          airlineName: "Turkish Airlines",
          flightNumber: "TK 1985",
          originCode: "IST",
          originCity: "Istanbul",
          destCode: "LHR",
          destCity: "London",
          departureTime: DateTime(today.year, today.month, today.day, 09, 00),
          arrivalTime: DateTime(today.year, today.month, today.day, 11, 00),
          basePrice: 6000.0,
          gate: "212"),
      Flight(
          id: "3",
          airlineName: "British Airways",
          flightNumber: "BA 670",
          originCode: "IST",
          originCity: "Istanbul",
          destCode: "LHR",
          destCity: "London",
          departureTime: DateTime(today.year, today.month, today.day, 14, 00),
          arrivalTime: DateTime(today.year, today.month, today.day, 17, 30),
          basePrice: 4500.0,
          gate: "101"),
      Flight(
          id: "4",
          airlineName: "Lufthansa",
          flightNumber: "LH 990",
          originCode: "IST",
          originCity: "Istanbul",
          destCode: "LHR",
          destCity: "London",
          departureTime:
              DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 13, 15),
          arrivalTime:
              DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 16, 20),
          basePrice: 3800.0,
          gate: "C4"),
    ];
  }

  // --- GÜNCELLENEN KOLTUK MANTIĞI ---
  static List<Seat> getSeatsForFlight(String flightId) {
    return List.generate(24, (index) {
      int row = (index ~/ 4) + 1;
      String letter = ['A', 'B', 'C', 'D'][index % 4];

      String type;
      double mult;

      // 1. Sıra -> First Class
      if (row == 1) {
        type = "First Class";
        mult = 4.0; // 4 katı fiyat
      }
      // 2. ve 3. Sıra -> Business
      else if (row <= 3) {
        type = "Business";
        mult = 2.0; // 2 katı fiyat
      }
      // Kalanı -> Economy
      else {
        type = "Economy";
        mult = 1.0;
      }

      return Seat(
        seatID: "$flightId-$row$letter",
        seatNumber: "$row$letter",
        isBooked: [2, 5, 8, 12, 19].contains(index), // Rastgele dolu koltuklar
        classType: type,
        priceMultiplier: mult,
      );
    });
  }
}

class User {
  final String name;
  final String email;
  final String password;

  User({required this.name, required this.email, required this.password});
}
