import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/worker_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/worker_item.dart';
import '../../widgets/stats_card.dart';
import '../worker_form/worker_form_screen.dart';
import '../worker_detail/worker_detail_screen.dart';

class WorkerListScreen extends StatefulWidget {
  const WorkerListScreen({super.key});

  @override
  State<WorkerListScreen> createState() => _WorkerListScreenState();
}

class _WorkerListScreenState extends State<WorkerListScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'all'; // 'all', 'active', 'busy', 'offline'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    Provider.of<WorkerProvider>(context, listen: false).setSearchQuery(query);
  }

  void _onFilterChanged(String filter) {
    setState(() => _selectedFilter = filter);
    Provider.of<WorkerProvider>(context, listen: false).setStatusFilter(filter);
  }

  Future<void> _onRefresh() async {
    await Provider.of<WorkerProvider>(context, listen: false).refresh();
  }

  void _navigateToAddWorker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WorkerFormScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // backgroundColor: AppColors.backgroundLight, // Removed for theme support
      body: Consumer<WorkerProvider>(
          builder: (context, workerProvider, _) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Container(
                      color: AppColors.primary,
                      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Workers',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          const SizedBox(height: 20),

                          // Search Bar
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                hintText: 'Search workers...',
                                hintStyle: TextStyle(
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                  size: 20,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: AppColors.textMutedLight,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          _onSearchChanged('');
                                        },
                                      )
                                    : IconButton(
                                        icon: Icon(
                                          Icons.filter_list,
                                          color: AppColors.textMutedLight,
                                          size: 20,
                                        ),
                                        onPressed: () => _showFilterDialog(),
                                      ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Statistics Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: StatsCard(
                              title: 'Total',
                              value: '${workerProvider.totalWorkers}',
                              icon: Icons.people,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatsCard(
                              title: 'Active',
                              value: '${workerProvider.activeToday}',
                              icon: Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Filter Chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', 'all'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Active', 'active'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Busy', 'busy'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Offline', 'offline'),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // Workers List
                  if (workerProvider.isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (workerProvider.errorMessage != null)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                            const SizedBox(height: 16),
                            Text(
                              workerProvider.errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _onRefresh,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (workerProvider.workers.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_off_outlined,
                              size: 64,
                              color: AppColors.textMutedLight,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'No workers found'
                                  : 'No workers yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textMutedLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'Try adjusting your search'
                                  : 'Tap + to add your first worker',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final worker = workerProvider.workers[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: WorkerItem(
                                name: worker.name,
                                role: worker.role,
                                yearsOfExperience: worker.yearsOfExperience,
                                status: worker.statusDisplay,
                                rating: worker.ratingStars,
                                photoUrl: worker.photoUrl,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WorkerDetailScreen(workerId: worker.id),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          childCount: workerProvider.workers.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          onPressed: _navigateToAddWorker,
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => _onFilterChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Workers'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All'),
              leading: Radio<String>(
                value: 'all',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  if (value != null) {
                    _onFilterChanged(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Active'),
              leading: Radio<String>(
                value: 'active',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  if (value != null) {
                    _onFilterChanged(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Busy'),
              leading: Radio<String>(
                value: 'busy',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  if (value != null) {
                    _onFilterChanged(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Offline'),
              leading: Radio<String>(
                value: 'offline',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  if (value != null) {
                    _onFilterChanged(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
