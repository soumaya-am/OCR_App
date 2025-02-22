import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  // void _login() {
  //   if (_formKey.currentState!.validate()) {
  //     // Handle login logic here
  //     if (_emailController.text == 'admin@gmail.com' &&
  //         _passwordController.text == '123456') {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Login successful')),
  //       );
  //       Navigator.pushNamed(context, '/home');
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Invalid email or password')),
  //       );
  //     }
  //   }
  // }
  // Future<void> _login() async {
  //   if (_formKey.currentState!.validate()) {
  //     // Simuler un délai de connexion
  //     await Future.delayed(const Duration(seconds: 1));

  //     if (_emailController.text == 'admin@gmail.com' &&
  //         _passwordController.text == '123456') {
  //       _showSnackbar('Login successful');
  //       Navigator.pushNamed(context, '/home');
  //     } else {
  //       _showSnackbar('Invalid email or password');
  //     }
  //   }
  // }
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        _showSnackbar(
            'Login successful: Welcome ${userCredential.user?.email}');
        Navigator.pushNamed(context, '/home');
      } catch (e) {
        _showSnackbar('Login failed: ${e.toString()}');
      }
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateToRegister() {
    // Navigate to the Register screen
    Navigator.pushNamed(context, '/register');
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(r'^[\w-]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
        actions: [
          TextButton.icon(
            onPressed: _navigateToRegister,
            icon: const Icon(Icons.person_add),
            label: const Text("Register"),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  "assets/images/logo.jpg",
                  width: 200, // Largeur en pixels
                  height: 200, // Hauteur en pixels
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _login,
                  label: const Text("Login"),
                  icon: const Icon(Icons.login),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
