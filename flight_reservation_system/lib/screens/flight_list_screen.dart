import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../booking_provider.dart';
import '../data.dart';
import 'seat_selection_screen.dart';

class FlightListScreen extends StatefulWidget {
  const FlightListScreen({super.key});

  @override
  State<FlightListScreen> createState() => _FlightListScreenState();
}

class _FlightListScreenState extends State<FlightListScreen> {
  // Seçili Durumlar
  String _currentSort = "Varsayılan";
  bool _isLoading = false;
  List<Flight>? _displayFlights;

  @override
  void initState() {
    super.initState();
    // İlk açılışta listeyi doldur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshFlights();
    });
  }

  void _refreshFlights() {
    final provider = context.read<BookingProvider>();
    setState(() {
      _displayFlights = List.from(provider.getFilteredFlights());
      _applySort(); // Mevcut sıralamayı uygula
    });
  }

  void _sortFlights(String criteria) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _currentSort = criteria;
      _applySort();
      _isLoading = false;
    });
  }

  void _applySort() {
    if (_displayFlights == null) return;

    if (_currentSort == "En Ucuz") {
      _displayFlights!.sort((a, b) => a.basePrice.compareTo(b.basePrice));
    } else if (_currentSort == "En Hızlı") {
      _displayFlights!.sort((a, b) {
        int durationA = a.arrivalTime.difference(a.departureTime).inMinutes;
        int durationB = b.arrivalTime.difference(b.departureTime).inMinutes;
        return durationA.compareTo(durationB);
      });
    } else {
      // Varsayılan: Rastgelelik yerine kalkış saatine göre sıralayalım daha mantıklı olur
      _displayFlights!
          .sort((a, b) => a.departureTime.compareTo(b.departureTime));
    }
  }

  void _changeDate(DateTime date, bool hasFlight) async {
    final provider = context.read<BookingProvider>();

    // Eğer o gün uçuş yoksa seçtirme
    if (!hasFlight) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Seçilen tarihte uygun uçuş bulunmamaktadır."),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    // Aynı tarih seçiliyse işlem yapma
    if (isSameDay(provider.selectedDate, date)) return;

    setState(() => _isLoading = true);

    // Tarihi güncelle
    provider.setDate(date);

    await Future.delayed(const Duration(milliseconds: 600));

    // Listeyi yenile
    _refreshFlights();

    setState(() => _isLoading = false);
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Türkçe gün isimleri yardımcısı
  String _getDayName(int weekday) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[weekday - 1];
  }

  // Türkçe ay isimleri yardımcısı
  String _getMonthName(int month) {
    const months = [
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Ekim',
      'Kas',
      'Ara'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final size = MediaQuery.of(context).size;
    bool isDesktop = size.width > 900;

    // Eğer liste henüz null ise (initState çalışmadan build olursa)
    if (_displayFlights == null) {
      _displayFlights = List.from(provider.getFilteredFlights());
    }

    // --- DİNAMİK TARİH KARTLARI OLUŞTURMA ---
    // Bugünden itibaren 5 günü listele
    DateTime startDate = DateTime.now();
    List<Map<String, dynamic>> dynamicDateCards = List.generate(5, (index) {
      DateTime d = startDate.add(Duration(days: index));
      String minPrice = provider.getMinPriceForDate(d);
      bool hasFlight = minPrice != "-"; // Fiyat yoksa uçuş da yoktur

      return {
        "dateObj": d,
        "day": _getDayName(d.weekday),
        "date": "${d.day} ${_getMonthName(d.month)}",
        "price": hasFlight ? minPrice : "Yok",
        "hasFlight": hasFlight
      };
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Column(
        children: [
          // ============================================================
          // 1. HEADER VE TARİH ŞERİDİ
          // ============================================================
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF023E8A), Color(0xFF0096C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Üst Navigasyon
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        Text("Uçuş Seçimi",
                            style: GoogleFonts.poppins(
                                color: Colors.white70, fontSize: 14)),
                        const Spacer(),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),

                  // Rota Görseli
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(provider.selectedOrigin!.split(' ')[0],
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                            Text("Kalkış",
                                style: GoogleFonts.poppins(
                                    color: Colors.white70, fontSize: 10)),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.circle,
                                      size: 6, color: Colors.white54),
                                  Container(
                                      width: 40,
                                      height: 1,
                                      color: Colors.white54),
                                  Transform.rotate(
                                      angle: 1.57,
                                      child: const Icon(Icons.flight,
                                          color: Colors.white, size: 20)),
                                  Container(
                                      width: 40,
                                      height: 1,
                                      color: Colors.white54),
                                  const Icon(Icons.circle,
                                      size: 6, color: Colors.white54),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text("1s 45dk",
                                    style: GoogleFonts.poppins(
                                        color: Colors.white, fontSize: 10)),
                              )
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(provider.selectedDestination!.split(' ')[0],
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                            Text("Varış",
                                style: GoogleFonts.poppins(
                                    color: Colors.white70, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TARİH KARTLARI (Dinamik Liste)
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: dynamicDateCards.length,
                      separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return _buildBigDateCard(
                            dynamicDateCards[index], provider);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. FİLTRELER
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? (size.width - 800) / 2 : 20,
                vertical: 15),
            child: Row(
              children: [
                Text("${_displayFlights!.length} Uçuş",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800)),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300)),
                  child: Row(
                    children: [
                      _buildSortBtn("En Ucuz"),
                      Container(
                          width: 1, height: 20, color: Colors.grey.shade300),
                      _buildSortBtn("En Hızlı"),
                    ],
                  ),
                )
              ],
            ),
          ),

          // 3. UÇUŞ LİSTESİ
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor))
                : _displayFlights!.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? (size.width - 800) / 2 : 20,
                            vertical: 0),
                        itemCount: _displayFlights!.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return _buildFlightCard(
                              context, _displayFlights![index], provider);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // --- COMPONENT: DİNAMİK TARİH KARTI ---
  Widget _buildBigDateCard(
      Map<String, dynamic> data, BookingProvider provider) {
    DateTime date = data["dateObj"];
    bool isSelected = isSameDay(date, provider.selectedDate);
    bool hasFlight = data["hasFlight"];

    return GestureDetector(
      onTap: () => _changeDate(date, hasFlight),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 75,
        decoration: BoxDecoration(
          // Uçuş yoksa gri, seçiliyse turuncu, normalse şeffaf beyaz
          color: !hasFlight
              ? Colors.white.withOpacity(0.05)
              : (isSelected
                  ? const Color(0xFFFF9F1C)
                  : Colors.white.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: Colors.white, width: 2)
              : Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(data["day"],
                style: TextStyle(
                    color: !hasFlight
                        ? Colors.white38
                        : (isSelected ? Colors.white : Colors.white70),
                    fontSize: 11)),
            const SizedBox(height: 2),
            Text(data["date"],
                style: TextStyle(
                    color: !hasFlight ? Colors.white38 : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(height: 2),

            // Uçuş yoksa ikon, varsa fiyat
            !hasFlight
                ? const Icon(Icons.block, color: Colors.white24, size: 16)
                : Text(data["price"],
                    style: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xFFB3E5FC),
                        fontWeight: FontWeight.bold,
                        fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // --- DİĞER COMPONENTLER (AYNI) ---

  Widget _buildSortBtn(String label) {
    bool isActive = _currentSort == label;
    return InkWell(
      onTap: () => _sortFlights(label),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? const Color(0xFF0077B6) : Colors.grey),
        ),
      ),
    );
  }

  Widget _buildFlightCard(
      BuildContext context, Flight flight, BookingProvider provider) {
    // (Kodun bu kısmı orijinal dosyadakiyle aynı kalacak, yer kaplamaması için kısaltmadım ama
    // yukarıdaki orijinal kodun aynısını buraya yapıştırabilirsin.
    // Ana değişiklik build ve _buildBigDateCard kısmındaydı.)
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.blue.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            provider.selectFlight(flight);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => SeatSelectionScreen(flightId: flight.id)));
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10)),
                          child:
                              Icon(Icons.airlines, color: Colors.blue.shade800),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(flight.airlineName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(flight.flightNumber,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    Text("₺${flight.basePrice}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF0077B6))),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('HH:mm').format(flight.departureTime),
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(flight.originCode,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Text(flight.duration,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 5),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                const Divider(color: Colors.grey, thickness: 1),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.flight_takeoff,
                                      size: 16, color: Color(0xFF0077B6)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            const Text("Direkt",
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(DateFormat('HH:mm').format(flight.arrivalTime),
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(flight.destCode,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Ekonomi • 1 Yolcu",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Row(
                      children: [
                        Text("Seç",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800)),
                        const SizedBox(width: 5),
                        Icon(Icons.arrow_forward,
                            size: 16, color: Colors.orange.shade800)
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flight_takeoff_outlined,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text("Uçuş Bulunamadı",
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 5),
          Text("Lütfen başka bir tarih seçin.",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
