import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:latihan_responsi/network/api_service.dart';
import 'package:latihan_responsi/presenters/auth_presenter.dart';
import 'package:latihan_responsi/presenters/restaurant_presenter.dart';
import 'package:latihan_responsi/presenters/favorite_presenter.dart';
import 'package:latihan_responsi/utils/shared_prefs.dart';
import 'package:latihan_responsi/views/login_screen.dart';
import 'package:latihan_responsi/views/restaurant_list_screen.dart';
import 'package:latihan_responsi/views/favorite_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPrefs = SharedPrefs();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPrefs>(create: (_) => sharedPrefs),
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider(
          create: (context) => AuthPresenter(sharedPrefs), // Fixed to use sharedPrefs directly
        ),
        ChangeNotifierProvider(
          create: (context) => RestaurantPresenter(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => FavoritePresenter(sharedPrefs), // Fixed to use sharedPrefs directly
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder(
          future: Provider.of<AuthPresenter>(context, listen: false).getLoggedInUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return snapshot.hasData
                ? const RestaurantListScreen()
                : LoginScreen(
                    onLoginSuccess: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                  );
          },
        ),
        '/login': (context) => LoginScreen(
              onLoginSuccess: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
        '/home': (context) => const RestaurantListScreen(),
        '/favorites': (context) => const FavoriteScreen(), // Added favorite route
      },
    );
  }
}