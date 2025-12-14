import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../booking_provider.dart';
import 'boarding_pass_screen.dart';

class BookingSummaryScreen extends StatefulWidget {
  const BookingSummaryScreen({super.key});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _cardNumberCtrl = TextEditingController();
  final TextEditingController _expiryCtrl = TextEditingController();
  final TextEditingController _cvvCtrl = TextEditingController();

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final size = MediaQuery.of(context).size;
    bool isDesktop = size.width > 1000;

    return Scaffold(
      backgroundColor: const Color(0xFFECEFF1),
      appBar: AppBar(
        title: Text("Ödeme ve Onay",
            style: GoogleFonts.poppins(
                color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 3, child: _buildLeftSection(context, provider)),
                    const SizedBox(width: 30),
                    Expanded(
                        flex: 2, child: _buildRightSection(context, provider)),
                  ],
                )
              : Column(
                  children: [
                    _buildRightSection(context, provider),
                    const SizedBox(height: 20),
                    _buildLeftSection(context, provider),
                  ],
                ),
        ),
      ),
    );
  }

  // SOL BÖLÜM (AYNI KALDI)
  Widget _buildLeftSection(BuildContext context, BookingProvider provider) {
    return Column(
      children: [
        // 1. YOLCU BİLGİLERİ
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader("Yolcu Bilgileri", Icons.person),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: _buildInput(
                    label: "Ad Soyad",
                    icon: Icons.badge,
                    controller: provider.nameController,
                    validator: (v) =>
                        v!.isEmpty ? "İsim alanı boş bırakılamaz" : null,
                  )),
                  const SizedBox(width: 20),
                  Expanded(
                      child: _buildInput(
                    label: "Pasaport No",
                    icon: Icons.book,
                    controller: provider.passportController,
                    validator: (v) =>
                        v!.isEmpty ? "Pasaport alanı zorunludur" : null,
                  )),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: _buildInput(
                          label: "E-posta",
                          icon: Icons.email,
                          controller: provider.emailController,
                          validator: (v) => (v == null || !v.contains('@'))
                              ? "Geçersiz e-posta"
                              : null)),
                  const SizedBox(width: 20),
                  Expanded(
                      child: _buildInput(
                          label: "Telefon",
                          icon: Icons.phone,
                          controller: provider.phoneController,
                          isNumeric: true,
                          maxLength: 15,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            PhoneInputFormatter(),
                          ],
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Gerekli";
                            String raw = v.replaceAll(RegExp(r'\D'), '');
                            if (raw.length < 11) return "Eksik numara";
                            return null;
                          })),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 2. ÖDEME YÖNTEMİ
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader("Ödeme Yöntemi", Icons.credit_card),
              const SizedBox(height: 20),
              _buildCreditCardVisual(provider),
              const SizedBox(height: 25),
              _buildInput(
                label: "Kart Numarası",
                icon: Icons.credit_card,
                controller: _cardNumberCtrl,
                isNumeric: true,
                maxLength: 19,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CardNumberInputFormatter(),
                ],
                validator: (val) {
                  if (val == null || val.length < 19) {
                    return "Geçersiz kart numarası";
                  }
                  return null;
                },
                onChanged: (val) => setState(() {}),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                      child: _buildInput(
                    label: "SKT (Ay/Yıl)",
                    icon: Icons.calendar_today,
                    controller: _expiryCtrl,
                    isNumeric: true,
                    maxLength: 5,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      DateInputFormatter(),
                    ],
                    validator: (val) {
                      if (val == null || val.length < 5) return "Hatalı tarih";
                      int? month = int.tryParse(val.split('/')[0]);
                      if (month == null || month < 1 || month > 12) {
                        return "Geçersiz ay";
                      }
                      return null;
                    },
                    onChanged: (val) => setState(() {}),
                  )),
                  const SizedBox(width: 20),
                  Expanded(
                      child: _buildInput(
                    label: "CVV",
                    icon: Icons.lock,
                    controller: _cvvCtrl,
                    isNumeric: true,
                    maxLength: 3,
                    validator: (val) =>
                        (val == null || val.length < 3) ? "Eksik" : null,
                  )),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  // SAĞ BÖLÜM (ÖZET & OTOPARK GÜNCELLENDİ)
  Widget _buildRightSection(BuildContext context, BookingProvider provider) {
    final flight = provider.selectedFlight!;

    return Column(
      children: [
        // UÇUŞ ÖZETİ
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Gidiş Uçuşu",
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12)),
                        Text(flight.airlineName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ]),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(flight.flightNumber,
                        style: TextStyle(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFlightTime(flight.originCode, flight.departureTime),
                  const Icon(Icons.arrow_forward, color: Colors.grey),
                  _buildFlightTime(flight.destCode, flight.arrivalTime),
                ],
              ),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Koltuk", style: TextStyle(color: Colors.grey)),
                  Text(
                      "${provider.selectedSeat?.seatNumber} (${provider.selectedSeat?.classType})",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ),

        const SizedBox(height: 20),

        // --- GELİŞMİŞ OTOPARK SEÇİMİ ---
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              // Üst Kısım: Switch ve Başlık
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.local_parking,
                        color: Color(0xFF1565C0)),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Otopark Ekle",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1565C0))),
                        Text("Güvenli ve ekonomik park yeri",
                            style: TextStyle(
                                color: Colors.blue.shade700, fontSize: 12)),
                      ],
                    ),
                  ),
                  Switch(
                    value: provider.addParking,
                    activeColor: const Color(0xFF1565C0),
                    onChanged: (val) => provider.toggleParking(val),
                  )
                ],
              ),

              // Alt Kısım: Detaylar (Sadece seçiliyse göster)
              if (provider.addParking) ...[
                const SizedBox(height: 20),
                const Divider(color: Colors.white54),
                const SizedBox(height: 10),

                // 1. Araç Tipi Seçimi
                DropdownButtonFormField<String>(
                  value: provider.vehicleType,
                  decoration: InputDecoration(
                    labelText: "Araç Tipi",
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: "Motosiklet", child: Text("Motosiklet (0.8x)")),
                    DropdownMenuItem(
                        value: "Otomobil", child: Text("Otomobil (1.0x)")),
                    DropdownMenuItem(
                        value: "SUV", child: Text("SUV / Jeep (1.3x)")),
                    DropdownMenuItem(
                        value: "Kamyonet", child: Text("Kamyonet (1.5x)")),
                  ],
                  onChanged: (val) {
                    if (val != null) provider.setVehicleType(val);
                  },
                ),

                const SizedBox(height: 15),

                // 2. Tarih Aralığı Seçimi (Popup Modlu)
                InkWell(
                  onTap: () async {
                    DateTimeRange? picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                      initialDateRange: DateTimeRange(
                          start: provider.parkingStartDate,
                          end: provider.parkingEndDate),
                      builder: (context, child) {
                        return Center(
                          child: Container(
                            width: 350,
                            height: 500,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF1565C0),
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                    if (picked != null) {
                      provider.setParkingDates(picked.start, picked.end);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                              DateFormat("dd MMM")
                                  .format(provider.parkingStartDate),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const Text(" - "),
                          Text(
                              DateFormat("dd MMM")
                                  .format(provider.parkingEndDate),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ]),
                        Text("${provider.parkingDays} Gün",
                            style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // 3. YENİ: KAPIDA ÖDEME SEÇENEĞİ
                InkWell(
                  onTap: () =>
                      provider.setPayAtLocation(!provider.payAtLocation),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: provider.payAtLocation
                                ? const Color(0xFF1565C0)
                                : Colors.transparent,
                            width: 1.5)),
                    child: Row(
                      children: [
                        Checkbox(
                            value: provider.payAtLocation,
                            activeColor: const Color(0xFF1565C0),
                            onChanged: (val) =>
                                provider.setPayAtLocation(val!)),
                        const Expanded(
                          child: Text("Otoparkta Öde (Kapıda Ödeme)",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // 4. Fiyat Özeti
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Toplam Otopark:",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            "₺${provider.totalParkingPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                                color: Color(0xFF1565C0),
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        if (provider.payAtLocation)
                          const Text("(Kapıda)",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold))
                      ],
                    ),
                  ],
                )
              ]
            ],
          ),
        ),

        const SizedBox(height: 20),

        // FİYAT DÖKÜMÜ VE BUTON
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              _buildPriceRow("Uçuş Ücreti", "₺${flight.basePrice}"),
              _buildPriceRow("Vergiler & Harçlar", "₺450.00"),
              if (provider.selectedSeat?.classType == "First Class")
                _buildPriceRow(
                    "First Class Farkı", "+₺${flight.basePrice * 3}"),
              if (provider.selectedSeat?.classType == "Business")
                _buildPriceRow("Business Farkı", "+₺${flight.basePrice * 0.5}"),
              if (provider.addParking)
                _buildPriceRow(
                    "Otopark (${provider.vehicleType})",
                    provider.payAtLocation
                        ? "Kapıda Ödenecek"
                        : "+₺${provider.totalParkingPrice.toStringAsFixed(0)}",
                    color: Colors.blue),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TOPLAM",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("₺${provider.totalPrice + 450}",
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32))),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9F1C),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const BoardingPassScreen()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Lütfen hatalı alanları düzeltin."),
                            backgroundColor: Colors.redAccent),
                      );
                    }
                  },
                  child: const Text("ÖDEMEYİ TAMAMLA",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  // HELPER WIDGETS (AYNI)
  Widget _buildCreditCardVisual(BookingProvider provider) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1B263B), Color(0xFF415A77)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 10))
        ],
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.contactless, color: Colors.white70, size: 30),
              Text("BANK",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          ),
          Text(
              _cardNumberCtrl.text.isEmpty
                  ? "**** **** **** ****"
                  : _cardNumberCtrl.text,
              style: GoogleFonts.sourceCodePro(
                  color: Colors.white, fontSize: 22, letterSpacing: 2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Kart Sahibi",
                      style: GoogleFonts.sourceCodePro(
                          color: Colors.white70, fontSize: 10)),
                  Text(provider.nameController.text.toUpperCase(),
                      style: GoogleFonts.sourceCodePro(
                          color: Colors.white, fontSize: 14)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("SKT",
                      style: GoogleFonts.sourceCodePro(
                          color: Colors.white70, fontSize: 10)),
                  Text(_expiryCtrl.text.isEmpty ? "MM/YY" : _expiryCtrl.text,
                      style: GoogleFonts.sourceCodePro(
                          color: Colors.white, fontSize: 14)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1B263B)),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B263B))),
      ],
    );
  }

  Widget _buildInput({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    bool isNumeric = false,
    int? maxLength,
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      inputFormatters: inputFormatters,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      maxLength: maxLength,
      readOnly: readOnly,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF7F9FC),
        counterText: "",
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildFlightTime(String code, DateTime time) {
    return Column(
      children: [
        Text(DateFormat('HH:mm').format(time),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(code,
            style: const TextStyle(
                color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color ?? Colors.black)),
        ],
      ),
    );
  }
}

// FORMATLAYICILAR (AYNI)
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.isEmpty) return newValue.copyWith(text: '');
    var rawText = text;
    if (!rawText.startsWith('0')) rawText = '0$rawText';
    if (rawText.length > 11) rawText = rawText.substring(0, 11);
    var buffer = StringBuffer();
    for (int i = 0; i < rawText.length; i++) {
      buffer.write(rawText[i]);
      if (i == 3 || i == 6 || i == 8) {
        if (i != rawText.length - 1) buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}
