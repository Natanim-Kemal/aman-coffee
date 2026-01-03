import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/worker_item.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDtwDBdnrL1fGGeV5egRJBOMoWAN6cgZnFUvg2Y96d1gtct28S_VGiBo9M2LMhoxeU_uhIue5ekwdT1oJ9D6HqNsVRC6mqMRu9MStNPdxHRN2K_KJVyvj0_99LVyFgfsawjxOQap5uDrodiYCR8ihJk-4Qz7tECmYS2vTTDuXhoxYHZ2pVzHTB9CZXL5PQUMRtLPXE7tm8itP8H7we9aTN79TKuED1vs8c8eHYsHzkUOSMWX73Aon36RvH0Xi86pMtzy_xoepbTGIU'),
                              fit: BoxFit.cover
                            )
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textMutedDark,
                            ),
                          ),
                          Text(
                            'Admin',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: const [
                        Icon(Icons.notifications_outlined),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: CircleAvatar(
                            radius: 4,
                            backgroundColor: AppColors.primary,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              
              const SizedBox(height: 24),

              // Overview Title
              Text(
                'Overview',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Monday, 14 Oct 2023',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textMutedDark,
                ),
              ),

              const SizedBox(height: 24),

              // Float Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Row(
                           children: [
                             Container(
                               padding: const EdgeInsets.all(6),
                               decoration: BoxDecoration(
                                 color: AppColors.primary.withOpacity(0.1),
                                 borderRadius: BorderRadius.circular(8)
                               ),
                               child: const Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 20),
                             ),
                             const SizedBox(width: 12),
                             const Text('Daily Float', style: TextStyle(fontWeight: FontWeight.bold)),
                           ],
                         ),
                         Container( 
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                           decoration: BoxDecoration(
                             color: AppColors.primary.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(20)
                           ),
                           child: const Text('Update', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                         )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        children: [
                          Text('\$', style: TextStyle(color: Colors.grey.shade600, fontSize: 20)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '5000.00',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(Icons.edit, color: Colors.grey.shade600, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Stats Grid
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Distributed',
                      '\$3,200',
                      '+12%',
                      Colors.green,
                      Icons.trending_up
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Remaining',
                      '\$1,800',
                      '-8%',
                      Colors.red,
                      Icons.trending_down
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Utilization
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Fund Utilization', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Today', style: const TextStyle(color: AppColors.textMutedDark, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('64%', style: TextStyle(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.bold)),
                              const Text('of daily budget used', style: TextStyle(color: AppColors.textMutedDark, fontSize: 12)),
                            ],
                          ),
                        ),
                        CircularPercentIndicator(
                          radius: 40.0,
                          lineWidth: 8.0,
                          percent: 0.64,
                          center: const Icon(Icons.local_cafe, color: AppColors.primary),
                          progressColor: AppColors.primary,
                          backgroundColor: theme.scaffoldBackgroundColor,
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const Text('Active Workers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              
              // Activities
              ...kMockWorkers.take(3).map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: WorkerItem(worker: w, isDashboardMode: true),
              )),
              
               const SizedBox(height: 80), // Footer space
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, String change, Color color, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(label.toUpperCase(), style: const TextStyle(color: AppColors.textMutedDark, fontSize: 10, fontWeight: FontWeight.bold)),
           const SizedBox(height: 8),
           Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
           const SizedBox(height: 4),
           Row(
             children: [
               Icon(icon, color: color, size: 14),
               const SizedBox(width: 4),
               Text(change, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
             ],
           )
        ],
      ),
    );
  }
}
