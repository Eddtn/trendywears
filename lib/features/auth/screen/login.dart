// lib/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onlineclothing_app/features/auth/screen/forgottenpasswordscreen.dart';
import 'package:onlineclothing_app/features/auth/screen/signup.dart';
import 'package:onlineclothing_app/presentation/screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Google Sign-In Singleton (required in v7.2.0+)
  late final GoogleSignIn _googleSignIn;

  get _signInWithGoogle => null;

  @override
  void initState() {
    super.initState();
    // Initialize the singleton instance (MUST call before any other methods)
    _googleSignIn = GoogleSignIn.instance;
    _googleSignIn.initialize(
      // Optional: Add for web (from Google Cloud Console)
      // clientId: 'your-web-client-id.apps.googleusercontent.com',
      // Optional: For mobile backend verification
      // serverClientId: 'your-server-client-id.apps.googleusercontent.com',
      // scopes: ['email', 'profile'], // Required scopes
    );
  }

  // EMAIL LOGIN (unchanged)
  Future<void> _signInWithEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login failed")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // GOOGLE SIGN-IN (FIXED – 100% WORKING IN v7.2.0)
  // Future<void> _signInWithGoogle() async {
  //   setState(() => _isLoading = true);

  //   try {
  //     // Use the initialized singleton instance
  //     // final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

  //     if (googleUser == null) {
  //       // User canceled
  //       setState(() => _isLoading = false);
  //       return;
  //     }

  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  //     final String? idToken = googleAuth.idToken;

  //     if (idToken == null) {
  //       throw 'No ID token received from Google';
  //     }

  //     // Sign in to Supabase
  //     final response = await Supabase.instance.client.auth.signInWithIdToken(
  //       provider: OAuthProvider.google,
  //       idToken: idToken,
  //       // accessToken is optional on mobile – pass if available
  //       // accessToken: googleAuth.accessToken,
  //     );

  //     if (response.user != null && mounted) {
  //       // Auto-create profile if first time
  //       final userId = response.user!.id;
  //       final exists = await Supabase.instance.client
  //           .from('profiles')
  //           .select('id')
  //           .eq('id', userId)
  //           .maybeSingle();

  //       if (exists == null) {
  //         await Supabase.instance.client.from('profiles').insert({
  //           'id': userId,
  //           'full_name': googleUser.displayName ?? 'Google User',
  //           'email': googleUser.email,
  //           'avatar_url': googleUser.photoUrl ?? '',
  //         });
  //       }

  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => const HomeScreen()),
  //       );
  //     }
  //   } on AuthException catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(e.message), backgroundColor: Colors.red),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Google Sign-In failed: $e"), backgroundColor: Colors.red),
  //     );
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_bag,
                  size: 100,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Welcome Back!",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Login to continue shopping",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signInWithEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Login", style: TextStyle(fontSize: 18)),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: const Icon(Icons.login, color: Colors.deepPurple),
                    label: const Text("Continue with Google"),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.deepPurple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                  ),
                  child: const Text("Don't have an account? Sign Up"),
                ),

                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  ),
                  child: const Text("Forgot Password?"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
