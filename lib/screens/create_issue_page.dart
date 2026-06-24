import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/issue_service.dart';

class CreateIssuePage extends StatefulWidget {
  final int projectId;
  const CreateIssuePage({super.key, required this.projectId});

  @override
  State<CreateIssuePage> createState() => _CreateIssuePageState();
}

class _CreateIssuePageState extends State<CreateIssuePage> {
  final _pageCtrl = PageController();
  int _currentTab = 0;
  final _tabCount = 4;
  bool _isSubmitting = false;

  // Tab 1
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _type = 'task';
  String _priority = 'medium';

  // Tab 2
  final _orgObjCtrl = TextEditingController();
  final _orgHowCtrl = TextEditingController();
  final _orgMeasureCtrl = TextEditingController();
  final _userOutCtrl = TextEditingController();
  final _userHowCtrl = TextEditingController();
  final _userMeasureCtrl = TextEditingController();
  final _modelPropCtrl = TextEditingController();
  final _modelHowCtrl = TextEditingController();
  final _modelMeasureCtrl = TextEditingController();
  final List<List<TextEditingController>> _indicators = [
    [TextEditingController(), TextEditingController(), TextEditingController()],
  ];

  // Tab 3
  final Set<String> _presentations = {};
  final List<List<TextEditingController>> _functions = [
    [TextEditingController(), TextEditingController()],
  ];

  final List<List<TextEditingController>> _errorMitigation = [
    [TextEditingController(), TextEditingController()],
  ];
  final List<List<TextEditingController>> _dataCollection = [
    [TextEditingController(), TextEditingController()],
  ];

  // Tab 4
  final List<List<TextEditingController>> _processes = [
    [TextEditingController(), TextEditingController()],
  ];
  final List<List<TextEditingController>> _technologies = [
    [TextEditingController(), TextEditingController()],
  ];

  bool _attemptedNext = false;

