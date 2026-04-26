import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_theme.dart';
import '../../services/worker_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

class WorkerRegistrationScreen extends StatefulWidget {
  const WorkerRegistrationScreen({super.key});

  @override
  State<WorkerRegistrationScreen> createState() => _WorkerRegistrationScreenState();
}

class _WorkerRegistrationScreenState extends State<WorkerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _fixedRateController = TextEditingController();
  final _nidController = TextEditingController();
  final _workerService = WorkerService();

  final Set<String> _selectedSkills = {};
  String? _selectedDistrict;
  final Set<String> _selectedDays = {};
  String _startTime = '08:00';
  String _endTime = '18:00';
  bool _loading = false;

  final _timeSlots = ['06:00','07:00','08:00','09:00','10:00','11:00','12:00',
                      '13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00'];

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _hourlyRateController.dispose();
    _fixedRateController.dispose();
    _nidController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कम्तिमा एउटा सिप छान्नुहोस्।'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (_selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('जिल्ला छान्नुहोस्।'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _workerService.registerWorker({
        'name': _nameController.text.trim(),
        'skills': _selectedSkills.toList(),
        'bio': _bioController.text.trim(),
        'hourlyRate': double.tryParse(_hourlyRateController.text),
        'fixedRate': double.tryParse(_fixedRateController.text),
        'availabilityDays': _selectedDays.toList(),
        'availabilityStartTime': _startTime,
        'availabilityEndTime': _endTime,
        'nidNumber': _nidController.text.trim(),
        'locationDistrict': _selectedDistrict,
      });

      // Refresh user profile to get worker role
      await context.read<AuthProvider>().updateProfile({'role': 'worker', 'name': _nameController.text.trim()});

      if (mounted) context.go('/worker/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('दर्ता गर्न सकिएन: $e'), backgroundColor: AppColors.error),
        );
      }
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('कामदारको रूपमा दर्ता गर्नुहोस्')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('व्यक्तिगत जानकारी'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                validator: Validators.validateName,
                decoration: const InputDecoration(labelText: 'पूरा नाम *', prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nidController,
                validator: Validators.validateNid,
                decoration: const InputDecoration(
                  labelText: 'नागरिकता / NID नम्बर (ऐच्छिक)',
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'आफ्नो बारेमा छोटो परिचय',
                  hintText: 'मेरो X वर्षको अनुभव छ...',
                ),
              ),

              const SizedBox(height: 24),
              _sectionTitle('सिपहरू *'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: serviceCategories.where((c) => c.id != 'other').map((cat) {
                  final selected = _selectedSkills.contains(cat.id);
                  return FilterChip(
                    label: Text(cat.label),
                    avatar: Icon(cat.icon, size: 16),
                    selected: selected,
                    onSelected: (v) => setState(() => v
                        ? _selectedSkills.add(cat.id)
                        : _selectedSkills.remove(cat.id)),
                    selectedColor: AppColors.primary.withAlpha(26),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              _sectionTitle('स्थान'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedDistrict,
                decoration: const InputDecoration(labelText: 'जिल्ला *', prefixIcon: Icon(Icons.location_on)),
                items: nepalDistricts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setState(() => _selectedDistrict = v),
              ),

              const SizedBox(height: 24),
              _sectionTitle('मूल्य (NPR)'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hourlyRateController,
                      keyboardType: TextInputType.number,
                      validator: Validators.validateRate,
                      decoration: const InputDecoration(
                        labelText: 'प्रति घण्टा',
                        prefixText: 'रू ',
                        prefixIcon: Icon(Icons.schedule),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _fixedRateController,
                      keyboardType: TextInputType.number,
                      validator: Validators.validateRate,
                      decoration: const InputDecoration(
                        labelText: 'प्रति काम',
                        prefixText: 'रू ',
                        prefixIcon: Icon(Icons.work),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _sectionTitle('उपलब्धता'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(7, (i) {
                  final day = weekDays[i];
                  final label = weekDaysNp[i];
                  final selected = _selectedDays.contains(day);
                  return FilterChip(
                    label: Text(label, style: const TextStyle(fontSize: 13)),
                    selected: selected,
                    onSelected: (v) => setState(() => v
                        ? _selectedDays.add(day)
                        : _selectedDays.remove(day)),
                    selectedColor: AppColors.primary.withAlpha(26),
                    checkmarkColor: AppColors.primary,
                  );
                }),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _startTime,
                      decoration: const InputDecoration(labelText: 'सुरु समय'),
                      items: _timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) { if (v != null) setState(() => _startTime = v); },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _endTime,
                      decoration: const InputDecoration(labelText: 'समाप्त समय'),
                      items: _timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) { if (v != null) setState(() => _endTime = v); },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('दर्ता पूरा गर्नुहोस्'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));
  }
}
