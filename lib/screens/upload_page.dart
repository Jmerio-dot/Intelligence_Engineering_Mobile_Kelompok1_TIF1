import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'AI';
  final List<String> _files = [];
  bool _submitted = false;

  final _categories = ['AI', 'Machine Learning', 'Computer Vision', 'NLP', 'Data Engineering', 'Quantum', 'Other'];

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(scaffoldBackgroundColor: AppColors.darkBg),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.darkTextPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              Container(width: 28, height: 28, decoration: BoxDecoration(gradient: AppColors.darkGradient, borderRadius: BorderRadius.circular(7)),
                alignment: Alignment.center, child: const Text('⚡', style: TextStyle(fontSize: 14))),
              const SizedBox(width: 8),
              const Text('Upload', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.darkTextPrimary)),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Hero
              ShaderMask(
                shaderCallback: (bounds) => AppColors.darkGradient.createShader(bounds),
                child: const Text('Upload Your Project', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
              const SizedBox(height: 8),
              const Text('Submit proyek AI Anda untuk review', style: TextStyle(fontSize: 14, color: AppColors.darkTextSecondary)),
              const SizedBox(height: 28),

              // Form Card 1
              _darkCard('📤 Project Details', [
                _darkLabel('Project Name'),
                _darkInput(_nameCtrl, 'Nama proyek Anda'),
                const SizedBox(height: 14),
                _darkLabel('Category'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _category,
                      isExpanded: true,
                      dropdownColor: AppColors.darkBgSecondary,
                      style: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 14),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _darkLabel('Description'),
                _darkInput(_descCtrl, 'Deskripsi proyek Anda', maxLines: 3),
              ]),
              const SizedBox(height: 16),

              // Form Card 2
              _darkCard('📁 Upload Files', [
                GestureDetector(
                  onTap: () => setState(() => _files.add('document_${_files.length + 1}.pdf')),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.darkCyan.withValues(alpha: 0.3), width: 2, style: BorderStyle.solid),
                    ),
                    child: Column(
                      children: [
                        const Text('⬆️', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text('Tap to add files', style: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('PDF, PNG, JPG supported', style: TextStyle(fontSize: 12, color: AppColors.darkTextMuted)),
                      ],
                    ),
                  ),
                ),
                if (_files.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...List.generate(_files.length, (i) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.darkCyan.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.darkCyan.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        const Text('📄', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_files[i], style: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 13))),
                        Text('${(i + 1) * 245} KB', style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 11)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _files.removeAt(i)),
                          child: const Icon(Icons.close, size: 16, color: AppColors.darkTextMuted),
                        ),
                      ],
                    ),
                  )),
                ],
              ]),
              const SizedBox(height: 24),

              // Submit
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: _submitted ? const LinearGradient(colors: [AppColors.success, Color(0xFF34D399)]) : AppColors.darkGradient,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _submitted ? null : _handleSubmit,
                      borderRadius: BorderRadius.circular(25),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            _submitted ? '✅ Project Submitted!' : '⬆ Submit Project',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _darkCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _darkLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkTextSecondary)),
    );
  }

  Widget _darkInput(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.darkTextMuted),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.darkCyan)),
      ),
    );
  }

  void _handleSubmit() {
    if (_nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in the project name'), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _submitted = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _submitted = false);
    });
  }
}
