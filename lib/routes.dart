import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:landmark_manager/views/form/form_screen.dart';
import 'package:landmark_manager/views/map/map_screen.dart';
import 'package:landmark_manager/views/records/records_screen.dart';

class AppRoutes {
  static const String map = '/';
  static const String records = '/records';
  static const String addLandmark = '/add';
  static const String editLandmark = '/edit';

  static final router = GoRouter(
    initialLocation: map,
    routes: [
      // Bottom navigation shell
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          // Map Screen
          GoRoute(
            path: map,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MapScreen(),
            ),
          ),
          
          // Records Screen
          GoRoute(
            path: records,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RecordsScreen(),
            ),
          ),
        ],
      ),
      
      // Add Landmark Screen
      GoRoute(
        path: addLandmark,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const FormScreen(),
        ),
      ),
      
      // Edit Landmark Screen
      GoRoute(
        path: '$editLandmark/:id',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return MaterialPage(
            key: state.pageKey,
            child: FormScreen(landmarkId: id),
          );
        },
      ),
    ],
  );
}

class MainScaffold extends StatefulWidget {
  final Widget child;
  
  const MainScaffold({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              context.go(AppRoutes.map);
              break;
            case 1:
              context.go(AppRoutes.records);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_outlined),
            activeIcon: Icon(Icons.list),
            label: 'Records',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () => context.go(AppRoutes.addLandmark),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
