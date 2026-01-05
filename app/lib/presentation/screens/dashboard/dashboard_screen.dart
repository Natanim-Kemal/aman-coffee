import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/worker_provider.dart';
import '../../../core/providers/transaction_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/activity_chart.dart';
import '../worker_detail/worker_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      transactionProvider.loadTodayTotals();
      transactionProvider.loadAllTransactions(); // Load for chart
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final workerProvider = Provider.of<WorkerProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get chart data
    final distributedData = _getLast7DaysData('distribution');
    final returnedData = _getLast7DaysData('return');
    final labels = _getLast7DaysLabels();

    return Scaffold(
      // backgroundColor: AppColors.backgroundLight, // Removed to use Theme background
      body: RefreshIndicator(
        onRefresh: () async {
          await workerProvider.refresh();
          await transactionProvider.loadTodayTotals();
          transactionProvider.loadAllTransactions();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                           authProvider.user?.displayName ?? 'User',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Date
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 24),

                // Today's Overview Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Today's Activity",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTodayStatItem(
                              'Distributed',
                              'ETB ${transactionProvider.todayDistributed.toStringAsFixed(0)}',
                              Icons.arrow_downward,
                              Colors.white,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.white24,
                          ),
                          Expanded(
                            child: _buildTodayStatItem(
                              'Returned',
                              'ETB ${transactionProvider.todayReturned.toStringAsFixed(0)}',
                              Icons.arrow_upward,
                              Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.white24),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Net Balance',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'ETB ${transactionProvider.todayNet.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),


                const SizedBox(height: 24),

                // Compact Stats
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCompactStat(context, Icons.people, '${workerProvider.totalWorkers}', 'Total', Colors.blue),
                      _buildContainerDivider(isDark),
                      _buildCompactStat(context, Icons.check_circle, '${workerProvider.activeToday}', 'Active', Colors.green),
                      _buildContainerDivider(isDark),
                      _buildCompactStat(context, Icons.star, '${workerProvider.avgPerformance.toStringAsFixed(0)}%', 'Perf', Colors.amber),
                      _buildContainerDivider(isDark),
                      _buildCompactStat(context, Icons.local_cafe, '${transactionProvider.todayPurchased.toStringAsFixed(0)}', 'Sales', Colors.brown),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Activity Chart
                ActivityChart(
                  distributedData: distributedData,
                  returnedData: returnedData,
                  labels: labels,
                ),

                const SizedBox(height: 24),

                // Active Workers Section
                if (workerProvider.workers.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active Workers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to workers tab
                          DefaultTabController.of(context)?.animateTo(1);
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...workerProvider.workers
                      .where((w) => w.status == 'active')
                      .take(3)
                      .map((worker) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        WorkerDetailScreen(workerId: worker.id),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  // Avatar
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary.withOpacity(0.1),
                                    ),
                                    child: Center(
                                      child: Text(
                                        worker.name.substring(0, 2).toUpperCase(),
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          worker.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          worker.role,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textMutedLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Balance
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'ETB ${worker.currentBalance.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          worker.statusDisplay,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.person_add_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No workers yet',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add workers to get started',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<double> _getLast7DaysData(String type) {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final transactions = transactionProvider.allTransactions;
    final now = DateTime.now();
    List<double> data = [];

    // Map the string type to what we have in the database/model
    // 'distribution' matches DB
    // 'return' matches DB
    
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final startOfDay = DateTime(day.year, day.month, day.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final dailySum = transactions
          .where((t) =>
              t.type.toLowerCase() == type.toLowerCase() &&
              t.createdAt.isAfter(startOfDay) &&
              t.createdAt.isBefore(endOfDay))
          .fold(0.0, (sum, t) => sum + t.amount);
      
      data.add(dailySum);
    }
    return data;
  }

  List<String> _getLast7DaysLabels() {
    final now = DateTime.now();
    List<String> labels = [];
    
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      labels.add(DateFormat('E').format(day));
    }
    return labels;
  }

  Widget _buildTodayStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }


  Widget _buildCompactStat(BuildContext context, IconData icon, String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildContainerDivider(bool isDark) {
    return Container(
      width: 1,
      height: 40,
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
    );
  }
}
