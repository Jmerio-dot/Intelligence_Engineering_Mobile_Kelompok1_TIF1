import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/project.dart';
import '../models/issue.dart';
import '../models/sprint.dart';
import '../models/activity.dart';
import '../models/service_item.dart';
import '../models/team_member.dart';

class MockData {
  MockData._();

  // ──────────── CURRENT USER ────────────
  static User currentUser = User(
    id: 1,
    name: 'Demo User',
    email: 'demo@intring.ai',
    role: 'admin',
    status: 'active',
    avatar: '👨‍💻',
    bio: 'Full-stack developer & AI enthusiast',
    location: 'Universitas Teknologi',
    website: 'https://intring.ai',
    issueCount: 5,
    createdAt: DateTime(2026, 1, 15),
    lastLogin: DateTime.now(),
  );

  // ──────────── USERS ────────────
  static List<User> users = [
    currentUser,
  ];

  // ──────────── PROJECTS ────────────
  static List<Project> projects = [];

  // ──────────── SPRINTS ────────────
  static List<Sprint> sprints = [];

  // ──────────── ISSUES ────────────
  static List<Issue> issues = [];

  // ──────────── ACTIVITIES ────────────
  static List<Activity> activities = [
    Activity(userEmoji: '👨‍💻', userName: 'Demo User', detail: 'Membuat akun', timestamp: DateTime.now().subtract(const Duration(hours: 2))),
  ];

  // ──────────── SERVICES ────────────
  static const List<ServiceItem> services = [
    ServiceItem(icon: '🤖', badge: '🧠', title: 'AI Consulting', description: 'Konsultasi strategi AI dan implementasi solusi cerdas untuk bisnis Anda.', gradientColors: [Color(0xFF0077B6), Color(0xFF00B4D8)]),
    ServiceItem(icon: '📊', badge: '✨', title: 'Machine Learning', description: 'Pengembangan model ML untuk prediksi, klasifikasi, dan rekomendasi.', gradientColors: [Color(0xFFEC4899), Color(0xFFF472B6)]),
    ServiceItem(icon: '🗄️', badge: '📦', title: 'Data Engineering', description: 'Pipeline data, ETL, dan arsitektur data warehouse yang scalable.', gradientColors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)]),
    ServiceItem(icon: '🧬', badge: '🔗', title: 'Neural Networks', description: 'Pengembangan deep learning dan neural network untuk tugas kompleks.', gradientColors: [Color(0xFF10B981), Color(0xFF34D399)]),
    ServiceItem(icon: '👁️', badge: '🔭', title: 'Computer Vision', description: 'Deteksi objek, segmentasi gambar, dan analisis visual real-time.', gradientColors: [Color(0xFFF59E0B), Color(0xFFFBBF24)]),
    ServiceItem(icon: '💬', badge: '🗣️', title: 'NLP', description: 'Pemrosesan bahasa alami untuk chatbot, analisis sentimen, dan text mining.', gradientColors: [Color(0xFF0D9488), Color(0xFF14B8A6)]),
    ServiceItem(icon: '📈', badge: '📡', title: 'Predictive Analytics', description: 'Analisis prediktif untuk forecasting dan decision support system.', gradientColors: [Color(0xFFF97316), Color(0xFFFB923C)]),
    ServiceItem(icon: '⚙️', badge: '🔧', title: 'Intelligent Automation', description: 'Otomasi proses bisnis berbasis AI untuk efisiensi operasional.', gradientColors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)]),
    ServiceItem(icon: '⚛️', badge: '🔬', title: 'Quantum Computing', description: 'Solusi komputasi kuantum untuk optimasi dan simulasi kompleks.', gradientColors: [Color(0xFF06B6D4), Color(0xFF22D3EE)]),
    ServiceItem(icon: '🔋', badge: '📊', title: 'AI Analytics', description: 'Platform analitik bertenaga AI untuk insight data real-time.', gradientColors: [Color(0xFF4F46E5), Color(0xFF6366F1)]),
    ServiceItem(icon: '🧩', badge: '💎', title: 'Cognitive Computing', description: 'Sistem kognitif untuk pemahaman dan pengambilan keputusan otomatis.', gradientColors: [Color(0xFFD946EF), Color(0xFFE879F9)]),
    ServiceItem(icon: '📱', badge: '🚀', title: 'AI App Development', description: 'Pengembangan aplikasi mobile dan web bertenaga AI/ML.', gradientColors: [Color(0xFFEAB308), Color(0xFFFACC15)]),
  ];

  // ──────────── TEAM MEMBERS ────────────
  static const List<TeamMember> teamMembers = [];

  // ──────────── TECH STACK ────────────
  static const List<Map<String, String>> techStack = [
    {'icon': '🔷', 'name': 'TensorFlow'},
    {'icon': '🐍', 'name': 'Python'},
    {'icon': '🔥', 'name': 'PyTorch'},
    {'icon': '☁️', 'name': 'AWS'},
    {'icon': '🌐', 'name': 'Azure'},
    {'icon': '⚓', 'name': 'Kubernetes'},
  ];

  // ──────────── HELPERS ────────────
  static List<Issue> getIssuesForProject(int projectId) {
    return issues.where((i) => i.projectId == projectId).toList();
  }

  static List<Issue> getIssuesForSprint(int sprintId) {
    return issues.where((i) => i.sprintId == sprintId).toList();
  }

  static List<Issue> getBacklogIssues(int projectId) {
    return issues.where((i) => i.projectId == projectId && i.sprintId == null).toList();
  }

  static List<Sprint> getSprintsForProject(int projectId) {
    return sprints.where((s) => s.projectId == projectId).toList();
  }

  static Iterable<Issue> get _validIssues => issues.where((i) => projects.any((p) => p.id == i.projectId));

  static List<Issue> getMyOpenIssues() {
    return _validIssues.where((i) => i.assigneeId == currentUser.id && i.status != 'done').toList();
  }

  static Map<String, int> getStatusCounts() {
    final counts = {'todo': 0, 'in_progress': 0, 'in_review': 0, 'done': 0};
    for (final issue in _validIssues) {
      counts[issue.status] = (counts[issue.status] ?? 0) + 1;
    }
    return counts;
  }

  static Map<String, int> getPriorityCounts() {
    final counts = {'critical': 0, 'high': 0, 'medium': 0, 'low': 0};
    for (final issue in _validIssues) {
      counts[issue.priority] = (counts[issue.priority] ?? 0) + 1;
    }
    return counts;
  }

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
