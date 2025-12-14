import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../booking_provider.dart';
import '../data.dart';
import 'flight_list_screen.dart';
import 'auth_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = context.watch<BookingProvider>();
    final cities = MockData.getCities();

    // Masaüstü kontrolü (Genişlik 900'den büyükse)
    bool isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ---------------- HEADER & SEARCH SECTION ----------------
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // 1. Header Arkaplan
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF023E8A), Color(0xFF0077B6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Dekoratif Baloncuklar
                      Positioned(top: -50, left: -50, child: _buildCircle(200)),
                      Positioned(top: 50, right: -20, child: _buildCircle(150)),
                      Positioned(
                          bottom: -50, left: 100, child: _buildCircle(100)),

                      // --- SAĞ ÜST GİRİŞ/ÇIKIŞ BUTONU ---
                      Positioned(
                        top: 40,
                        right: 20,
                        child: InkWell(
                          onTap: () {
                            if (provider.isLoggedIn) {
                              _showLogoutDialog(context, provider);
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AuthScreen()));
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3))),
                            child: Row(
                              children: [
                                Icon(
                                    provider.isLoggedIn
                                        ? Icons.logout
                                        : Icons.login,
                                    color: Colors.white,
                                    size: 18),
                                const SizedBox(width: 8),
                                Text(
                                    provider.isLoggedIn
                                        ? "Çıkış Yap"
                                        : "Giriş Yap / Kayıt Ol",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Başlık
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20)),
                              child: const Text("✈️ Dünyayı Keşfet",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 10),
                            Text("SkyRes",
                                style: GoogleFonts.poppins(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.5)),
                            Text("Sınırsız Rota, Tek Adres",
                                style: GoogleFonts.poppins(
                                    fontSize: 16, color: Colors.white70)),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Arama Kapsülü (ESKİ HALİNE DÖNDÜRÜLDÜ)
                Positioned(
                  bottom: -30,
                  child: Container(
                    width: isDesktop ? 850 : size.width * 0.92,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF0077B6).withOpacity(0.25),
                            blurRadius: 30,
                            offset: const Offset(0, 15))
                      ],
                    ),
                    // BURASI DÜZELTİLDİ: Masaüstü için Row, Mobil için Column
                    child: isDesktop
                        ? Row(
                            children: [
                              Expanded(
                                  child: _buildCleanDropdown(
                                      Icons.flight_takeoff,
                                      "Nereden",
                                      cities,
                                      provider.selectedOrigin,
                                      (v) => provider.setOrigin(v))),
                              _buildVerticalDivider(),
                              Expanded(
                                  child: _buildCleanDropdown(
                                      Icons.flight_land,
                                      "Nereye",
                                      cities,
                                      provider.selectedDestination,
                                      (v) => provider.setDestination(v))),
                              _buildVerticalDivider(),
                              Expanded(
                                  child: _buildCleanDate(context, provider)),
                              const SizedBox(width: 10),
                              // Masaüstü Arama Butonu
                              _InteractiveButton(
                                onPressed: () =>
                                    _handleSearch(context, provider),
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFFF9F1C),
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.search,
                                      color: Colors.white),
                                ),
                              )
                            ],
                          )
                        : Column(
                            children: [
                              _buildCleanDropdown(
                                  Icons.flight_takeoff,
                                  "Nereden",
                                  cities,
                                  provider.selectedOrigin,
                                  (v) => provider.setOrigin(v)),
                              const Divider(),
                              _buildCleanDropdown(
                                  Icons.flight_land,
                                  "Nereye",
                                  cities,
                                  provider.selectedDestination,
                                  (v) => provider.setDestination(v)),
                              const Divider(),
                              _buildCleanDate(context, provider),
                              const SizedBox(height: 15),
                              // Mobil Arama Butonu
                              _InteractiveButton(
                                onPressed: () =>
                                    _handleSearch(context, provider),
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFFF9F1C),
                                      borderRadius: BorderRadius.circular(30)),
                                  child: const Center(
                                      child: Text("UÇUŞ ARA",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16))),
                                ),
                              )
                            ],
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 80),

            // ---------------- POPÜLER ROTALAR ----------------
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? (size.width - 1000) / 2 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Popüler Rotalar",
                          style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      const SizedBox(height: 5),
                      Text("Sizin için seçtiğimiz en iyi fiyatlı uçuşlar",
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.8,
                        children: [
                          _buildRouteCard(
                              context,
                              "London (LHR)",
                              "Londra",
                              "₺4,500",
                              "https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=400"),
                          _buildRouteCard(
                              context,
                              "Paris (CDG)",
                              "Paris",
                              "₺3,800",
                              "https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400"),
                          _buildRouteCard(
                              context,
                              "New York (JFK)",
                              "New York",
                              "₺15,000",
                              "https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=400"),
                          _buildRouteCard(
                              context,
                              "Berlin (BER)",
                              "Berlin",
                              "₺2,900",
                              "https://images.unsplash.com/photo-1560969184-10fe8719e047?w=400"),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),

            // ---------------- NEDEN BİZ? ----------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
              color: Colors.white,
              child: Column(
                children: [
                  Text("Neden SkyRes?",
                      style: GoogleFonts.poppins(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  Wrap(
                    spacing: 40,
                    runSpacing: 40,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFeatureItem(Icons.verified_user_outlined,
                          "Güvenli Ödeme", "3D Secure ile koruma"),
                      _buildFeatureItem(Icons.price_check, "En İyi Fiyat",
                          "Fiyat garantili biletler"),
                      _buildFeatureItem(Icons.support_agent, "7/24 Destek",
                          "Her an yanınızdayız"),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- ORTAK ARAMA MANTIĞI ---
  void _handleSearch(BuildContext context, BookingProvider provider) async {
    if (!provider.isLoggedIn) {
      bool? result = await Navigator.push(
          context, MaterialPageRoute(builder: (_) => const AuthScreen()));
      if (result == true) {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const FlightListScreen()));
      }
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const FlightListScreen()));
    }
  }

  // --- HELPER WIDGETS ---

  void _showLogoutDialog(BuildContext context, BookingProvider provider) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("Çıkış Yap"),
              content: const Text(
                  "Hesabınızdan çıkış yapmak istediğinize emin misiniz?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("İptal")),
                TextButton(
                    onPressed: () {
                      provider.logout();
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Çıkış yapıldı.")));
                    },
                    child: const Text("Çıkış Yap",
                        style: TextStyle(color: Colors.red))),
              ],
            ));
  }

  Widget _buildCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
    );
  }

  Widget _buildCleanDropdown(IconData icon, String hint, List<String> items,
      String? value, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: const InputDecoration.collapsed(hintText: ''),
          icon: Icon(Icons.keyboard_arrow_down,
              color: Colors.grey.shade400, size: 20),
          menuMaxHeight: 300,
          alignment: AlignmentDirectional.bottomStart,
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(hint.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold)),
                    Text(val,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                  ]),
            );
          }).toList(),
          onChanged: onChanged,
          selectedItemBuilder: (context) {
            return items.map((String val) {
              return Row(children: [
                Icon(icon, size: 22, color: const Color(0xFF0077B6)),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(val,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1)),
              ]);
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildCleanDate(BuildContext context, BookingProvider provider) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
            context: context,
            initialDate: provider.selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime(2026));
        if (picked != null) provider.setDate(picked);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(children: [
                Icon(Icons.calendar_today, size: 18, color: Color(0xFF0077B6)),
                SizedBox(width: 8),
                Text("Gidiş Tarihi",
                    style: TextStyle(fontSize: 10, color: Colors.grey))
              ]),
              Text(DateFormat("dd MMM yyyy").format(provider.selectedDate),
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ]),
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context, String cityCode, String cityName,
      String price, String imageUrl) {
    return _InteractiveButton(
      onPressed: () {
        context.read<BookingProvider>().setQuickTrip(cityCode);
        _handleSearch(
            context,
            context.read<
                BookingProvider>()); // Hızlı rotalar için de giriş kontrolü
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5))
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(imageUrl,
                          fit: BoxFit.cover, width: double.infinity)),
                  Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(price,
                              style: const TextStyle(
                                  color: Color(0xFF0077B6),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12))))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cityName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text("Istanbul",
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(width: 5),
                      Icon(Icons.arrow_forward,
                          size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 5),
                      Text(cityName,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.grey),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildVerticalDivider() =>
      Container(height: 30, width: 1, color: Colors.grey.shade200);
}

class _InteractiveButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  const _InteractiveButton({required this.child, required this.onPressed});
  @override
  State<_InteractiveButton> createState() => _InteractiveButtonState();
}

class _InteractiveButtonState extends State<_InteractiveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedOpacity(
          opacity: _isHovered ? 0.8 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
