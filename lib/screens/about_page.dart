import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/mock_data.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ocean),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(gradient: AppColors.gradient2, borderRadius: BorderRadius.circular(7)),
              alignment: Alignment.center,
              child: const Text('⚡', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: 8),
            const Text('Intelligence Engineering', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.ocean)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
              child: const Column(
                children: [
                  Text('Misi Kami', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.ocean)),
                  SizedBox(height: 12),
                  Text(
                    'Menghadirkan solusi kecerdasan buatan yang inovatif untuk mendukung pengembangan teknologi masa depan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: AppColors.text2, height: 1.6),
                  ),
                ],
              ),
            ),

            // Team Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Meet Our Founders', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ocean)),
                  const SizedBox(height: 20),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                          boxShadow: const [BoxShadow(color: Color(0x1A0064B4), blurRadius: 16, offset: Offset(0, 2))],
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
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.cyan, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
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

            // Footer
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
}
