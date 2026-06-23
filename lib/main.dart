import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/home_shell.dart';
import 'screens/board_page.dart';
import 'screens/backlog_page.dart';
import 'screens/issue_detail_page.dart';
import 'screens/create_issue_page.dart';
import 'screens/profile_page.dart';
import 'screens/about_page.dart';
import 'screens/services_page.dart';
import 'screens/upload_page.dart';
import 'screens/transcript_page.dart';
import 'screens/report_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService().init();
  runApp(const IntRingApp());
}

class IntRingApp extends StatelessWidget {
  const IntRingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IntRing PM - Intelligence Engineering',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(AppTheme.lightTheme.textTheme),
      ),
      home: const _SplashGate(),
      routes: {
        '/landing': (_) => const LandingPage(),
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomeShell(),
        '/board': (ctx) => BoardPage(projectId: _getIntArg(ctx, 'projectId') ?? 1),
        '/backlog': (ctx) => BacklogPage(projectId: _getIntArg(ctx, 'projectId') ?? 1),
        '/issue': (ctx) => IssueDetailPage(issueId: _getIntArg(ctx, 'issueId') ?? 1),
        '/create-issue': (ctx) => CreateIssuePage(projectId: _getIntArg(ctx, 'projectId') ?? 1),
        '/profile': (_) => const ProfilePage(),
        '/about': (_) => const AboutPage(),
        '/services': (_) => const ServicesPage(),
        '/upload': (_) => const UploadPage(),
        '/transcript': (ctx) => TranscriptPage(projectId: _getIntArg(ctx, 'projectId') ?? 1),
        '/report': (_) => const ReportPage(),
      },
    );
  }

  static int? _getIntArg(BuildContext context, String key) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      return args[key] as int?;
    }
    return null;
  }
}

/// Splash gate: tries auto-login, then navigates to /home or /landing.
class _SplashGate extends StatefulWidget {
  const _SplashGate();

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await AuthService().tryAutoLogin();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, loggedIn ? '/home' : '/landing');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
