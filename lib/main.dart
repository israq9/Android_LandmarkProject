import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:landmark_manager/providers/landmark_provider.dart';
import 'package:landmark_manager/utils/theme.dart';
import 'package:landmark_manager/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize providers and services here
  final landmarkProvider = LandmarkProvider();
  await landmarkProvider.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => landmarkProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Landmark Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRoutes.router, // Fixed: Changed AppRouter.router to AppRoutes.router
    );
  }
}
