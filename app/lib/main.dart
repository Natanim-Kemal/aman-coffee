import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'core/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/audit_provider.dart';
import 'core/providers/worker_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/services/offline_sync_service.dart';
import 'core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/providers/transaction_provider.dart';
import 'presentation/widgets/custom_bottom_nav.dart';
import 'presentation/widgets/offline_indicator.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/reports/reports_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/worker_list/worker_list_screen.dart';
import 'presentation/screens/worker/worker_dashboard_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase already initialized, continue
    if (!e.toString().contains('duplicate-app')) {
      rethrow;
    }
  }

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize offline services
  final offlineSyncService = OfflineSyncService();
  await offlineSyncService.initialize();
  
  runApp(StitchWorkerApp(
    notificationService: notificationService,
    offlineSyncService: offlineSyncService,
  ));
}

class StitchWorkerApp extends StatelessWidget {
  final NotificationService notificationService;
  final OfflineSyncService offlineSyncService;
  
  const StitchWorkerApp({
    super.key,
    required this.notificationService,
    required this.offlineSyncService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: notificationService),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WorkerProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuditProvider()),
      ],
      child: Consumer2<ThemeProvider, SettingsProvider>(
        builder: (context, themeProvider, settingsProvider, _) {
          return MaterialApp(
            title: 'Cofiz',
            // Locale
            locale: settingsProvider.locale,
            
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), 
              Locale('am'),
            ],
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

/// Auth gate to check if user is logged in
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        print('DEBUG AuthGate: status = ${authProvider.status}, isAuthenticated = ${authProvider.isAuthenticated}');
        
        // Show loading while checking auth state or during sign out
        if (authProvider.status == AuthStatus.uninitialized || 
            authProvider.status == AuthStatus.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Not authenticated - show login
        if (!authProvider.isAuthenticated) {
          print('DEBUG AuthGate: Not authenticated, showing LoginScreen');
          return const LoginScreen();
        }

        // Check if user role is loaded
        if (authProvider.userRole == null) {
          // User authenticated but no Firestore document found
          // This means user was not manually created by admin
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Account Not Set Up',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your account has not been configured yet. Please contact an administrator to set up your account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await authProvider.signOut();
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Route based on role
        print('DEBUG ROUTING: userRole = ${authProvider.userRole}');
        print('DEBUG ROUTING: workerId = ${authProvider.workerId}');
        
        switch (authProvider.userRole!) {
          case UserRole.admin:
            print('DEBUG ROUTING: Routing to MainLayout (admin)');
            return const MainLayout();
          case UserRole.viewer:
            print('DEBUG ROUTING: Routing to MainLayout (viewer)');
            return const MainLayout();
            
          case UserRole.worker:
            print('DEBUG ROUTING: Routing to WorkerDashboardScreen');
            // Workers go to their own dashboard
            if (authProvider.workerId != null) {
              return WorkerDashboardScreen(
                workerId: authProvider.workerId!,
              );
            } else {
              print('DEBUG ROUTING: ERROR - Worker has no workerId!');
              return const Scaffold(
                body: Center(
                  child: Text('Error: Worker account not properly configured'),
                ),
              );
            }
        }
      },
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
  late PageController _pageController;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const WorkerListScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _screens,
          ),
          
          // Offline Indicator
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: OfflineIndicator(),
          ),
          
          // Fixed Bottom Nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNav(
              currentIndex: _currentIndex,
              onTap: _onNavTap,
            ),
          ),
        ],
      ),
    );
  }
}
