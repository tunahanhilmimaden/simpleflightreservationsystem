import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../booking_provider.dart';
import '../data.dart';
import 'home_screen.dart';

class BoardingPassScreen extends StatelessWidget {
  const BoardingPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<BookingProvider>();
    final flight = provider.selectedFlight!;

    return Scaffold(
      body: Stack(
        children: [
          // 1. ARKAPLAN
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF023E8A), Color(0xFF0096C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Dekoratif Daireler
          Positioned(top: -50, right: -50, child: _buildCircle(300)),
          Positioned(bottom: 100, left: -50, child: _buildCircle(200)),

          // 2. İÇERİK
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  const Icon(Icons.check_circle_outline_rounded,
                      size: 80, color: Colors.white),

                  const SizedBox(height: 10),

                  Text(
                      "İyi Uçuşlar, ${provider.nameController.text.split(' ')[0]}!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),

                  Text("Rezervasyonunuz başarıyla oluşturuldu.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.white70)),

                  const SizedBox(height: 30),

                  // 3. TEK PARÇA BİLET KARTI
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: _buildCleanTicketCard(context, provider, flight),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 4. ANA SAYFA BUTONU
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HomeScreen()),
                            (route) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9F1C),
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_filled, size: 20),
                          SizedBox(width: 10),
                          Text("ANA SAYFA",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- BİLET KARTI ---
  Widget _buildCleanTicketCard(
      BuildContext context, BookingProvider provider, dynamic flight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Kısım
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(flight.airlineName.toUpperCase(),
                    style: const TextStyle(
                        color: Color(0xFF0D47A1),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1)),
              ),
              const Text("ECONOMY CLASS",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
            ],
          ),

          const SizedBox(height: 25),

          // Orta Kısım
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBigCityText(flight.originCode, "Kalkış"),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      const Icon(Icons.flight_takeoff,
                          color: Color(0xFF0077B6), size: 24),
                      const SizedBox(height: 5),
                      Container(height: 2, color: Colors.grey.shade300),
                      const SizedBox(height: 5),
                      Text(flight.duration,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              _buildBigCityText(flight.destCode, "Varış"),
            ],
          ),

          const SizedBox(height: 25),
          const Divider(),
          const SizedBox(height: 15),

          // Alt Kısım
          Wrap(
            spacing: 20,
            runSpacing: 15,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                  "YOLCU", provider.nameController.text.toUpperCase()),
              _buildInfoItem("TARİH",
                  DateFormat("dd MMM yyyy").format(provider.selectedDate)),
              _buildInfoItem("UÇUŞ NO", flight.flightNumber),
              _buildInfoItem("KAPI", flight.gate),
              _buildInfoItem("BİNİŞ", "08:10"),
              _buildInfoItem(
                  "KOLTUK", provider.selectedSeat?.seatNumber ?? "XX",
                  isHighlighted: true),
            ],
          ),

          // --- OTOPARK BİLGİSİ (PARK NO EKLENDİ) ---
          if (provider.addParking) ...[
            const SizedBox(height: 20),
            Builder(builder: (context) {
              bool isPayAtDoor = provider.payAtLocation;
              Color bgColor = isPayAtDoor
                  ? const Color(0xFFE3F2FD)
                  : Colors.green.withOpacity(0.1);
              Color contentColor =
                  isPayAtDoor ? const Color(0xFF1565C0) : Colors.green;
              IconData icon =
                  isPayAtDoor ? Icons.info_outline : Icons.check_circle;

              // Metni Dinamik Yap (Park No Ekle)
              String statusText =
                  isPayAtDoor ? "Otopark: Kapıda Ödenecek" : "Otopark: Ödendi";
              String spotText =
                  "Park Yeri: ${provider.parkingSpot}"; // Örn: Park Yeri: A-42

              return Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: contentColor.withOpacity(0.3))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Sol Taraf: Durum
                    Row(
                      children: [
                        Icon(icon, color: contentColor, size: 20),
                        const SizedBox(width: 8),
                        Text(statusText,
                            style: TextStyle(
                                color: contentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ],
                    ),

                    // Sağ Taraf: Park No
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(spotText,
                          style: TextStyle(
                              color: contentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    )
                  ],
                ),
              );
            })
          ]
        ],
      ),
    );
  }

  Widget _buildBigCityText(String code, String label) {
    return Column(
      children: [
        Text(code,
            style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B263B))),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value,
      {bool isHighlighted = false}) {
    return SizedBox(
      width: 75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isHighlighted
                      ? const Color(0xFFFF9F1C)
                      : Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
    );
  }
}
