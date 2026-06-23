import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/mock_data.dart';
import '../widgets/service_card_widget.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(scaffoldBackgroundColor: AppColors.darkBg),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              backgroundColor: AppColors.darkBg.withValues(alpha: 0.9),
              floating: true,
              title: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(gradient: AppColors.darkGradient, borderRadius: BorderRadius.circular(7)),
                    alignment: Alignment.center,
                    child: const Text('⚡', style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 8),
                  const Text('Services', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.darkTextPrimary)),
                ],
              ),
              automaticallyImplyLeading: false,
            ),

            // Hero
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => AppColors.darkGradient.createShader(bounds),
                      child: const Text(
                        'Our Services',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Solusi AI terdepan untuk transformasi digital bisnis Anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.darkTextSecondary),
                    ),
                  ],
                ),
              ),
            ),

            // Services Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ServiceCardWidget(service: MockData.services[index]),
                  childCount: MockData.services.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
              ),
            ),

            // Tech Stack
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.darkBgSecondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Our Technology Stack',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.darkTextPrimary),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Powered by industry-leading tools',
                      style: TextStyle(fontSize: 13, color: AppColors.darkTextSecondary),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16, runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: MockData.techStack.map((t) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.darkCardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.darkBorder),
                            ),
                            alignment: Alignment.center,
                            child: Text(t['icon']!, style: const TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(height: 6),
                          Text(t['name']!, style: const TextStyle(fontSize: 11, color: AppColors.darkTextSecondary)),
                        ],
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // CTA
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0A2540), Color(0xFF1A0A3A)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('⚙️', style: TextStyle(fontSize: 36)),
                    const SizedBox(height: 12),
                    const Text('Ready to Get Started?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 8),
                    const Text(
                      'Mulai konsultasi gratis untuk proyek AI Anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.darkTextSecondary),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.darkGradient,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(25),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                            child: Text('⚡ Schedule a Consultation →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
