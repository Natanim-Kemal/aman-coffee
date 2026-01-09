import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/worker_provider.dart';
import '../../../core/providers/transaction_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/worker_model.dart';
import '../../../core/models/transaction_model.dart';
import '../../widgets/custom_header.dart';
import '../settings/settings_screen.dart';
import 'tabs/worker_home_tab.dart';
import 'tabs/worker_history_tab.dart';
import 'dialogs/record_return_dialog.dart';
import 'dialogs/record_purchase_dialog.dart';
import '../notifications/notifications_screen.dart';
import '../../widgets/background_pattern.dart';
import '../../widgets/notification_badge.dart';

class WorkerDashboardScreen extends StatefulWidget {
  final String workerId;

  const WorkerDashboardScreen({
    super.key,
    required this.workerId,
  });

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load worker's transactions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false)
          .loadWorkerTransactions(widget.workerId);
    });
  }

  void _showRecordReturnDialog(Worker worker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RecordReturnDialog(
        worker: worker,
        onSuccess: () {
          setState(() {}); // Refresh dashboard to show new balance
          // Reload transactions
          Provider.of<TransactionProvider>(context, listen: false)
            .loadWorkerTransactions(widget.workerId);
        },
      ),
    );
  }

  void _showRecordPurchaseDialog(Worker worker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RecordPurchaseDialog(
        worker: worker,
        onSuccess: () {
          setState(() {}); // Refresh dashboard
           // Reload transactions
          Provider.of<TransactionProvider>(context, listen: false)
            .loadWorkerTransactions(widget.workerId);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final workerProvider = Provider.of<WorkerProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FutureBuilder<Worker?>(
      future: workerProvider.getWorkerById(widget.workerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Worker data not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => authProvider.signOut(),
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            ),
          );
        }

        final worker = snapshot.data!;

        return Scaffold(
          body: Stack(
            children: [
              const BackgroundPattern(),
              Column(
            children: [
              // Hide header on Settings screen to avoid double headers
              if (_currentIndex != 2)
              CustomHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome Back,',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              worker.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                         Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.white),
                                tooltip: 'Refresh',
                                onPressed: () => setState(() {}),
                              ),
                            ),
                            NotificationBadge(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const NotificationsScreen(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    WorkerHomeTab(
                      worker: worker,
                      isDark: isDark,
                      onRefresh: () {
                        setState(() {});
                        Provider.of<TransactionProvider>(context, listen: false)
                            .loadWorkerTransactions(widget.workerId);
                      },
                      onRecordReturn: _showRecordReturnDialog,
                      onRecordPurchase: _showRecordPurchaseDialog,
                      onViewHistory: () => setState(() => _currentIndex = 1),
                    ),
                    WorkerHistoryTab(
                      worker: worker, 
                      isDark: isDark,
                      onRefresh: () {
                         Provider.of<TransactionProvider>(context, listen: false)
                            .loadWorkerTransactions(widget.workerId);
                      }
                    ),
                    const SettingsScreen(),
                  ],
                ),
              ),
            ],
          ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: AppColors.primary,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            iconSize: 24,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded), // Uniform with Admin Dashboard
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined), // Uniform with Admin Settings
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
