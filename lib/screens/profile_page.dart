import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _editing = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _locCtrl;
  late TextEditingController _webCtrl;
  User? _user;

  @override
  void initState() {
    super.initState();
    final data = AuthService().currentUser;
    if (data != null) {
      _user = User.fromJson(data);
    } else {
      _user = User(id: 0, name: '', email: '');
    }
    
    _nameCtrl = TextEditingController(text: _user!.name);
    _bioCtrl = TextEditingController(text: _user!.bio ?? '');
    _locCtrl = TextEditingController(text: _user!.location ?? '');
    _webCtrl = TextEditingController(text: _user!.website ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _bioCtrl.dispose(); _locCtrl.dispose(); _webCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _user!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profil Engineer', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ocean)),
            const SizedBox(height: 4),
            const Text('Kelola identitas dan detail kontak Anda', style: TextStyle(fontSize: 13, color: AppColors.text2)),
            const SizedBox(height: 20),

            // ── Profile Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x1A0064B4), blurRadius: 16, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Text('Informasi Pribadi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ocean)),
                      const Spacer(),
                      if (!_editing)
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _editing = true),
                          icon: const Text('✏️', style: TextStyle(fontSize: 14)),
                          label: const Text('Edit', style: TextStyle(fontSize: 12)),
                        )
                      else
                        Row(
                          children: [
                            TextButton(onPressed: () => setState(() => _editing = false), child: const Text('Batal', style: TextStyle(fontSize: 12))),
                            const SizedBox(width: 6),
                            ElevatedButton(
                              onPressed: _saveProfile,
                              child: const Text('Simpan', style: TextStyle(fontSize: 12, color: Colors.white)),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 90, height: 90,
                          decoration: const BoxDecoration(gradient: AppColors.gradient2, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text(user.avatar ?? '👨‍💻', style: const TextStyle(fontSize: 40)),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: GestureDetector(
                            onTap: _showPhotoOptions,
                            child: Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.cyan,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              alignment: Alignment.center,
                              child: const Text('📷', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(child: Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ocean))),
                  Center(child: Text(user.email, style: const TextStyle(fontSize: 13, color: AppColors.text2))),
                  const SizedBox(height: 24),

                  if (_editing) ..._editFields() else ..._viewFields(),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Danger Zone ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.dangerBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selesai Bekerja?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dangerText)),
                  const SizedBox(height: 4),
                  const Text('Anda akan keluar dari akun saat ini', style: TextStyle(fontSize: 13, color: Color(0xFFFB7185))),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dangerButton,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<Widget> _viewFields() {
    final user = _user!;
    return [
      _viewField('NAMA LENGKAP', user.name),
      _viewField('EMAIL TERDAFTAR', user.email, hint: 'Email bersifat tetap dan tidak dapat diubah'),
      _viewField('PERAN & KEAHLIAN', user.bio ?? ''),
      _viewField('LOKASI / KAMPUS', user.location ?? ''),
      _viewField('TAUTAN PORTOFOLIO', user.website ?? ''),
    ];
  }

  List<Widget> _editFields() {
    return [
      _editLabel('NAMA LENGKAP'),
      TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Nama lengkap')),
      const SizedBox(height: 14),
      _editLabel('EMAIL'),
      TextField(
        controller: TextEditingController(text: _user!.email),
        readOnly: true,
        decoration: InputDecoration(fillColor: const Color(0xFFE5E7EB), hintText: 'Email',
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xFFD1D5DB)))),
      ),
      const SizedBox(height: 14),
      _editLabel('BIO'),
      TextField(controller: _bioCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Peran & keahlian Anda')),
      const SizedBox(height: 14),
      _editLabel('LOKASI'),
      TextField(controller: _locCtrl, decoration: const InputDecoration(hintText: 'Kampus / kota')),
      const SizedBox(height: 14),
      _editLabel('WEBSITE'),
      TextField(controller: _webCtrl, decoration: const InputDecoration(hintText: 'https://...')),
    ];
  }

  Widget _viewField(String label, String value, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.ocean, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              value.isNotEmpty ? value : 'Belum diisi',
              style: TextStyle(
                fontSize: 14, color: value.isNotEmpty ? AppColors.text : AppColors.muted,
                fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
          if (hint != null) Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(hint, style: const TextStyle(fontSize: 10, color: AppColors.muted, fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }

  Widget _editLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.ocean, letterSpacing: 0.5)),
    );
  }

  Future<void> _saveProfile() async {
    try {
      final updatedData = await AuthService().updateProfile(
        name: _nameCtrl.text,
        bio: _bioCtrl.text,
        location: _locCtrl.text,
        website: _webCtrl.text,
      );
      if (mounted) {
        setState(() {
          _user = User.fromJson(updatedData);
          _editing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil disimpan!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ubah Foto Profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ocean)),
            const SizedBox(height: 20),
            _photoOption('📁', 'Upload dari Galeri', const Color(0xFFE0F2FE), AppColors.primaryBlue),
            const SizedBox(height: 10),
            _photoOption('📷', 'Ambil Foto dengan Kamera', const Color(0xFFEDE9FE), AppColors.darkPurple),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _photoOption(String icon, String text, Color bg, Color iconBg) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur foto akan tersedia setelah koneksi API'), backgroundColor: AppColors.cyan),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 14),
            Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
          ],
        ),
      ),
    );
  }
}
