import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/mock_data.dart';
import '../widgets/gradient_button.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.gradient2,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Text('⚡', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Intelligence Engineering',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.ocean),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GradientButton(
              text: 'Masuk ke Dashboard',
              onPressed: () => Navigator.pushNamed(context, '/login'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              fontSize: 12,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero Section ──
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Colors.white, AppColors.bg],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
              child: Column(
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: const Text(
                      '🚀 Platform Manajemen Sistem Cerdas',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ocean),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  const Text(
                    'Rancang & Kelola',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.ocean, height: 1.2),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => AppColors.gradient2.createShader(bounds),
                    child: const Text(
                      'Proyek AI Anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Subtitle
                  const Text(
                    'Platform terintegrasi untuk mengelola proyek kecerdasan buatan dari perencanaan hingga deployment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: AppColors.text2, height: 1.6),
                  ),
                  const SizedBox(height: 28),
                  // CTA
                  GradientButton(
                    text: 'Mulai Sekarang →',
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    fontSize: 15,
                  ),
                ],
              ),
            ),

            // ── Features Section ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
              child: Column(
                children: [
                  const Text(
                    'Fitur Utama',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ocean),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Semua yang Anda butuhkan untuk mengelola proyek AI',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.text2),
                  ),
                  const SizedBox(height: 28),
                  _featureCard('📋', 'Kanban Board Interaktif', 'Kelola alur kerja proyek dengan board visual yang intuitif dan drag-and-drop.'),
                  const SizedBox(height: 16),
                  _featureCard('🎯', 'Sprint & Backlog', 'Rencanakan sprint, kelola backlog, dan lacak progres tim secara real-time.'),
                  const SizedBox(height: 16),
                  _featureCard('📄', 'Manajemen Transkrip', 'Buat dan kelola transkrip proyek otomatis dengan export PDF.'),
                ],
              ),
            ),

            // ── About Us / Misi Kami Section ──
            Container(
              width: double.infinity,
              color: AppColors.bg,
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
              child: Column(
                children: [
                  const Text(
                    'Misi Kami',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.ocean),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(fontSize: 15, color: AppColors.text2, height: 1.7),
                      children: [
                        TextSpan(text: 'Kami membangun '),
                        TextSpan(text: 'Intelligence Engineering', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ocean)),
                        TextSpan(text: ' untuk menyederhanakan kompleksitas dalam perancangan sistem berbasis Artificial Intelligence. Melalui platform terpadu ini, tim pengembang dapat merencanakan objektif (Objectives), mengelola sprint, melacak bug (Issues), hingga mencetak dokumen perancangan secara transparan dan efisien.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Meet Our Founders ──
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 48),
              child: Column(
                children: [
                  const Text(
                    'Meet Our Founders',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ocean),
                  ),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: MockData.teamMembers.length,
                    itemBuilder: (context, index) {
                      final member = MockData.teamMembers[index];
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72, height: 72,
                              decoration: const BoxDecoration(
                                gradient: AppColors.gradient2,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                member.initial,
                                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              member.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ocean),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              member.role.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.cyan, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFBAE6FD)),
                              ),
                              child: Text(
                                member.nim,
                                style: const TextStyle(fontSize: 11, color: AppColors.text2),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Footer ──
            Container(
              width: double.infinity,
              color: AppColors.ocean,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Text(
                '© 2026 Intelligence Engineering - Kelompok 1.\nHak Cipta Dilindungi.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard(String icon, String title, String desc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Color(0x1A0064B4), blurRadius: 8, offset: Offset(0, 2))],
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ocean)),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(fontSize: 14, color: AppColors.text2, height: 1.5)),
        ],
      ),
    );
  }
}
