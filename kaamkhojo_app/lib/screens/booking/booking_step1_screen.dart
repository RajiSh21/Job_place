import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/booking_provider.dart';
import '../../config/app_theme.dart';
import '../../utils/validators.dart';
import '../../utils/date_helpers.dart';

class BookingStep1Screen extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const BookingStep1Screen({super.key, this.extra});

  @override
  State<BookingStep1Screen> createState() => _BookingStep1ScreenState();
}

class _BookingStep1ScreenState extends State<BookingStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '10:00';
  List<String> _photoPaths = [];
  bool _fetchingLocation = false;

  final _timeSlots = ['08:00', '09:00', '10:00', '11:00', '12:00',
                      '13:00', '14:00', '15:00', '16:00', '17:00', '18:00'];

  @override
  void initState() {
    super.initState();
    // Restore draft if exists
    final bp = context.read<BookingProvider>();
    if (bp.draftDescription != null) _descController.text = bp.draftDescription!;
    if (bp.draftAddress != null) _addressController.text = bp.draftAddress!;
    if (bp.draftDate != null) _selectedDate = bp.draftDate!;
    if (bp.draftTime != null) _selectedTime = bp.draftTime!;
    _photoPaths = List.from(bp.draftPhotoPaths);

    // Set worker from extra if coming directly from profile
    if (widget.extra != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        bp.setDraftWorker(
          widget.extra!['workerId'] as String,
          widget.extra!['workerName'] as String? ?? 'Unknown',
          widget.extra!['serviceType'] as String? ?? 'other',
        );
      });
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveDraft() {
    context.read<BookingProvider>().updateDraftStep1(
      description: _descController.text,
      photoPaths: _photoPaths,
      date: _selectedDate,
      time: _selectedTime,
      address: _addressController.text,
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(imageQuality: 70);
    if (images.isNotEmpty) {
      setState(() {
        _photoPaths = [..._photoPaths, ...images.map((e) => e.path)].take(5).toList();
      });
      _saveDraft();
    }
  }

  Future<void> _useMyLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) await Geolocator.requestPermission();

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      context.read<BookingProvider>().updateDraftStep1(
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
      _addressController.text = '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('स्थान पत्ता लगाउन सकिएन।')),
        );
      }
    }
    if (mounted) setState(() => _fetchingLocation = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _saveDraft();
    }
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    _saveDraft();
    context.push('/booking/step2');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('बुकिङ विवरण (१/३)')),
      body: Form(
        key: _formKey,
        onChanged: _saveDraft,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step indicator
              _StepIndicator(current: 0),
              const SizedBox(height: 24),

              const Text('काम विवरण', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                validator: Validators.validateDescription,
                decoration: const InputDecoration(
                  hintText: 'के काम चाहिन्छ? विस्तारमा लेख्नुहोस्...',
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('फोटोहरू (ऐच्छिक)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  TextButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_photo_alternate, size: 18),
                    label: const Text('थप्नुहोस्'),
                  ),
                ],
              ),
              if (_photoPaths.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _photoPaths.length,
                    itemBuilder: (_, i) => Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: AssetImage(_photoPaths[i]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 10,
                          child: GestureDetector(
                            onTap: () => setState(() => _photoPaths.removeAt(i)),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              const Text('मिति र समय', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(DateHelpers.formatDate(_selectedDate)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedTime,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.access_time, size: 18),
                      ),
                      items: _timeSlots.map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(DateHelpers.formatTime(t)),
                      )).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedTime = v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'BS: ${DateHelpers.formatBsDate(_selectedDate)}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 20),
              const Text('ठेगाना', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                validator: (v) => Validators.validateRequired(v, 'ठेगाना'),
                decoration: const InputDecoration(hintText: 'पूरा ठेगाना लेख्नुहोस्'),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _fetchingLocation ? null : _useMyLocation,
                  icon: _fetchingLocation
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location, size: 18),
                  label: const Text('मेरो स्थान प्रयोग गर्नुहोस्'),
                ),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _next,
                child: const Text('अर्को'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  const _StepIndicator({required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final active = i == current;
        final done = i < current;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: done || active ? AppColors.primary : AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (i < 2) const SizedBox(width: 4),
            ],
          ),
        );
      }),
    );
  }
}