  Widget _buildTextField(TextEditingController ctrl, {String hint = '', int maxLines = 1, bool isRequired = false, bool isDense = false}) {
    final hasError = isRequired && _attemptedNext && ctrl.text.trim().isEmpty;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: hasError ? const [BoxShadow(color: Color(0x66F44336), blurRadius: 6, spreadRadius: 1)] : const [],
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        onChanged: (v) { if (_attemptedNext) setState(() {}); },
        decoration: InputDecoration(
          hintText: hint,
          fillColor: Colors.white,
          filled: true,
          isDense: isDense,
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: hasError ? Colors.red : const Color(0xFFE5E7EB), width: 1), borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: hasError ? Colors.red : AppColors.cyan, width: 2), borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose(); _titleCtrl.dispose(); _descCtrl.dispose();
    _orgObjCtrl.dispose(); _orgHowCtrl.dispose(); _orgMeasureCtrl.dispose();
    _userOutCtrl.dispose(); _userHowCtrl.dispose(); _userMeasureCtrl.dispose();
    _modelPropCtrl.dispose(); _modelHowCtrl.dispose(); _modelMeasureCtrl.dispose();
    for (final row in _indicators) { for (final c in row) { c.dispose(); } }
    for (final row in _functions) { for (final c in row) { c.dispose(); } }
    for (final row in _errorMitigation) { for (final c in row) { c.dispose(); } }
    for (final row in _dataCollection) { for (final c in row) { c.dispose(); } }
    for (final row in _processes) { for (final c in row) { c.dispose(); } }
    for (final row in _technologies) { for (final c in row) { c.dispose(); } }
    super.dispose();
  }

  void _goToTab(int tab) {
    if (tab > _currentTab) {
      setState(() => _attemptedNext = true);
      if (_currentTab == 0 && _titleCtrl.text.trim().isEmpty) return;
      if (_currentTab == 1) {
        bool indValid = _indicators.isNotEmpty && _indicators.every((r) => r.every((c) => c.text.trim().isNotEmpty));
        if (!indValid || _orgObjCtrl.text.trim().isEmpty || _orgHowCtrl.text.trim().isEmpty || _orgMeasureCtrl.text.trim().isEmpty ||
            _userOutCtrl.text.trim().isEmpty || _userHowCtrl.text.trim().isEmpty || _userMeasureCtrl.text.trim().isEmpty ||
            _modelPropCtrl.text.trim().isEmpty || _modelHowCtrl.text.trim().isEmpty || _modelMeasureCtrl.text.trim().isEmpty) {
          return;
        }
      }
      if (_currentTab == 2) {
        if (_presentations.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih minimal satu penyajian kecerdasan'), backgroundColor: AppColors.error));
          return;
        }
        bool funcsValid = _functions.isNotEmpty && _functions.every((r) => r.every((c) => c.text.trim().isNotEmpty));
        bool errValid = _errorMitigation.isNotEmpty && _errorMitigation.every((r) => r.every((c) => c.text.trim().isNotEmpty));
        bool dataValid = _dataCollection.isNotEmpty && _dataCollection.every((r) => r.every((c) => c.text.trim().isNotEmpty));
        if (!funcsValid || !errValid || !dataValid) return;
      }
      if (_currentTab == 3) {
        bool procValid = _processes.isNotEmpty && _processes.every((r) => r.every((c) => c.text.trim().isNotEmpty));
        bool techValid = _technologies.isNotEmpty && _technologies.every((r) => r.every((c) => c.text.trim().isNotEmpty));
        if (!procValid || !techValid) return;
      }
    }
    
    setState(() => _attemptedNext = false);
    _pageCtrl.animateToPage(tab, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.ocean), onPressed: () => Navigator.pop(context)),
        title: const Text('Buat Issue Cerdas', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ocean)),
      ),
      body: Column(
        children: [
          // Tab header
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(_tabCount, (i) {
                final active = i == _currentTab;
                final labels = ['1. Basic Info', '2. Objectives', '3. Experiences', '4. Implementation'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => _goToTab(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? AppColors.cyan : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: active ? AppColors.cyan : AppColors.cardBorder),
                      ),
                      child: Text(labels[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.text2)),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Content
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [_tab1(), _tab2(), _tab3(), _tab4()],
            ),
          ),
          // Bottom nav
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Row(
              children: [
                if (_currentTab > 0)
                  OutlinedButton(onPressed: () => _goToTab(_currentTab - 1), child: const Text('← Sebelumnya')),
                const Spacer(),
                Text('${_currentTab + 1} / $_tabCount', style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600)),
                const Spacer(),
                if (_currentTab < _tabCount - 1)
                  ElevatedButton(onPressed: () => _goToTab(_currentTab + 1), child: const Text('Selanjutnya →', style: TextStyle(color: Colors.white))),
                if (_currentTab == _tabCount - 1)
                  ElevatedButton(
                    onPressed: _submitIssue,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                    child: const Text('✅ Simpan Issue & Kirim', style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab1() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _cardSection('Informasi Dasar Issue', null, [
          _fieldLabel('Judul Issue *'),
          _buildTextField(_titleCtrl, hint: 'Masukkan judul...', isRequired: true),
          const SizedBox(height: 14),
          _fieldLabel('Deskripsi Singkat'),
          _buildTextField(_descCtrl, maxLines: 3, hint: 'Deskripsi umum...', isRequired: false),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _fieldLabel('Tipe Issue'),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  items: ['story', 'task', 'bug'].map((t) => DropdownMenuItem(value: t, child: Text('${AppColors.typeIcon[t]} ${t[0].toUpperCase()}${t.substring(1)}'))).toList(),
                  onChanged: (v) => setState(() => _type = v!),
                  decoration: const InputDecoration(),
                ),
              ])),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _fieldLabel('Prioritas'),
                DropdownButtonFormField<String>(
                  initialValue: _priority,
                  items: ['critical', 'high', 'medium', 'low'].map((p) => DropdownMenuItem(value: p, child: Text('${AppColors.priorityIcon[p]} ${p[0].toUpperCase()}${p.substring(1)}'))).toList(),
                  onChanged: (v) => setState(() => _priority = v!),
                  decoration: const InputDecoration(),
                ),
              ])),
            ],
          ),
        ]),
      ],
    );
  }

  Widget _tab2() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _cardSection('Organizational Objectives *', 'Apa nilai bisnis utama yang ingin dicapai perusahaan melalui sistem cerdas ini?', [
          _buildTextField(_orgObjCtrl, maxLines: 2, hint: 'Contoh: Meningkatkan pendapatan tenant kantin...', isRequired: true),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _fieldLabel('Bagaimana cara mencapainya?'),
              _buildTextField(_orgHowCtrl, maxLines: 2, isRequired: true),
            ])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _fieldLabel('Bagaimana cara mengukurnya?'),
              _buildTextField(_orgMeasureCtrl, maxLines: 2, isRequired: true),
            ])),
          ]),
        ]),
        const SizedBox(height: 12),
        _cardSection('Leading Indicators *', 'Indikator metrik apa saja yang bisa memprediksi keberhasilan sistem ini dibandingkan dengan produk kompetitor?', [
          Row(
            children: [
              Expanded(child: Text('FITUR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.ocean))),
              const SizedBox(width: 6),
              Expanded(child: Text('SISTEM KITA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.ocean))),
              const SizedBox(width: 6),
              Expanded(child: Text('PRODUK KOMPETITOR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.ocean))),
              const SizedBox(width: 32),
            ],
          ),
          const Divider(color: Color(0xFFBAE6FD)),
          ..._indicators.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(child: _buildTextField(e.value[0], hint: 'Kecepatan Memilih Menu', isDense: true, isRequired: true)),
              const SizedBox(width: 6),
              Expanded(child: _buildTextField(e.value[1], hint: '< 10 detik', isDense: true, isRequired: true)),
              const SizedBox(width: 6),
              Expanded(child: _buildTextField(e.value[2], hint: '5 Menit', isDense: true, isRequired: true)),
              IconButton(icon: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFFECACA))), child: const Icon(Icons.close, size: 14, color: AppColors.error)), onPressed: () {
                if (_indicators.length > 1) setState(() { for (final c in _indicators[e.key]) { c.dispose(); } _indicators.removeAt(e.key); });
              }),
            ]),
          )),
        ], actionLabel: '+ Tambah Baris', onAction: () => setState(() => _indicators.add([TextEditingController(), TextEditingController(), TextEditingController()]))),
        const SizedBox(height: 12),
        _cardSection('User Outcomes *', 'Manfaat nyata apa yang akan dirasakan oleh pengguna saat berinteraksi dengan sistem ini?', [
          _buildTextField(_userOutCtrl, maxLines: 2, hint: 'Siswa langsung mendapat pilihan makanan yang pas...', isRequired: true),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _fieldLabel('Bagaimana cara mencapainya?'),
              _buildTextField(_userHowCtrl, maxLines: 2, isRequired: true),
            ])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _fieldLabel('Bagaimana cara mengukurnya?'),
              _buildTextField(_userMeasureCtrl, maxLines: 2, isRequired: true),
            ])),
          ]),
        ]),
        const SizedBox(height: 12),
        _cardSection('Model Properties *', 'Spesifikasi teknis dan kriteria akurasi yang harus dipenuhi oleh model AI/Machine Learning-nya.', [
          _buildTextField(_modelPropCtrl, maxLines: 2, hint: 'Model rekomendasi harus mampu memberikan saran real-time...', isRequired: true),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _fieldLabel('Bagaimana cara mencapainya?'),
              _buildTextField(_modelHowCtrl, maxLines: 2, isRequired: true),
            ])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _fieldLabel('Bagaimana cara mengukurnya?'),
              _buildTextField(_modelMeasureCtrl, maxLines: 2, isRequired: true),
            ])),
          ]),
        ]),
      ],
    );
  }

  Widget _tab3() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _cardSection('Penyajian Kecerdasan *', 'Pilih satu atau lebih cara penyajian AI ke user.', [
          GridView.count(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.5,
            children: [
              _checkItem('Automate', '⚙️', 'Sistem otomatis melakukan aksi tanpa diminta'),
              _checkItem('Prompt', '💬', 'User input, sistem memberikan jawaban'),
              _checkItem('Organisation', '📊', 'Mengorganisir informasi secara cerdas'),
              _checkItem('Annotate', '📝', 'Memberikan label/anotasi pada data'),
            ],
          ),
          const SizedBox(height: 10),
          const TextField(maxLines: 2, decoration: InputDecoration(hintText: 'Jelaskan interaksi AI dengan user...')),
        ]),
        const SizedBox(height: 12),
        _cardSection('Fungsi-fungsi Realisasi Objectives *', 'Rincian fungsi spesifik apa saja yang perlu dibangun untuk merealisasikan tujuan di atas.', [
          Row(
            children: [
              Expanded(child: Text('NAMA FUNGSI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.ocean))),
              const SizedBox(width: 8),
              Expanded(child: Text('DESKRIPSI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.ocean))),
              const SizedBox(width: 32),
            ],
          ),
          const Divider(color: Color(0xFFBAE6FD)),
          ..._functions.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(child: _buildTextField(e.value[0], hint: 'Nama Fungsi', isDense: true, isRequired: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(e.value[1], hint: 'Deskripsi...', isDense: true, isRequired: true)),
              IconButton(icon: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFFECACA))), child: const Icon(Icons.close, size: 14, color: AppColors.error)), onPressed: () {
                if (_functions.length > 1) setState(() { for (final c in _functions[e.key]) { c.dispose(); } _functions.removeAt(e.key); });
              }),
            ]),
          )),
        ], actionLabel: '+ Tambah Fungsi', onAction: () => setState(() => _functions.add([TextEditingController(), TextEditingController()]))),
        const SizedBox(height: 12),
        _cardSection('Minimalisasi Kesalahan *', 'Bagaimana sistem menangani potensi kesalahan dari prediksi AI agar tidak fatal.', [
          Row(
            children: [
              Expanded(child: Text('NAMA FUNGSI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.ocean))),
              const SizedBox(width: 8),
              Expanded(child: Text('STRATEGI MITIGASI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.ocean))),
              const SizedBox(width: 32),
            ],
          ),
          const Divider(color: Color(0xFFBAE6FD)),
          ..._errorMitigation.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(child: _buildTextField(e.value[0], hint: 'Nama Fungsi', isDense: true, isRequired: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(e.value[1], hint: 'Strategi mitigasi...', isDense: true, isRequired: true)),
              IconButton(icon: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFFECACA))), child: const Icon(Icons.close, size: 14, color: AppColors.error)), onPressed: () {
                if (_errorMitigation.length > 1) setState(() { for (final c in _errorMitigation[e.key]) { c.dispose(); } _errorMitigation.removeAt(e.key); });
              }),
            ]),
          )),
        ], actionLabel: '+ Tambah Strategi', onAction: () => setState(() => _errorMitigation.add([TextEditingController(), TextEditingController()]))),
        const SizedBox(height: 12),
        _cardSection('Pengumpulan Data untuk Perbaikan *', 'Bagaimana cara sistem mengumpulkan data baru secara berkala untuk melatih ulang (re-train) model.', [
          Row(
            children: [
              Expanded(child: Text('NAMA FUNGSI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.ocean))),
              const SizedBox(width: 8),
              Expanded(child: Text('RENCANA PENGUMPULAN DATA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.ocean))),
              const SizedBox(width: 32),
            ],
          ),
          const Divider(color: Color(0xFFBAE6FD)),
          ..._dataCollection.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(child: _buildTextField(e.value[0], hint: 'Nama Fungsi', isDense: true, isRequired: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(e.value[1], hint: 'Rencana pengumpulan data...', isDense: true, isRequired: true)),
              IconButton(icon: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFFECACA))), child: const Icon(Icons.close, size: 14, color: AppColors.error)), onPressed: () {
                if (_dataCollection.length > 1) setState(() { for (final c in _dataCollection[e.key]) { c.dispose(); } _dataCollection.removeAt(e.key); });
              }),
            ]),
          )),
        ], actionLabel: '+ Tambah Rencana', onAction: () => setState(() => _dataCollection.add([TextEditingController(), TextEditingController()]))),
      ],
    );
  }

  Widget _tab4() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _cardSection('Proses Bisnis Sistem Cerdas *', 'Alur kerja atau tahapan proses yang terjadi di dalam sistem ini secara berurutan.', [
          Row(
            children: [
              Expanded(child: Text('NAMA PROSES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.ocean))),
              const SizedBox(width: 8),
              Expanded(child: Text('DESKRIPSI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.ocean))),
              const SizedBox(width: 32),
            ],
          ),
          const Divider(color: Color(0xFFBAE6FD)),
          ..._processes.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(child: _buildTextField(e.value[0], hint: 'Nama Proses', isDense: true, isRequired: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(e.value[1], hint: 'Deskripsi proses...', isDense: true, isRequired: true)),
              IconButton(icon: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFFECACA))), child: const Icon(Icons.close, size: 14, color: AppColors.error)), onPressed: () {
                if (_processes.length > 1) setState(() { for (final c in _processes[e.key]) { c.dispose(); } _processes.removeAt(e.key); });
              }),
            ]),
          )),
        ], actionLabel: '+ Tambah Proses', onAction: () => setState(() => _processes.add([TextEditingController(), TextEditingController()]))),
        const SizedBox(height: 12),
        _cardSection('Teknologi per Proses *', 'Teknologi yang digunakan untuk setiap proses.', [
          Row(
            children: [
              Expanded(child: Text('NAMA PROSES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.ocean))),
              const SizedBox(width: 8),
              Expanded(child: Text('TEKNOLOGI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.ocean))),
              const SizedBox(width: 32),
            ],
          ),
          const Divider(color: Color(0xFFBAE6FD)),
          ..._technologies.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(child: _buildTextField(e.value[0], hint: 'Nama Proses', isDense: true, isRequired: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(e.value[1], hint: 'Contoh: Python, Pandas, dsb', isDense: true, isRequired: true)),
              IconButton(icon: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFFECACA))), child: const Icon(Icons.close, size: 14, color: AppColors.error)), onPressed: () {
                if (_technologies.length > 1) setState(() { for (final c in _technologies[e.key]) { c.dispose(); } _technologies.removeAt(e.key); });
              }),
            ]),
          )),
        ], actionLabel: '+ Tambah Teknologi', onAction: () => setState(() => _technologies.add([TextEditingController(), TextEditingController()]))),
        const SizedBox(height: 12),
        _cardSection('Upload Diagram Proses Bisnis', null, [
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload akan tersedia setelah koneksi API'))),
            child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFBAE6FD), style: BorderStyle.solid)),
              child: Column(children: [
                const Icon(Icons.arrow_upward, size: 28, color: AppColors.ocean),
                const SizedBox(height: 6),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(color: AppColors.ocean, fontSize: 13, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(text: 'Drag & drop file di sini atau '),
                      TextSpan(text: 'pilih file', style: TextStyle(decoration: TextDecoration.underline)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Format: JPG, PNG, PDF (Maks 5MB)', style: TextStyle(color: AppColors.muted, fontSize: 11)),
              ]),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _cardSection(String title, String? desc, List<Widget> children, {String? actionLabel, VoidCallback? onAction}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBAE6FD))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ocean))),
              const SizedBox(width: 8),
              if (actionLabel != null)
                GestureDetector(
                  onTap: onAction,
                  child: Text(actionLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.ocean)),
                ),
            ],
          ),
          if (desc != null) ...[
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _checkItem(String label, String icon, String desc) {
    final checked = _presentations.contains(label);
    return GestureDetector(
      onTap: () => setState(() => checked ? _presentations.remove(label) : _presentations.add(label)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: checked ? AppColors.cyan : AppColors.cardBorder),
          color: checked ? const Color(0xFFE0F2FE) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(checked ? Icons.check_box : Icons.check_box_outline_blank, size: 18, color: checked ? AppColors.cyan : AppColors.muted),
            const SizedBox(width: 6),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('$icon $label', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ocean)),
                Text(desc, style: const TextStyle(fontSize: 9, color: AppColors.muted), maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ocean)),
  );

  Future<void> _submitIssue() async {
    setState(() => _attemptedNext = true);
    bool procValid = _processes.isNotEmpty && _processes.every((r) => r.every((c) => c.text.trim().isNotEmpty));
    bool techValid = _technologies.isNotEmpty && _technologies.every((r) => r.every((c) => c.text.trim().isNotEmpty));
    if (!procValid || !techValid) return;
    
    setState(() => _isSubmitting = true);
    if (_titleCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required'), backgroundColor: AppColors.error));
      setState(() => _isSubmitting = false);
      return;
    }
    
    try {
      await IssueService().createIssue(
        widget.projectId,
        title: _titleCtrl.text,
        description: _descCtrl.text,
        type: _type,
        priority: _priority,
        meaningfulObjectives: {
          'organizational': {'obj': _orgObjCtrl.text, 'how': _orgHowCtrl.text, 'measure': _orgMeasureCtrl.text},
          'leading_indicators': _indicators.map((e) => {'col1': e[0].text, 'col2': e[1].text, 'col3': e[2].text}).toList(),
          'user_outcomes': {'obj': _userOutCtrl.text, 'how': _userHowCtrl.text, 'measure': _userMeasureCtrl.text},
          'model_properties': {'obj': _modelPropCtrl.text, 'how': _modelHowCtrl.text, 'measure': _modelMeasureCtrl.text},
        },
        intelligenceExperience: {
          'presentation': {
            'automate': _presentations.contains('Automate'),
            'prompt': _presentations.contains('Prompt'),
            'organisation': _presentations.contains('Organisation'),
            'annotate': _presentations.contains('Annotate'),
            'desc': ''
          },
          'functions': _functions.map((e) => {'col1': e[0].text, 'col2': e[1].text}).toList(),
          'error_mitigation': _errorMitigation.map((e) => {'col1': e[0].text, 'col2': e[1].text}).toList(),
          'data_collection': _dataCollection.map((e) => {'col1': e[0].text, 'col2': e[1].text}).toList(),
        },
        intelligenceImplementation: {
          'business_process': _processes.map((e) => {'col1': e[0].text, 'col2': e[1].text}).toList(),
          'technology': _technologies.map((e) => {'col1': e[0].text, 'col2': e[1].text}).toList(),
        }
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Issue berhasil dibuat!'), backgroundColor: AppColors.success));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
        setState(() => _isSubmitting = false);
      }
    }
  }
}
