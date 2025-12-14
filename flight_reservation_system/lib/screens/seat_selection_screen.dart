import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../booking_provider.dart';
import '../data.dart';
import 'booking_summary_screen.dart';

class SeatSelectionScreen extends StatelessWidget {
  final String flightId;
  const SeatSelectionScreen({super.key, required this.flightId});

  @override
  Widget build(BuildContext context) {
    final seats = MockData.getSeatsForFlight(flightId);
    final provider = context.watch<BookingProvider>();
    final size = MediaQuery.of(context).size;

    bool isDesktop = size.width > 1000;

    // Koltukları satırlara böl
    Map<int, List<Seat>> rows = {};
    for (var seat in seats) {
      int rowNum = int.parse(seat.seatNumber.replaceAll(RegExp(r'[^0-9]'), ''));
      if (!rows.containsKey(rowNum)) rows[rowNum] = [];
      rows[rowNum]!.add(seat);
    }

    // RENK PALETİ
    final Color bgColor = const Color(0xFFECEFF1);
    final Color fuselageColor = Colors.white;
    final Color businessColor = const Color(0xFF0D47A1); // Derin Mavi
    final Color firstClassColor = const Color(0xFFFFD700); // Altın Sarısı

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text("Koltuk Seçimi",
            style: GoogleFonts.poppins(
                color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildLeftPanel(provider)),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: _buildPlaneFuselage(context, rows, provider,
                          fuselageColor, businessColor, firstClassColor),
                    ),
                  ),
                ),
                Expanded(flex: 3, child: _buildRightPanel(context, provider)),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildLeftPanel(provider),
                  _buildPlaneFuselage(context, rows, provider, fuselageColor,
                      businessColor, firstClassColor),
                  _buildRightPanel(context, provider),
                ],
              ),
            ),
    );
  }

  // PANEL 1: SOL (BİLGİ)
  Widget _buildLeftPanel(BookingProvider provider) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Uçuş Detayları",
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800)),
          const Divider(height: 30),
          _buildInfoRow(
              Icons.flight_takeoff, "Kalkış", "Istanbul (IST)", "08:30"),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.flight_land, "Varış", "London (LHR)", "12:30"),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.airplanemode_active, "Uçak Tipi",
              "Boeing 737-800", "Dar Gövde"),
          const SizedBox(height: 30),
          Text("Koltuk Durumları",
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildLegendItem(Colors.white, "Boş", border: true),
              _buildLegendItem(Colors.grey.shade300, "Dolu"),
              _buildLegendItem(const Color(0xFFFF9F1C), "Seçili"),
              _buildLegendItem(const Color(0xFFFFD700), "First Class"),
              _buildLegendItem(const Color(0xFF0D47A1), "Business"),
            ],
          )
        ],
      ),
    );
  }

  // PANEL 2: UÇAK GÖVDESİ (GÜNCELLENDİ)
  Widget _buildPlaneFuselage(
      BuildContext context,
      Map<int, List<Seat>> rows,
      BookingProvider provider,
      Color fuselageColor,
      Color businessColor,
      Color firstClassColor) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: fuselageColor,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(160), bottom: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.flight, size: 50, color: Colors.grey.shade300),
          const SizedBox(height: 20),

          // --- 1. FIRST CLASS ---
          _buildClassBadge("FIRST CLASS", firstClassColor),
          ...rows.keys.where((r) => r == 1).map((r) =>
              _buildRow(context, r, rows[r]!, provider, classType: "First")),

          const SizedBox(height: 20),

          // --- 2. BUSINESS CLASS ---
          _buildClassBadge("BUSINESS CLASS", businessColor),
          ...rows.keys.where((r) => r > 1 && r <= 3).map((r) =>
              _buildRow(context, r, rows[r]!, provider, classType: "Business")),

          const SizedBox(height: 20),

          // --- 3. ECONOMY CLASS ---
          _buildClassBadge("ECONOMY CLASS", Colors.lightBlue),
          ...rows.keys.where((r) => r > 3).map((r) =>
              _buildRow(context, r, rows[r]!, provider, classType: "Economy")),

          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // PANEL 3: SAĞ (ÖZET)
  Widget _buildRightPanel(BuildContext context, BookingProvider provider) {
    // Ek ücret hesabı
    String extraFee = "Ücretsiz";
    if (provider.selectedSeat != null) {
      if (provider.selectedSeat!.classType == "First Class") {
        extraFee =
            "+₺${provider.selectedFlight!.basePrice * 3}"; // x4 olduğu için +3 kat ekle
      } else if (provider.selectedSeat!.classType == "Business") {
        extraFee =
            "+₺${provider.selectedFlight!.basePrice}"; // x2 olduğu için +1 kat ekle
      }
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Seçiminiz",
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800)),
          const Divider(height: 30),
          Center(
            child: Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: provider.selectedSeat == null
                      ? Colors.grey.shade100
                      : const Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: provider.selectedSeat == null
                          ? Colors.grey.shade300
                          : Colors.blue,
                      width: 2)),
              child: Text(
                provider.selectedSeat?.seatNumber ?? "--",
                style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: provider.selectedSeat == null
                        ? Colors.grey
                        : Colors.blue.shade900),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSummaryItem("Sınıf", provider.selectedSeat?.classType ?? "-"),
          _buildSummaryItem("Ek Ücret", extraFee),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: provider.selectedSeat == null
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BookingSummaryScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9F1C),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("SEÇİMİ ONAYLA",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  // --- SATIR YAPISI ---
  Widget _buildRow(BuildContext context, int rowNum, List<Seat> seats,
      BookingProvider provider,
      {required String classType}) {
    // First ve Business satırları biraz daha geniş olsun
    bool isPremium = classType == "First" || classType == "Business";

    return Container(
      margin: EdgeInsets.only(bottom: isPremium ? 15 : 8),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildWindow(left: true),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSeat(seats[0], provider, classType),
                SizedBox(width: isPremium ? 10 : 4),
                _buildSeat(seats[1], provider, classType),
                SizedBox(
                    width: 40,
                    child: Center(
                        child: Text("$rowNum",
                            style: GoogleFonts.poppins(
                                color: Colors.grey.shade300,
                                fontWeight: FontWeight.bold)))),
                _buildSeat(seats[2], provider, classType),
                SizedBox(width: isPremium ? 10 : 4),
                _buildSeat(seats[3], provider, classType),
              ],
            ),
          ),
          _buildWindow(left: false),
        ],
      ),
    );
  }

  // --- KOLTUK WIDGET (GÜNCELLENDİ) ---
  Widget _buildSeat(Seat seat, BookingProvider provider, String classType) {
    bool isSelected = provider.selectedSeat?.seatID == seat.seatID;
    Color color = Colors.white;
    Color border = Colors.grey.shade300;
    Color textColor = Colors.grey;

    if (seat.isBooked) {
      color = Colors.grey.shade300;
      border = Colors.transparent;
    } else if (isSelected) {
      color = const Color(0xFFFF9F1C);
      border = const Color(0xFFFF9F1C);
      textColor = Colors.black87;
    } else if (classType == "First") {
      color = const Color(0xFFFFF8E1); // Açık Gold
      border = const Color(0xFFFFD700); // Koyu Gold
      textColor = Colors.black87;
    } else if (classType == "Business") {
      color = const Color(0xFFE8EAF6); // Açık Mavi
      border = const Color(0xFF3949AB); // Koyu Mavi
      textColor = Colors.black54;
    }

    // First class koltukları biraz daha büyük olsun
    double size =
        classType == "First" ? 55 : (classType == "Business" ? 50 : 42);

    return GestureDetector(
      onTap: seat.isBooked ? null : () => provider.selectSeat(seat),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: 2),
          boxShadow: isSelected || classType == "First"
              ? [BoxShadow(color: border.withOpacity(0.4), blurRadius: 8)]
              : null,
        ),
        child: Center(
          child: seat.isBooked
              ? const Icon(Icons.close, size: 16, color: Colors.grey)
              : Text(seat.seatNumber.replaceAll(RegExp(r'[0-9]'), ''),
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        ),
      ),
    );
  }

  // --- YARDIMCI WIDGETLAR ---
  Widget _buildWindow({required bool left}) {
    return Container(
      width: 6,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade100,
        borderRadius: BorderRadius.horizontal(
          left: left ? const Radius.circular(10) : Radius.zero,
          right: left ? Radius.zero : const Radius.circular(10),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String val1, String val2) {
    return Row(
      children: [
        Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF0D47A1))),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(val1, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(val2,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        )
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildClassBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildLegendItem(Color color, String text, {bool border = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border:
                    border ? Border.all(color: Colors.grey.shade300) : null)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
