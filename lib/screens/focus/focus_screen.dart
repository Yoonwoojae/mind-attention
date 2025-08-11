import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mind_attention/core/utils/translation_utils.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      tr('focus_title'),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: false,
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildListDelegate([
                      _buildToolCard(
                        context,
                        icon: Icons.timer_outlined,
                        iconColor: const Color(0xFF4CAF50),
                        title: tr('focus_adhd_timer'),
                        subtitle: tr('focus_adhd_timer_desc'),
                        route: '/focus/timer',
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                        ),
                      ),
                      _buildToolCard(
                        context,
                        icon: Icons.checklist_rtl_outlined,
                        iconColor: const Color(0xFF2196F3),
                        title: tr('focus_task_breakdown'),
                        subtitle: tr('focus_task_breakdown_desc'),
                        route: '/focus/task-breakdown',
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                        ),
                      ),
                      _buildToolCard(
                        context,
                        icon: Icons.refresh_outlined,
                        iconColor: const Color(0xFFFF9800),
                        title: tr('focus_reset'),
                        subtitle: tr('focus_reset_desc'),
                        route: '/focus/reset',
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                        ),
                      ),
                      _buildToolCard(
                        context,
                        icon: Icons.space_dashboard_outlined,
                        iconColor: const Color(0xFF9C27B0),
                        title: tr('focus_environment'),
                        subtitle: tr('focus_environment_desc'),
                        route: '/focus/environment',
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String route,
    required Gradient gradient,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(route);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black.withOpacity(0.7),
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

}