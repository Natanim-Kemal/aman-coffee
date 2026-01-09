import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/transaction_provider.dart';
import '../../../../../core/utils/number_formatter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/worker_model.dart';
import '../widgets/worker_action_button.dart';
import '../widgets/worker_stat_card.dart';
import '../widgets/worker_transaction_tile.dart';

class WorkerHomeTab extends StatefulWidget {
  final Worker worker;
  final bool isDark;
  final VoidCallback onRefresh;
  final Function(Worker) onRecordReturn;
  final Function(Worker) onRecordPurchase;
  final VoidCallback onViewHistory;

  const WorkerHomeTab({
    super.key,
    required this.worker,
    required this.isDark,
    required this.onRefresh,
    required this.onRecordReturn,
    required this.onRecordPurchase,
    required this.onViewHistory,
  });

  @override
  State<WorkerHomeTab> createState() => _WorkerHomeTabState();
}

class _WorkerHomeTabState extends State<WorkerHomeTab> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: WorkerStatCard(
                  label: AppLocalizations.of(context)!.totalDistributed,
                  value: 'ETB ${widget.worker.totalDistributed.formatted}',
                  icon: Icons.arrow_downward,
                  color: Colors.orange,
                  isDark: widget.isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: WorkerStatCard(
                  label: AppLocalizations.of(context)!.totalReturned,
                  value: 'ETB ${widget.worker.totalReturned.formatted}',
                  icon: Icons.arrow_upward,
                  color: Colors.green,
                  isDark: widget.isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: WorkerStatCard(
                  label: AppLocalizations.of(context)!.coffeePurchased,
                  value: 'ETB ${widget.worker.totalCoffeePurchased.formatted}',
                  icon: Icons.local_cafe,
                  color: Colors.brown,
                  isDark: widget.isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: WorkerStatCard(
                  label: AppLocalizations.of(context)!.commissionEarned,
                  value: 'ETB ${widget.worker.totalCommissionEarned.formatted}',
                  icon: Icons.paid,
                  color: Colors.teal,
                  isDark: widget.isDark,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // Balance Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.currentBalance,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ETB ${widget.worker.currentBalance.formatted}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      widget.worker.currentBalance < 500 
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle,
                      color: widget.worker.currentBalance < 500 
                          ? Colors.orange 
                          : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.worker.currentBalance < 500 
                          ? AppLocalizations.of(context)!.lowBalanceWarning
                          : AppLocalizations.of(context)!.balanceGood,
                      style: TextStyle(
                        color: widget.worker.currentBalance < 500 
                            ? Colors.orange 
                            : Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: WorkerActionButton(
                  icon: Icons.arrow_upward,
                  label: AppLocalizations.of(context)!.recordReturn,
                  color: Colors.green,
                  onTap: () => widget.onRecordReturn(widget.worker),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: WorkerActionButton(
                  icon: Icons.shopping_cart,
                  label: AppLocalizations.of(context)!.recordPurchase,
                  color: Colors.blue,
                  onTap: () => widget.onRecordPurchase(widget.worker),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Transactions Preview
          _buildRecentTransactionsPreview(widget.isDark),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsPreview(bool isDark) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final transactions = provider.workerTransactions.take(3).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.recentActivity,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: widget.onViewHistory,
                  child: Text(
                    AppLocalizations.of(context)!.viewAll,
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (transactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.noTransactionsYet,
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ),
              )
            else
              ...transactions.map((tx) => WorkerTransactionTile(transaction: tx, isDark: isDark)),
          ],
        );
      },
    );
  }
}
