import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/transaction_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/transaction_model.dart';
import '../../widgets/stats_card.dart';
import '../../../core/services/report_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _dateFilter = 'Last 7 Days';
  String _typeFilter = 'All';
  
  final List<String> _dateOptions = ['Today', 'Last 7 Days', 'This Month', 'All Time'];
  final List<String> _typeOptions = ['All', 'Distribution', 'Return', 'Purchase'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false).loadAllTransactions();
    });
  }

  List<MoneyTransaction> _getFilteredTransactions(List<MoneyTransaction> allTransactions) {
    DateTime now = DateTime.now();
    DateTime? startDate;
    
    switch (_dateFilter) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Last 7 Days':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'All Time':
        startDate = null;
        break;
    }

    return allTransactions.where((t) {
      bool dateMatch = startDate == null || t.createdAt.isAfter(startDate);
      bool typeMatch = _typeFilter == 'All' || 
                       t.type.toLowerCase() == _typeFilter.toLowerCase();
      return dateMatch && typeMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final filteredTransactions = _getFilteredTransactions(transactionProvider.allTransactions);
    
    // Calculate summary
    double totalAmount = filteredTransactions.fold(0, (sum, t) => sum + t.amount);
    int count = filteredTransactions.length;
    double avgAmount = count > 0 ? totalAmount / count : 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reports',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                           if (filteredTransactions.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No data to export')),
                            );
                            return;
                          }
                          
                          try {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Preparing PDF Report...')),
                            );

                            await ReportService().generateTransactionReport(
                              filteredTransactions,
                              _dateFilter,
                              _typeFilter,
                            );
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error generating report: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterDropdown(
                          value: _dateFilter,
                          items: _dateOptions,
                          onChanged: (val) => setState(() => _dateFilter = val!),
                          icon: Icons.calendar_today,
                        ),
                        const SizedBox(width: 12),
                        _buildFilterDropdown(
                          value: _typeFilter,
                          items: _typeOptions,
                          onChanged: (val) => setState(() => _typeFilter = val!),
                          icon: Icons.filter_list,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Summary Cards
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Total Volume',
                            value: 'ETB ${totalAmount.toStringAsFixed(0)}',
                            icon: Icons.attach_money,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            title: 'Transactions',
                            value: '$count',
                            icon: Icons.receipt_long,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    StatsCard(
                      title: 'Average Transaction',
                      value: 'ETB ${avgAmount.toStringAsFixed(2)}',
                      icon: Icons.show_chart,
                      color: Colors.purple,
                    ),

                    const SizedBox(height: 24),

                    // Transaction List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Transactions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${filteredTransactions.length} records',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    if (filteredTransactions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'No transactions found',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = filteredTransactions[index];
                          return _buildTransactionItem(transaction);
                        },
                      ),
                      
                    const SizedBox(height: 80), // Bottom padding for nav bar
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(MoneyTransaction transaction) {
    Color getAmountColor() {
      switch (transaction.type.toLowerCase()) {
        case 'distribution': return Colors.green;
        case 'return': return Colors.red;
        case 'purchase': return Colors.orange;
        default: return Colors.black;
      }
    }

    String getSign() {
       switch (transaction.type.toLowerCase()) {
        case 'distribution': return '+'; // Or maybe just normal? Distribution increases worker balance (debt) or wallet? Actually distribution is MONEY GIVEN TO WORKER.
        // Wait, logic:
        // Distribute: Money goes OUT of company.
        // Return: Money comes IN to company.
        // But for Worker Balance: Distribute INCREASES debt. Return DECREASES debt.
        
        // Let's stick to simple logic:
        // Distribution: Green (Positive flow to worker)
        // Return: Red (Negative flow from worker)
        // Purchase: Orange (Expense)
        
        // Actually, typically:
        // Money OUT (Distribution) = Red
        // Money IN (Return) = Green
        // But here it tracks "Worker's Held Money". So Distribution = +Balance.
        
        return '';
      }
      return '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              transaction.typeIcon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.workerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  DateFormat('MMM d, h:mm a').format(transaction.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'ETB ${transaction.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: getAmountColor(),
                ),
              ),
              Text(
                transaction.typeDisplay,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMutedLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
