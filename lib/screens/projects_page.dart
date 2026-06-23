import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/project_card.dart';
import '../widgets/empty_state.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late Future<List<Map<String, dynamic>>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }
  
  void _loadProjects() {
    setState(() {
      _projectsFuture = ProjectService().getProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('📁 All Projects'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.ocean),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.ocean, size: 28),
            onPressed: () => _showCreateWizard(context),
            tooltip: 'New Project',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadProjects(),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _projectsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.error)));
            }
            final projectsData = snapshot.data ?? [];
            if (projectsData.isEmpty) {
              return const EmptyState(icon: '📁', message: 'Belum ada proyek.\nBuat proyek pertamamu!');
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: projectsData.length,
              itemBuilder: (context, i) {
                final pData = projectsData[i];
                final p = Project.fromJson(pData);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: ProjectCard(
                    project: p,
                    onTapBoard: () => Navigator.pushNamed(context, '/board', arguments: {'projectId': p.id}),
                    onTapBacklog: () => Navigator.pushNamed(context, '/backlog', arguments: {'projectId': p.id}),
                    onTapTranscript: () => Navigator.pushNamed(context, '/transcript', arguments: {'projectId': p.id}),
                    onDelete: () => _confirmDelete(p),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(Project p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Proyek?'),
        content: Text('Apakah Anda yakin ingin menghapus "${p.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog
              try {
                await ApiService().delete('/api/projects/${p.id}');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Proyek "${p.name}" dihapus'), backgroundColor: AppColors.success));
                  _loadProjects();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: AppColors.error));
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showCreateWizard(BuildContext context) {
    showProjectWizard(context, onSaved: () => _loadProjects());
  }
}

void showProjectWizard(BuildContext context, {Project? initialProject, VoidCallback? onSaved}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
    builder: (_) => _CreateProjectWizard(
      initialProject: initialProject,
      onCreated: () {
        if (onSaved != null) onSaved();
      },
    ),
  );
}

class _CreateProjectWizard extends StatefulWidget {
  final Project? initialProject;
  final VoidCallback onCreated;
  const _CreateProjectWizard({this.initialProject, required this.onCreated});

  @override
  State<_CreateProjectWizard> createState() => _CreateProjectWizardState();
}

class _CreateProjectWizardState extends State<_CreateProjectWizard> {
  int _step = 0;
  final _nameCtrl = TextEditingController();
  final _keyCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
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
  final _deployCtrl = TextEditingController();
  String _type = 'scrum';
  DateTime? _startDate;
  DateTime? _endDate;
  final List<TextEditingController> _supervisors = [TextEditingController()];
  bool _attemptedNext = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProject;
    if (p != null) {
      _nameCtrl.text = p.name;
      _keyCtrl.text = p.key;
      _descCtrl.text = p.description;
      _type = p.type;
      _startDate = p.startDate;
      _endDate = p.endDate;
      _deployCtrl.text = p.deployment ?? '';
      _orgObjCtrl.text = p.orgObjective ?? '';
      _orgHowCtrl.text = p.orgHow ?? '';
      _orgMeasureCtrl.text = p.orgMeasure ?? '';
      _userOutCtrl.text = p.userOutcome ?? '';
      _userHowCtrl.text = p.userHow ?? '';
      _userMeasureCtrl.text = p.userMeasure ?? '';
      _modelPropCtrl.text = p.modelProperty ?? '';
      _modelHowCtrl.text = p.modelHow ?? '';
      _modelMeasureCtrl.text = p.modelMeasure ?? '';
      
      if (p.supervisors != null && p.supervisors!.isNotEmpty) {
        _supervisors.clear();
        for (var s in p.supervisors!) {
          _supervisors.add(TextEditingController(text: s));
        }
      }
      if (p.leadingIndicators != null && p.leadingIndicators!.isNotEmpty) {
        _indicators.clear();
        for (var i in p.leadingIndicators!) {
          _indicators.add([
            TextEditingController(text: i['fitur'] ?? ''),
            TextEditingController(text: i['sistemKita'] ?? ''),
            TextEditingController(text: i['kompetitor'] ?? ''),
          ]);
        }
      }
    }
  }

  Widget _buildTextField(TextEditingController ctrl, {String hint = '', int maxLines = 1, int? maxLength, void Function(String)? onChanged, bool isRequired = false, bool isDense = false}) {
    final hasError = isRequired && _attemptedNext && ctrl.text.trim().isEmpty;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: hasError ? const [
          BoxShadow(
            color: Color(0x66F44336), // red with opacity 0.4
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ] : const [],
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        maxLength: maxLength,
        onChanged: (v) {
          if (_attemptedNext) setState(() {});
          if (onChanged != null) onChanged(v);
        },
        decoration: InputDecoration(
          hintText: hint,
          fillColor: Colors.white,
          filled: true,
          isDense: isDense,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: hasError ? Colors.red : const Color(0xFFE5E7EB), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: hasError ? Colors.red : AppColors.primaryBlue, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _keyCtrl.dispose(); _descCtrl.dispose();
    _orgObjCtrl.dispose(); _orgHowCtrl.dispose(); _orgMeasureCtrl.dispose();
    _userOutCtrl.dispose(); _userHowCtrl.dispose(); _userMeasureCtrl.dispose();
    _modelPropCtrl.dispose(); _modelHowCtrl.dispose(); _modelMeasureCtrl.dispose();
    for (final row in _indicators) { for (final c in row) { c.dispose(); } }
    _deployCtrl.dispose();
    for (final s in _supervisors) { s.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(gradient: AppColors.gradient, borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: const Text('🗂️', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10),
                const Text('Create New Project', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ocean)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.close, size: 16, color: AppColors.text2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Stepper
            Row(
              children: List.generate(3, (i) {
                final done = i < _step;
                final active = i == _step;
                return Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done ? AppColors.success : (active ? AppColors.primaryBlue : Colors.white),
                          border: Border.all(color: done ? AppColors.success : (active ? AppColors.primaryBlue : const Color(0xFFD1D5DB)), width: 2),
                        ),
                        alignment: Alignment.center,
                        child: done
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : Text('${i + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? Colors.white : const Color(0xFF9CA3AF))),
                      ),
                      if (i < 2) Expanded(child: Container(height: 2, color: done ? AppColors.success : const Color(0xFFE5E7EB))),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Info', 'Objectives', 'Planning'].asMap().entries.map((e) {
                final active = e.key == _step;
                final done = e.key < _step;
                return Text(e.value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: done ? AppColors.success : (active ? AppColors.primaryBlue : AppColors.muted)));
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Content
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                children: [
                  if (_step == 0) ..._step1(),
                  if (_step == 1) ..._step2(),
                  if (_step == 2) ..._step3(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Footer
            Row(
              children: [
                OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                const Spacer(),
                if (_step > 0)
                  OutlinedButton(onPressed: () => setState(() => _step--), child: const Text('← Back')),
                const SizedBox(width: 8),
                if (_step < 2)
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _attemptedNext = true);
                      if (_step == 0) {
                        if (_nameCtrl.text.trim().isEmpty || _keyCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) return;
                      } else if (_step == 1) {
                        bool indicatorsValid = _indicators.isNotEmpty && _indicators.every((row) => row.every((c) => c.text.trim().isNotEmpty));
                        if (!indicatorsValid || _orgObjCtrl.text.trim().isEmpty || _orgHowCtrl.text.trim().isEmpty || _orgMeasureCtrl.text.trim().isEmpty ||
                            _userOutCtrl.text.trim().isEmpty || _userHowCtrl.text.trim().isEmpty || _userMeasureCtrl.text.trim().isEmpty ||
                            _modelPropCtrl.text.trim().isEmpty || _modelHowCtrl.text.trim().isEmpty || _modelMeasureCtrl.text.trim().isEmpty) {
                          return;
                        }
                      }
                      setState(() {
                        _step++;
                        _attemptedNext = false;
                      });
                    },
                    child: const Text('Next →'),
                  ),
                if (_step == 2)
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _attemptedNext = true);
                      if (_deployCtrl.text.trim().isEmpty) return;
                      _createProject();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                    child: Text(widget.initialProject == null ? '✅ Create' : '💾 Save', style: const TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _step1() {
    return [
      _fieldLabel('Project Name *'),
      _buildTextField(_nameCtrl, hint: 'e.g. AI Platform v3', isRequired: true, onChanged: (v) {
        if (_keyCtrl.text.isEmpty || _keyCtrl.text.length <= 5) {
          _keyCtrl.text = v.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase().substring(0, v.length > 3 ? 3 : v.length);
        }
      }),
      const SizedBox(height: 14),
      _fieldLabel('Project Key *'),
      _buildTextField(_keyCtrl, hint: 'e.g. AIP', maxLength: 5, isRequired: true, onChanged: (v) => _keyCtrl.text = v.toUpperCase()),
      const SizedBox(height: 14),
      _fieldLabel('Type'),
      DropdownButtonFormField<String>(
        initialValue: _type,
        items: ['scrum', 'kanban', 'safe', 'custom'].map((t) => DropdownMenuItem(value: t, child: Text(t[0].toUpperCase() + t.substring(1)))).toList(),
        onChanged: (v) => setState(() => _type = v!),
        decoration: const InputDecoration(),
      ),
      const SizedBox(height: 14),
      _fieldLabel('Description *'),
      _buildTextField(_descCtrl, maxLines: 3, hint: 'Describe your project...', isRequired: true),
    ];
  }

  List<Widget> _step2() {
    return [
      _cardSection('Organizational Objectives *', 'Apa nilai bisnis utama yang ingin dicapai perusahaan melalui sistem cerdas ini?', [
        _buildTextField(_orgObjCtrl, maxLines: 2, hint: 'Contoh: Meningkatkan pendapatan tenant kantin...', isRequired: true),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _fieldLabel('Bagaimana cara mencapainya?'),
              _buildTextField(_orgHowCtrl, maxLines: 2, isRequired: true),
            ])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _fieldLabel('Bagaimana cara mengukurnya?'),
              _buildTextField(_orgMeasureCtrl, maxLines: 2, isRequired: true),
            ])),
          ],
        ),
      ]),
      const SizedBox(height: 12),
      _cardSection('Leading Indicators *', 'Indikator metrik prediksi keberhasilan dibandingkan kompetitor.', [
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
            Expanded(child: _buildTextField(e.value[0], hint: 'Kecepatan', isDense: true, isRequired: true)),
            const SizedBox(width: 6),
            Expanded(child: _buildTextField(e.value[1], hint: '< 10 detik', isDense: true, isRequired: true)),
            const SizedBox(width: 6),
            Expanded(child: _buildTextField(e.value[2], hint: '5 Menit', isDense: true, isRequired: true)),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFFECACA))),
                child: const Icon(Icons.close, size: 14, color: AppColors.error),
              ),
              onPressed: () {
                if (_indicators.length > 1) {
                  setState(() { for (final c in _indicators[e.key]) { c.dispose(); } _indicators.removeAt(e.key); });
                }
              },
            ),
          ]),
        )),
      ], actionLabel: '+ Tambah Baris', onAction: () => setState(() => _indicators.add([TextEditingController(), TextEditingController(), TextEditingController()]))),
      const SizedBox(height: 12),
      _cardSection('User Outcomes *', 'Manfaat nyata apa yang akan dirasakan oleh pengguna?', [
        _buildTextField(_userOutCtrl, maxLines: 2, hint: 'Siswa langsung mendapat pilihan makanan yang pas...', isRequired: true),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _fieldLabel('Bagaimana cara mencapainya?'),
              _buildTextField(_userHowCtrl, maxLines: 2, isRequired: true),
            ])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _fieldLabel('Bagaimana cara mengukurnya?'),
              _buildTextField(_userMeasureCtrl, maxLines: 2, isRequired: true),
            ])),
          ],
        ),
      ]),
      const SizedBox(height: 12),
      _cardSection('Model Properties *', 'Spesifikasi teknis dan kriteria akurasi model AI/Machine Learning-nya.', [
        _buildTextField(_modelPropCtrl, maxLines: 2, hint: 'Model rekomendasi harus mampu memberikan saran real-time...', isRequired: true),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _fieldLabel('Bagaimana cara mencapainya?'),
              _buildTextField(_modelHowCtrl, maxLines: 2, isRequired: true),
            ])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _fieldLabel('Bagaimana cara mengukurnya?'),
              _buildTextField(_modelMeasureCtrl, maxLines: 2, isRequired: true),
            ])),
          ],
        ),
      ]),
    ];
  }

  List<Widget> _step3() {
    return [
      Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _fieldLabel('Start Date'),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(context: context, firstDate: DateTime(2024), lastDate: DateTime(2030));
                if (d != null) setState(() => _startDate = d);
              },
              child: InputDecorator(
                decoration: const InputDecoration(),
                child: Text(_startDate != null ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}' : 'Select date', style: TextStyle(color: _startDate != null ? AppColors.text : AppColors.muted)),
              ),
            ),
          ])),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _fieldLabel('End Date'),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(context: context, firstDate: DateTime(2024), lastDate: DateTime(2030));
                if (d != null) setState(() => _endDate = d);
              },
              child: InputDecorator(
                decoration: const InputDecoration(),
                child: Text(_endDate != null ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}' : 'Select date', style: TextStyle(color: _endDate != null ? AppColors.text : AppColors.muted)),
              ),
            ),
          ])),
        ],
      ),
      const SizedBox(height: 14),
      _fieldLabel('Deployment *'),
      _buildTextField(_deployCtrl, maxLines: 2, hint: 'Deployment plan', isRequired: true),
      const SizedBox(height: 14),
      _fieldLabel('Supervisors'),
      ...List.generate(_supervisors.length, (i) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(child: TextField(controller: _supervisors[i], decoration: const InputDecoration(hintText: 'Supervisor name'))),
            const SizedBox(width: 8),
            if (_supervisors.length > 1)
              IconButton(
                onPressed: () => setState(() { _supervisors[i].dispose(); _supervisors.removeAt(i); }),
                icon: Container(width: 28, height: 28, decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(7), border: Border.all(color: const Color(0xFFFCA5A5))),
                  child: const Icon(Icons.close, size: 14, color: Color(0xFFDC2626))),
              ),
          ],
        ),
      )),
      GestureDetector(
        onTap: () => setState(() => _supervisors.add(TextEditingController())),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: AppColors.cardBorder, style: BorderStyle.solid),
          ),
          alignment: Alignment.center,
          child: const Text('+ Add Supervisor', style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ),
    ];
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ocean)),
    );
  }

  Widget _cardSection(String title, String desc, List<Widget> children, {String? actionLabel, VoidCallback? onAction}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBAE6FD))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ocean)),
              const Spacer(),
              if (actionLabel != null)
                GestureDetector(
                  onTap: onAction,
                  child: Text(actionLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.ocean)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
  Future<void> _createProject() async {
    try {
      if (widget.initialProject == null) {
        // Create new project
        await ProjectService().createProject(
          name: _nameCtrl.text,
          key: _keyCtrl.text,
          type: _type,
          description: _descCtrl.text,
        );
      } else {
        // Update existing project
        await ProjectService().updateProject(
          widget.initialProject!.id,
          name: _nameCtrl.text,
          description: _descCtrl.text,
          status: widget.initialProject!.status,
        );
      }
      
      if (mounted) {
        widget.onCreated();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.initialProject == null ? 'Project created successfully!' : 'Project saved successfully!'), backgroundColor: AppColors.success));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
  }
}
