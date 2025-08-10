import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pesticides/screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set memory limits for better performance
  // This helps prevent OOM crashes
  const int megabyte = 1024 * 1024;

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('formBox');

  // Allow all orientations by default
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set image cache size limits to prevent memory issues with large datasets
  PaintingBinding.instance.imageCache.maximumSize =
      50; // Further reduce for 200+ entries
  PaintingBinding.instance.imageCache.maximumSizeBytes =
      30 * megabyte; // More conservative limit for large datasets

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IPCS App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
