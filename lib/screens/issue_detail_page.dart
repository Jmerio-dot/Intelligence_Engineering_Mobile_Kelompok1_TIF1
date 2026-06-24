import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/issue_service.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class IssueDetailPage extends StatefulWidget {
  final int issueId;
  const IssueDetailPage({super.key, required this.issueId});

  @override
  State<IssueDetailPage> createState() => _IssueDetailPageState();
}

class _IssueDetailPageState extends State<IssueDetailPage> {
  Map<String, dynamic>? _issue;
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  final _commentCtrl = TextEditingController();
  
  bool _loading = true;
  String? _error;

  int _selectedTab = 0;
  final List<String> _tabs = [
    'Meaningful Objectives',
    'Intelligence Experiences',
    'Intelligence Implementation',
    'Creation Status',
    'Orchestration'
  ];

  Map<int, String> _tabContents = {};

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await IssueService().getIssue(widget.issueId);
      if (!mounted) return;
      
      setState(() {
        _issue = data;
        _titleCtrl.text = data['title'] ?? '';
        _descCtrl.text = data['description'] ?? '';
        
        _tabContents = {
          0: 'Tujuan: Menciptakan satu pintu input data terstruktur yang memvalidasi setiap variabel barang secara presisi.\nCara: Menerapkan form terstandardisasi dengan batasan tipe input.\nUkuran: End-to-End Success Rate.\n\nLeading Indicators:\n• Prediksi Total Harga Akhir\n• Kalkulasi Pajak & Bea Cukai\n• Penentuan Asuransi & Risiko\n• Waktu Penyelesaian Form',
          1: 'Belum ada data Intelligence Experiences.',
          2: 'Belum ada data Intelligence Implementation.',
          3: 'Status saat ini: ${data['creation_progress'] ?? 0}%',
          4: _buildOrchestration(data),
        };
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _buildOrchestration(Map<String, dynamic> data) {
    final status = data['creation_status'];
    if (status == null || status is! Map) return 'Belum ada data Orchestration.';
    final orch = status['orchestration'];
    if (orch == null || orch is! List || orch.isEmpty) return 'Belum ada data Orchestration.';
    
    return (orch as List).map((o) {
      return '■ ${o['category'] ?? '-'}\n   Status: ${o['status'] ?? '-'}\n   Created At: ${o['created_at'] ?? '-'}';
    }).join('\n\n');
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose(); _commentCtrl.dispose();
    super.dispose();
  }

  // Helper: time ago
  static String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.ocean), onPressed: () => Navigator.pop(context)),
          title: const Text('Detail Issue'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _issue == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.ocean), onPressed: () => Navigator.pop(context)),
          title: const Text('Detail Issue'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(_error ?? 'Issue not found', style: const TextStyle(color: AppColors.error, fontSize: 14)),
              const SizedBox(height: 16),
              ElevatedButton.icon(onPressed: _loadData, icon: const Icon(Icons.refresh), label: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }

    final issueType = _issue!['type'] ?? 'task';
    final issueKey = _issue!['issue_key'] ?? '';
    final labels = _issue!['labels'] != null ? (_issue!['labels'] as String).split(',') : [];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.ocean), onPressed: () => Navigator.pop(context)),
        title: Row(
          children: [
            Text(AppColors.typeIcon[issueType] ?? '✅', style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(issueKey, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ocean)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20, color: AppColors.ocean),
            onPressed: _showEditTabModal,
          ),
          IconButton(
            icon: const Text('💾', style: TextStyle(fontSize: 18)),
            onPressed: _saveIssue,
          ),
          IconButton(
            icon: const Text('🗑', style: TextStyle(fontSize: 18)),
            onPressed: _deleteIssue,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleCtrl,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ocean),
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Issue title'),
              ),
              const SizedBox(height: 4),
              // Description
              _sectionLabel('DESKRIPSI'),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Tambahkan deskripsi...'),
              ),
              const SizedBox(height: 20),

              // ── Tabs ──
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 2)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, color: _selectedTab > 0 ? AppColors.ocean : AppColors.muted),
                      onPressed: _selectedTab > 0 ? () => setState(() => _selectedTab--) : null,
                    ),
                    Expanded(
                      child: Text(
                        _tabs[_selectedTab],
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right, color: _selectedTab < _tabs.length - 1 ? AppColors.ocean : AppColors.muted),
                      onPressed: _selectedTab < _tabs.length - 1 ? () => setState(() => _selectedTab++) : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Tab Content
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  _tabContents[_selectedTab] ?? '',
                  style: const TextStyle(fontSize: 13, color: AppColors.text, height: 1.5),
                ),
              ),
              const SizedBox(height: 20),

              // ── Meta Panel ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _dropdownRow('Status', _issue!['status'] ?? 'todo', AppColors.statusLabel, (v) => setState(() => _issue!['status'] = v)),
                    const Divider(height: 20, color: AppColors.cardBorder),
                    _dropdownRow('Prioritas', _issue!['priority'] ?? 'medium',
                      {'critical': '🔴 Critical', 'high': '🟠 High', 'medium': '🟡 Medium', 'low': '🟢 Low'},
                      (v) => setState(() => _issue!['priority'] = v)),
                    const Divider(height: 20, color: AppColors.cardBorder),
                    _dropdownRow('Type', _issue!['type'] ?? 'task',
                      {'story': '📗 Story', 'task': '✅ Task', 'bug': '🐛 Bug', 'epic': '⚡ Epic', 'subtask': '🔲 Subtask'},
                      (v) {}),
                    const Divider(height: 20, color: AppColors.cardBorder),
                    // Assignee
                    _metaRow('Assignee', _issue!['assignee_name'] ?? 'Unassigned'),
                    const Divider(height: 20, color: AppColors.cardBorder),
                    // Story Points
                    Row(
                      children: [
                        const SizedBox(width: 100, child: Text('Story Points', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text2))),
                        Expanded(
                          child: TextFormField(
                            initialValue: _issue!['story_points']?.toString() ?? '',
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '-', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                            onChanged: (v) => _issue!['story_points'] = int.tryParse(v),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.cardBorder),
                    // Labels
                    _metaRow('Labels', labels.isNotEmpty ? labels.join(', ') : 'None'),
                    const Divider(height: 20, color: AppColors.cardBorder),
                    // Due Date
                    Row(
                      children: [
                        const SizedBox(width: 100, child: Text('Due Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text2))),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              DateTime? initial = _issue!['due_date'] != null ? DateTime.tryParse(_issue!['due_date']) : null;
                              final d = await showDatePicker(context: context, firstDate: DateTime(2024), lastDate: DateTime(2030), initialDate: initial ?? DateTime.now());
                              if (d != null) setState(() => _issue!['due_date'] = d.toIso8601String());
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.cardBorder)),
                              child: Text(_issue!['due_date'] != null ? _issue!['due_date'].toString().split('T')[0] : 'Select date',
                                style: TextStyle(fontSize: 13, color: _issue!['due_date'] != null ? AppColors.text : AppColors.muted)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.cardBorder),
                    _metaRow('Reporter', _issue!['reporter_name'] ?? '-'),
                    const Divider(height: 20, color: AppColors.cardBorder),
                    _metaRow('Created', _timeAgo(_issue!['created_at'])),
                    const Divider(height: 20, color: AppColors.cardBorder),
                    _metaRow('Updated', _timeAgo(_issue!['updated_at'])),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Comments ──
              _sectionLabel('💬 Komentar (${(_issue!['comments'] as List?)?.length ?? 0})'),
              if (_issue!['comments'] != null && (_issue!['comments'] as List).isNotEmpty)
                ...(_issue!['comments'] as List).map((c) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30, height: 30,
                        decoration: const BoxDecoration(gradient: AppColors.gradient2, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text((c['user_name'] as String?)?.substring(0, 1).toUpperCase() ?? 'U', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.inputBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(c['user_name'] ?? 'User', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ocean)),
                                  const SizedBox(width: 6),
                                  Text(_timeAgo(c['created_at']), style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(c['content'] ?? '', style: const TextStyle(fontSize: 13, color: AppColors.text, height: 1.4)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              const SizedBox(height: 8),
              // Comment input
              Row(
                children: [
                  Container(
                    width: 30, height: 30,
                    decoration: const BoxDecoration(gradient: AppColors.gradient2, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const Text('?', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      decoration: const InputDecoration(hintText: 'Tulis komentar...', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _addComment,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(gradient: AppColors.gradient2, borderRadius: BorderRadius.circular(9)),
                      child: const Text('Kirim', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ocean, letterSpacing: 0.5)),
    );
  }

  Widget _metaRow(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text2))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: AppColors.text))),
      ],
    );
  }

  Widget _dropdownRow(String label, String current, Map<String, String> options, Function(String) onChanged) {
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text2))),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.cardBorder)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: options.containsKey(current) ? current : options.keys.first,
                isExpanded: true,
                isDense: true,
                style: const TextStyle(fontSize: 13, color: AppColors.text),
                items: options.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                onChanged: (v) { if (v != null) onChanged(v); },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveIssue() async {
    if (_titleCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and description cannot be empty'), backgroundColor: AppColors.error));
      return;
    }
    
    try {
      await IssueService().updateIssue(
        widget.issueId,
        {
          'title': _titleCtrl.text,
          'description': _descCtrl.text,
          'status': _issue!['status'],
          'priority': _issue!['priority'],
          'story_points': _issue!['story_points'],
          'due_date': _issue!['due_date'],
        }
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Issue saved!'), backgroundColor: AppColors.success));
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  void _showEditTabModal() {
    final TextEditingController ctrl = TextEditingController(text: _tabContents[_selectedTab]);
    bool attemptedSave = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          final hasError = attemptedSave && ctrl.text.trim().isEmpty;
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 16, right: 16, top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit ${_tabs[_selectedTab]}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ocean)),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: hasError ? const [BoxShadow(color: Color(0x66F44336), blurRadius: 6, spreadRadius: 1)] : const [],
                  ),
                  child: TextField(
                    controller: ctrl,
                    maxLines: 8,
                    minLines: 4,
                    onChanged: (v) {
                      if (attemptedSave) setModalState(() {});
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: hasError ? Colors.red : AppColors.cardBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: hasError ? Colors.red : AppColors.cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: hasError ? Colors.red : AppColors.primaryBlue)),
                      hintText: 'Masukkan konten...',
                      contentPadding: const EdgeInsets.all(16),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setModalState(() => attemptedSave = true);
                      if (ctrl.text.trim().isEmpty) return;
                      setState(() {
                        _tabContents[_selectedTab] = ctrl.text;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil diubah'), backgroundColor: AppColors.success));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteIssue() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Issue?'),
        content: Text('Delete "${_issue!['title']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (res == true) {
      try {
        await ApiService().delete('/api/issues/${widget.issueId}');
        if (mounted) {
          Navigator.pop(context); // pop detail page
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Issue deleted'), backgroundColor: AppColors.success));
        }
      } catch (e) {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
        }
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentCtrl.text.isEmpty) return;
    try {
      await ApiService().post('/api/issues/${widget.issueId}/comments', body: {
        'content': _commentCtrl.text
      });
      _commentCtrl.clear();
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
  }
}
