import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/providers/transaction_provider.dart';
import '../../../core/theme/app_theme.dart';

class WorkerTransactionsList extends StatefulWidget {
  final String workerId;

  const WorkerTransactionsList({super.key, required this.workerId});

  @override
  State<WorkerTransactionsList> createState() => _WorkerTransactionsListState();
}

class _WorkerTransactionsListState extends State<WorkerTransactionsList> {
  @override
  void initState() {
    super.initState();
    // Load transactions for this worker
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false)
          .loadWorkerTransactions(widget.workerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, _) {
        final transactions = transactionProvider.workerTransactions;

        if (transactions.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length > 5 ? 5 : transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return _buildTransactionItem(transaction);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Transactions will appear here',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(MoneyTransaction transaction) {
    Color typeColor;
    IconData typeIcon;
    bool isPositive = transaction.increasesBalance;

    switch (transaction.type.toLowerCase()) {
      case 'distribution':
        typeColor = Colors.green;
        typeIcon = Icons.add_circle;
        break;
      case 'return':
        typeColor = Colors.red;
        typeIcon = Icons.remove_circle;
        break;
      case 'purchase':
        typeColor = Colors.orange;
        typeIcon = Icons.shopping_cart;
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.receipt;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(typeIcon, color: typeColor, size: 20),
          ),

          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.typeDisplay,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy • h:mm a').format(transaction.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
                if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.notes!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Amount
          Text(
            '${isPositive ? '+' : '-'}ETB ${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: typeColor,
            ),
          ),
        ],
      ),
    );
  }
}
