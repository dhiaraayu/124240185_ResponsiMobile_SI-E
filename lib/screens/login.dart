import 'package:flutter/material.dart';

import '../services/local_storage.dart';
import 'resep_list.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isChecking = true; // true selama mengecek status login di awal
  bool isLoginFailed = false; // true kalau login gagal

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() async {
    final adaLogin = await LocalStorage.isLoggedIn();

    if (!mounted) return;

    if (adaLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ResepListScreen()),
      );
    } else {
      setState(() {
        isChecking = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        isLoginFailed = true;
      });
      _showError('Username dan password harus diisi!');
      return;
    }

    final berhasil = await LocalStorage.login(username, password);

    if (!mounted) return;

    if (berhasil) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ResepListScreen()),
      );
    } else {
      setState(() {
        isLoginFailed = true;
      });
      _showError('Username atau password salah!');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    final borderColor = isLoginFailed ? Colors.red : Color(0xFF722F37);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Color(0xFF722F37)),
          filled: true,
          fillColor: Color(0xFFFFFDF5),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: borderColor, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: borderColor, width: 2.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: Color(0xFF722F37),
        foregroundColor: Colors.white,
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: isChecking
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF722F37)),
            )
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Selamat Datang di Resep Masakan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF722F37),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _inputField(
                      controller: _usernameController,
                      hint: 'Username',
                      icon: Icons.person,
                    ),
                    _inputField(
                      controller: _passwordController,
                      hint: 'Password',
                      icon: Icons.lock,
                      obscure: true,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 160,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFC72C),
                          foregroundColor: Color(0xFF722F37),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: _login,
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
