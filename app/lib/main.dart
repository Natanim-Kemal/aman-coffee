import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/worker_list/worker_list_screen.dart';
import 'presentation/widgets/custom_bottom_nav.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/reports/reports_screen.dart';

void main() {
  runApp(const StitchWorkerApp());
}

class StitchWorkerApp extends StatelessWidget {
  const StitchWorkerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stitch Worker List',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const WorkerListScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],
          
          // Fixed Bottom Nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
