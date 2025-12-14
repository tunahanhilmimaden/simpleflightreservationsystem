import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../booking_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true; // true: Giriş, false: Kayıt
  final _formKey = GlobalKey<FormState>();

  // Kontrolcüler
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<BookingProvider>();
    String result;

    if (_isLogin) {
      // GİRİŞ YAP
      result = provider.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
    } else {
      // KAYIT OL
      result = provider.register(
          _nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text.trim());
    }

    if (result == "success") {
      // Başarılı
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isLogin
            ? "Hoşgeldin, ${provider.nameController.text}!"
            : "Kayıt Başarılı! Hoşgeldin."),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context, true); // Geri dön
    } else {
      // Hata (Kullanıcı zaten var veya şifre yanlış)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
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

          Positioned(top: -50, right: -50, child: _buildCircle(300)),
          Positioned(bottom: 100, left: -50, child: _buildCircle(200)),

          // 2. FORM KARTI
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flight_takeoff,
                      size: 60, color: Colors.white),
                  const SizedBox(height: 10),
                  Text("SkyRes",
                      style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10))
                        ]),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_isLogin ? "Giriş Yap" : "Kayıt Ol",
                              style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF023E8A))),
                          const SizedBox(height: 5),
                          Text(
                              _isLogin
                                  ? "Devam etmek için giriş yapın"
                                  : "Hızlıca yeni hesap oluşturun",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14)),

                          const SizedBox(height: 30),

                          // İsim Alanı (Sadece Kayıt ise)
                          if (!_isLogin) ...[
                            _buildInput("Ad Soyad", Icons.person, _nameCtrl,
                                validator: (val) {
                              if (val == null || val.length < 3)
                                return "En az 3 harf giriniz";
                              return null;
                            }),
                            const SizedBox(height: 20),
                          ],

                          _buildInput("E-posta", Icons.email, _emailCtrl,
                              validator: (val) {
                            if (val == null || val.isEmpty)
                              return "E-posta gerekli";
                            // Basit Email Regex
                            final bool emailValid = RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(val);
                            if (!emailValid)
                              return "Geçerli bir e-posta giriniz";
                            return null;
                          }),

                          const SizedBox(height: 20),

                          _buildInput("Şifre", Icons.lock, _passCtrl,
                              isPassword: true, validator: (val) {
                            if (val == null || val.length < 6)
                              return "Şifre en az 6 karakter olmalı";
                            return null;
                          }),

                          const SizedBox(height: 30),

                          // BUTON
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF9F1C),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  elevation: 5),
                              child: Text(_isLogin ? "GİRİŞ YAP" : "KAYIT OL",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Center(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  _formKey.currentState?.reset();
                                  _emailCtrl.clear();
                                  _passCtrl.clear();
                                  _nameCtrl.clear();
                                });
                              },
                              child: RichText(
                                text: TextSpan(
                                    text: _isLogin
                                        ? "Hesabın yok mu? "
                                        : "Zaten hesabın var mı? ",
                                    style: const TextStyle(color: Colors.grey),
                                    children: [
                                      TextSpan(
                                          text: _isLogin
                                              ? "Kayıt Ol"
                                              : "Giriş Yap",
                                          style: const TextStyle(
                                              color: Color(0xFF023E8A),
                                              fontWeight: FontWeight.bold))
                                    ]),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInput(String label, IconData icon, TextEditingController ctrl,
      {bool isPassword = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF7F9FC),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
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
