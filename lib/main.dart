import 'package:flutter/material.dart';
import 'package:petro_world/route/router.dart' as router;
import 'package:petro_world/theme/app_theme.dart';
import 'package:petro_world/auth_gate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // Initialise Express-backend JWT token from local storage FIRST,
  // so every provider can correctly see isLoggedIn on first build.
  await ApiService.instance.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PETRO WORLD',
      theme: AppTheme.lightTheme(context),
      themeMode: ThemeMode.light,
      onGenerateRoute: router.generateRoute,
      home: const AuthGate(),
    );
  }
}
