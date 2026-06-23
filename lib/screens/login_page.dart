import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLogin = true;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _error;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regConfirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    _regConfirmCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Email dan kata sandi harus diisi!');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      await AuthService().login(_emailCtrl.text.trim(), _passCtrl.text);
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on ApiException catch (e) {
      if (mounted) {
        setState(() { _error = e.message; _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() { _error = 'Gagal terhubung ke server'; _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal terhubung ke server'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _handleRegister() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Nama lengkap harus diisi!');
      return;
    }
    if (_regEmailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Email harus diisi!');
      return;
    }
    if (_regPassCtrl.text.length < 6) {
      setState(() => _error = 'Kata sandi minimal 6 karakter!');
      return;
    }
    if (_regPassCtrl.text != _regConfirmCtrl.text) {
      setState(() => _error = 'Kata sandi tidak cocok!');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      await AuthService().register(
        _nameCtrl.text.trim(),
        _regEmailCtrl.text.trim(),
        _regPassCtrl.text,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on ApiException catch (e) {
      if (mounted) {
        setState(() { _error = e.message; _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() { _error = 'Gagal terhubung ke server'; _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal terhubung ke server'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  InputDecoration _inputDeco(String hint, String prefixIcon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF8AB2CC), fontSize: 14),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Text(prefixIcon, style: const TextStyle(fontSize: 16)),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 40),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFB8D8F0), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFB8D8F0), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Brand Header ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                decoration: const BoxDecoration(gradient: AppColors.loginLeftGradient),
                child: Column(
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      alignment: Alignment.center,
                      child: const Text('⚡', style: TextStyle(fontSize: 30)),
                    ),
                    const SizedBox(height: 14),
                    const Text('Intelligence', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                    const Text('Engineering', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFCAF0F8))),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10, runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: ['📋 Kanban', '🏃 Sprint', '🐛 Issues', '👥 Team', '📊 Analytics']
                          .map((f) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(f, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),

              // ── Form Section ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLogin ? 'Selamat Datang 👋' : 'Buat Akun Baru ✨',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ocean),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isLogin ? 'Masuk ke akun Anda untuk melanjutkan' : 'Daftar untuk mulai mengelola proyek',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF5A7FA8)),
                      ),
                      const SizedBox(height: 18),

                      // Tab Switcher
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEEEFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _tabBtn('Masuk', _isLogin, () => setState(() { _isLogin = true; _error = null; })),
                            _tabBtn('Daftar', !_isLogin, () => setState(() { _isLogin = false; _error = null; })),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (_isLogin) ..._loginFields() else ..._registerFields(),

                      // Error
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F0),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Text(_error!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13)),
                        ),
                      ],
                      const SizedBox(height: 18),

                      // Submit
                      GradientButton(
                        text: _isLogin ? 'Masuk →' : 'Buat Akun →',
                        onPressed: _isLogin ? _handleLogin : _handleRegister,
                        isLoading: _isLoading,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 14),

                      // Switch
                      Center(
                        child: GestureDetector(
                          onTap: () => setState(() { _isLogin = !_isLogin; _error = null; }),
                          child: Text.rich(
                            TextSpan(
                              text: _isLogin ? 'Belum punya akun? ' : 'Sudah punya akun? ',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF5A7FA8)),
                              children: [
                                TextSpan(
                                  text: _isLogin ? 'Daftar sekarang' : 'Masuk di sini',
                                  style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                                ),
                              ],
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
      ),
    );
  }

  List<Widget> _loginFields() {
    return [
      _label('Email'),
      const SizedBox(height: 6),
      TextFormField(controller: _emailCtrl, decoration: _inputDeco('nama@email.com', '✉️'), keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 14),
      _label('Kata Sandi'),
      const SizedBox(height: 6),
      TextFormField(
        controller: _passCtrl,
        obscureText: _obscurePass,
        decoration: _inputDeco('Kata sandi Anda', '🔒', suffix: GestureDetector(
          onTap: () => setState(() => _obscurePass = !_obscurePass),
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(_obscurePass ? '👁️' : '🙈', style: const TextStyle(fontSize: 16)),
          ),
        )),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          SizedBox(
            width: 20, height: 20,
            child: Checkbox(
              value: _rememberMe,
              onChanged: (v) => setState(() => _rememberMe = v ?? false),
              activeColor: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 6),
          const Text('Ingat saya', style: TextStyle(fontSize: 13, color: AppColors.text2)),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: const Text('Lupa kata sandi?', style: TextStyle(fontSize: 13, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    ];
  }

  List<Widget> _registerFields() {
    return [
      _label('Nama Lengkap'),
      const SizedBox(height: 6),
      TextFormField(controller: _nameCtrl, decoration: _inputDeco('Nama lengkap Anda', '🧑')),
      const SizedBox(height: 14),
      _label('Email'),
      const SizedBox(height: 6),
      TextFormField(controller: _regEmailCtrl, decoration: _inputDeco('nama@email.com', '✉️'), keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 14),
      _label('Kata Sandi'),
      const SizedBox(height: 6),
      TextFormField(
        controller: _regPassCtrl,
        obscureText: _obscurePass,
        decoration: _inputDeco('Minimal 6 karakter', '🔒', suffix: GestureDetector(
          onTap: () => setState(() => _obscurePass = !_obscurePass),
          child: Padding(padding: const EdgeInsets.only(right: 12), child: Text(_obscurePass ? '👁️' : '🙈', style: const TextStyle(fontSize: 16))),
        )),
      ),
      const SizedBox(height: 14),
      _label('Konfirmasi Kata Sandi'),
      const SizedBox(height: 6),
      TextFormField(
        controller: _regConfirmCtrl,
        obscureText: _obscureConfirm,
        decoration: _inputDeco('Ulangi kata sandi', '🔒', suffix: GestureDetector(
          onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
          child: Padding(padding: const EdgeInsets.only(right: 12), child: Text(_obscureConfirm ? '👁️' : '🙈', style: const TextStyle(fontSize: 16))),
        )),
      ),
    ];
  }

  Widget _tabBtn(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: active ? AppColors.gradient2 : null,
            borderRadius: BorderRadius.circular(9),
            boxShadow: active ? [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))] : null,
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : const Color(0xFF5A7FA8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A4A7A)));
  }
}
