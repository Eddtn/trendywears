import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onlineclothing_app/features/auth/screen/login.dart';
import 'package:onlineclothing_app/presentation/screens/home_screen.dart';
import 'package:onlineclothing_app/presentation/view_model/cart_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ztkhbhqugfoeslygnify.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp0a2hiaHF1Z2ZvZXNseWduaWZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUwMzQ5OTEsImV4cCI6MjA4MDYxMDk5MX0.HIXqVpHKEQdYejoaXrH0yoepMqaYsdnLZ9o4WvQkGeI',
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        // Add other ViewModels here later
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        locale: DevicePreview.locale(context),
        debugShowCheckedModeBanner: false,
        builder: DevicePreview.appBuilder,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),

        home: AuthWrapper(),

        //  HomeScreen(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return user == null ? const LoginScreen() : const HomeScreen();
  }
}
