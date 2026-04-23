import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums/user_role.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/report_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/common/isnad_app_bar.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/report/report_list_item.dart';

class CommandHomeScreen extends StatefulWidget {
  const CommandHomeScreen({super.key});

  @override
  State<CommandHomeScreen> createState() => _CommandHomeScreenState();
}

class _CommandHomeScreenState extends State<CommandHomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await context.read<ReportProvider>().loadReports();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final rp = context.watch<ReportProvider>();
    final userName = auth.currentUser?.fullName ?? '—';
    final roleLabel = auth.userRole.displayName;
    final unit = auth.currentUser?.unit;
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: IsnadAppBar(
        title: 'العمليات',
        onProfileTap: () {
          Navigator.of(context).pushNamed('/profile');
        },
        onNotificationsTap: () {
          Navigator.of(context).pushNamed('/notifications');
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.borderColor, width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.badge_outlined, color: AppColors.goldPrimary, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName, style: AppTextStyles.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(roleLabel, style: AppTextStyles.caption),
                        if (unit != null && unit.isNotEmpty)
                          Text(unit, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: IsnadMiniButton(
                    label: 'خريطة مباشرة',
                    onTap: () => Navigator.of(context).pushNamed('/live_map'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: IsnadMiniButton(
                    label: 'الملف الشخصي',
                    onTap: () => Navigator.of(context).pushNamed('/profile'),
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabs,
            labelColor: AppColors.goldPrimary,
            unselectedLabelColor: AppColors.silverDark,
            indicatorColor: AppColors.goldPrimary,
            tabs: const [
              Tab(text: 'البلاغات النشطة'),
              Tab(text: 'الكل'),
            ],
          ),
          Expanded(
            child: LoadingOverlay(
              loading: rp.isLoading,
              child: TabBarView(
                controller: _tabs,
                children: [
                  _ReportList(
                    reports: rp.reports.where((r) => r.status != 'closed').toList(),
                  ),
                  _ReportList(reports: rp.reports),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportList extends StatelessWidget {
  const _ReportList({required this.reports});

  final List<ReportModel> reports;

  @override
  Widget build(BuildContext context) {
    final list = reports;
    if (list.isEmpty) {
      return Center(
        child: Text('لا توجد بلاغات', style: AppTextStyles.bodyMedium),
      );
    }
    return RefreshIndicator(
      color: AppColors.goldPrimary,
      onRefresh: () => context.read<ReportProvider>().refreshReports(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenHorizontal,
          vertical: AppDimensions.screenVertical,
        ),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final r = list[i];
          return ReportListItem(
            report: r,
            onTap: () {
              Navigator.of(context).pushNamed(
                '/report_detail',
                arguments: {'reportId': r.id ?? 0},
              );
            },
          );
        },
      ),
    );
  }
}

class IsnadMiniButton extends StatelessWidget {
  const IsnadMiniButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.borderColor, width: 0.5),
        ),
        child: Text(label, style: AppTextStyles.buttonTextSecondary),
      ),
    );
  }
}
