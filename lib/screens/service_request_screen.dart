import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ServiceRequestScreen extends StatefulWidget {
  const ServiceRequestScreen({super.key});

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen>
    with TickerProviderStateMixin {
  // Controllers
  final _issueTitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController(text: 'Tower A - Flat 204');
  final _contactController = TextEditingController(text: '+91 98765 43210');
  final _notesController = TextEditingController();
  final _scrollController = ScrollController();

  // State
  String? _selectedCategory;
  String _selectedPriority = 'Medium';
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  bool _isAnalyzing = false;
  bool _aiAnalysisDone = false;
  bool _isSubmitting = false;
  final List<String> _uploadedImages = [];

  // Animation controllers
  late AnimationController _bgOrbController;
  late AnimationController _aiPulseController;
  late AnimationController _formSlideController;
  late Animation<double> _formFadeAnim;
  late Animation<Offset> _formSlideAnim;

  final List<String> _categories = [
    'Plumbing',
    'Electrical',
    'Cleaning',
    'Internet / WiFi',
    'Security',
    'Appliance Repair',
    'Water Leakage',
    'Other',
  ];

  final List<Map<String, dynamic>> _priorities = [
    {'label': 'Low', 'color': const Color(0xFF22D3EE), 'icon': Icons.arrow_downward_rounded},
    {'label': 'Medium', 'color': const Color(0xFF818CF8), 'icon': Icons.remove_rounded},
    {'label': 'High', 'color': const Color(0xFFF97316), 'icon': Icons.arrow_upward_rounded},
    {'label': 'Emergency', 'color': const Color(0xFFEF4444), 'icon': Icons.priority_high_rounded},
  ];

  final List<String> _timeSlots = [
    '8:00 AM – 10:00 AM',
    '10:00 AM – 12:00 PM',
    '12:00 PM – 2:00 PM',
    '2:00 PM – 4:00 PM',
    '4:00 PM – 6:00 PM',
    '6:00 PM – 8:00 PM',
  ];

  // AI mock data
  final Map<String, dynamic> _aiResult = {
    'score': 82,
    'severity': 'HIGH',
    'label': 'Possible water leakage detected',
    'message': 'AI detected moisture patterns consistent with pipe leakage. Immediate attention recommended.',
    'responseTime': 'Within 2 hours',
  };

  @override
  void initState() {
    super.initState();
    _bgOrbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _aiPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _formSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _formFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _formSlideController, curve: Curves.easeOut),
    );
    _formSlideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _formSlideController, curve: Curves.easeOutCubic),
    );
    _formSlideController.forward();
  }

  @override
  void dispose() {
    _issueTitleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    _bgOrbController.dispose();
    _aiPulseController.dispose();
    _formSlideController.dispose();
    super.dispose();
  }

  void _simulateImageUpload() {
    setState(() {
      _uploadedImages.add('img_${_uploadedImages.length + 1}');
      _isAnalyzing = true;
      _aiAnalysisDone = false;
    });
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _aiAnalysisDone = true;
        });
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF818CF8),
            surface: Color(0xFF1A1A2E),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      setState(() => _isSubmitting = false);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    final ticketId = 'NVS-${1000 + Random().nextInt(8999)}';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SuccessDialog(ticketId: ticketId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: Stack(
        children: [
          // Animated background orbs
          _buildBackground(),
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _formFadeAnim,
              child: SlideTransition(
                position: _formSlideAnim,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverToBoxAdapter(child: _buildBody()),
                    const SliverToBoxAdapter(child: SizedBox(height: 140)),
                  ],
                ),
              ),
            ),
          ),
          // Bottom CTA bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _bgOrbController,
      builder: (context, _) {
        final t = _bgOrbController.value;
        return Stack(
          children: [
            Positioned(
              top: -80 + (t * 40),
              right: -60,
              child: _glowOrb(280, const Color(0xFF6366F1), 0.18),
            ),
            Positioned(
              top: 200 + (t * 30),
              left: -80,
              child: _glowOrb(220, const Color(0xFF06B6D4), 0.12),
            ),
            Positioned(
              bottom: 100 - (t * 50),
              right: 20,
              child: _glowOrb(180, const Color(0xFF8B5CF6), 0.14),
            ),
          ],
        );
      },
    );
  }

  Widget _glowOrb(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button + title row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: _glassButton(
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white.withOpacity(0.7), size: 16),
                ),
              ),
              const Spacer(),
              _glassButton(
                child: Icon(Icons.bookmark_border_rounded,
                    color: Colors.white.withOpacity(0.5), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF818CF8),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'MAINTENANCE REQUEST',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    letterSpacing: 2.0,
                    color: Color(0xFF818CF8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFF8FAFF), Color(0xFF818CF8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              'Raise a Service\nRequest',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Describe your issue and our team will assist you shortly.',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w300,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Service Category
          _sectionLabel('Service Category'),
          const SizedBox(height: 12),
          _buildCategorySelector(),
          const SizedBox(height: 28),

          // 2. Issue Title
          _sectionLabel('Issue Title'),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _issueTitleController,
            hint: 'Enter issue title',
            icon: Icons.title_rounded,
          ),
          const SizedBox(height: 28),

          // 3. Description
          _sectionLabel('Detailed Description'),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _descriptionController,
            hint: 'Describe the issue in detail…',
            icon: Icons.description_outlined,
            maxLines: 4,
          ),
          const SizedBox(height: 28),

          // 4. Location
          _sectionLabel('Location / Flat Number'),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _locationController,
            hint: 'Tower A - Flat 204',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 28),

          // 5. Priority
          _sectionLabel('Priority'),
          const SizedBox(height: 12),
          _buildPrioritySelector(),
          const SizedBox(height: 28),

          // 6. Image Upload
          _sectionLabel('Upload Issue Images'),
          const SizedBox(height: 6),
          Text(
            'Adding images helps us resolve issues faster.',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              color: Colors.white.withOpacity(0.35),
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 12),
          _buildImageUpload(),
          if (_uploadedImages.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildImagePreviews(),
          ],

          // 7. AI Analysis
          if (_isAnalyzing || _aiAnalysisDone) ...[
            const SizedBox(height: 24),
            _buildAiAnalysisCard(),
          ],

          const SizedBox(height: 28),

          // 8. Preferred Visit Time
          _sectionLabel('Preferred Visit Time'),
          const SizedBox(height: 12),
          _buildDateTimePicker(),
          const SizedBox(height: 28),

          // 9. Contact Number
          _sectionLabel('Contact Number'),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _contactController,
            hint: '+91 XXXXX XXXXX',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 28),

          // 10. Notes
          _sectionLabel('Additional Notes'),
          const SizedBox(height: 4),
          Text(
            'Optional',
            style: TextStyle(fontFamily: 'Manrope', fontSize: 11, color: Colors.white.withOpacity(0.3)),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _notesController,
            hint: 'Any special instructions or notes…',
            icon: Icons.notes_rounded,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 10,
        letterSpacing: 2.0,
        color: Colors.white.withOpacity(0.4),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return GestureDetector(
      onTap: _showCategorySheet,
      child: _glassCard(
        child: Row(
          children: [
            Icon(Icons.grid_view_rounded,
                size: 20, color: Colors.white.withOpacity(0.4)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _selectedCategory ?? 'Select service category',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  color: _selectedCategory != null
                      ? Colors.white.withOpacity(0.9)
                      : Colors.white.withOpacity(0.35),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(Icons.expand_more_rounded,
                color: Colors.white.withOpacity(0.4), size: 22),
          ],
        ),
      ),
    );
  }

  void _showCategorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111118).withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'SELECT CATEGORY',
                    style: TextStyle(
                      fontFamily: 'Manrope', fontSize: 10,
                      letterSpacing: 2.5, color: Color(0xFF818CF8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = cat);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6366F1).withOpacity(0.2)
                              : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF6366F1).withOpacity(0.5)
                                : Colors.white.withOpacity(0.06),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              cat,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 15,
                                color: isSelected
                                    ? const Color(0xFF818CF8)
                                    : Colors.white.withOpacity(0.8),
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w300,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(Icons.check_rounded,
                                  color: Color(0xFF818CF8), size: 18),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return _glassCard(
      padding: EdgeInsets.symmetric(
          horizontal: 20, vertical: maxLines > 1 ? 16 : 0),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 2 : 0),
            child: Icon(icon, size: 20, color: Colors.white.withOpacity(0.35)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w300,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.25),
                  fontWeight: FontWeight.w300,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                    vertical: maxLines > 1 ? 0 : 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      children: _priorities.map((p) {
        final isSelected = _selectedPriority == p['label'];
        final color = p['color'] as Color;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPriority = p['label']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color.withOpacity(0.7) : Colors.white.withOpacity(0.07),
                ),
              ),
              child: Column(
                children: [
                  Icon(p['icon'] as IconData,
                      size: 16,
                      color: isSelected ? color : Colors.white.withOpacity(0.3)),
                  const SizedBox(height: 6),
                  Text(
                    p['label'],
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10,
                      letterSpacing: 0.5,
                      color: isSelected ? color : Colors.white.withOpacity(0.4),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImageUpload() {
    return GestureDetector(
      onTap: _simulateImageUpload,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                width: 1.5,
                // dashed-like look via strokeAlign
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined,
                        color: const Color(0xFF818CF8).withOpacity(0.7), size: 24),
                    const SizedBox(width: 16),
                    Icon(Icons.photo_library_outlined,
                        color: const Color(0xFF22D3EE).withOpacity(0.7), size: 24),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap to upload or drag images here',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'PNG, JPG, HEIC up to 10MB each',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreviews() {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _uploadedImages.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          if (i == _uploadedImages.length) {
            return GestureDetector(
              onTap: _simulateImageUpload,
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1), style: BorderStyle.solid),
                ),
                child: Icon(Icons.add_rounded,
                    color: Colors.white.withOpacity(0.3), size: 28),
              ),
            );
          }
          return Stack(
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1).withOpacity(0.3),
                      const Color(0xFF06B6D4).withOpacity(0.3),
                    ],
                  ),
                  border: Border.all(color: const Color(0xFF818CF8).withOpacity(0.4)),
                ),
                child: Center(
                  child: Icon(Icons.image_rounded,
                      color: Colors.white.withOpacity(0.5), size: 28),
                ),
              ),
              Positioned(
                top: 4, right: 4,
                child: GestureDetector(
                  onTap: () => setState(() => _uploadedImages.removeAt(i)),
                  child: Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 12),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAiAnalysisCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F1A).withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isAnalyzing
                  ? const Color(0xFF818CF8).withOpacity(0.4)
                  : const Color(0xFFEF4444).withOpacity(0.4),
            ),
          ),
          child: _isAnalyzing
              ? _buildAiLoading()
              : _buildAiResult(),
        ),
      ),
    );
  }

  Widget _buildAiLoading() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _aiPulseController,
          builder: (_, __) => Opacity(
            opacity: 0.5 + (_aiPulseController.value * 0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: Color(0xFF818CF8), size: 20),
                const SizedBox(width: 10),
                Text(
                  'Analyzing issue severity…',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    color: Color(0xFF818CF8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            backgroundColor: Colors.white.withOpacity(0.08),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF818CF8)),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) => _skeletonLine(
            width: [120.0, 80.0, 100.0][i],
          )),
        ),
      ],
    );
  }

  Widget _skeletonLine({double width = 100}) {
    return AnimatedBuilder(
      animation: _aiPulseController,
      builder: (_, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        width: width,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05 + _aiPulseController.value * 0.05),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _buildAiResult() {
    final score = _aiResult['score'] as int;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Color(0xFFEF4444), size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI URGENCY DETECTION',
                  style: TextStyle(
                    fontFamily: 'Manrope', fontSize: 10,
                    letterSpacing: 1.8, color: Color(0xFF818CF8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _aiResult['label'],
                  style: TextStyle(
                    fontFamily: 'Manrope', fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Score bar
        Row(
          children: [
            Text(
              'Urgency Score',
              style: TextStyle(
                fontFamily: 'Manrope', fontSize: 12,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const Spacer(),
            Text(
              '$score / 100',
              style: const TextStyle(
                fontFamily: 'Manrope', fontSize: 13,
                color: Color(0xFFEF4444), fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 6,
            backgroundColor: Colors.white.withOpacity(0.07),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
          ),
          child: Text(
            _aiResult['message'],
            style: TextStyle(
              fontFamily: 'Manrope', fontSize: 13,
              color: Colors.white.withOpacity(0.75),
              fontWeight: FontWeight.w300, height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.schedule_rounded,
                size: 14, color: Color(0xFF22D3EE)),
            const SizedBox(width: 6),
            Text(
              'Suggested Response: ${_aiResult['responseTime']}',
              style: const TextStyle(
                fontFamily: 'Manrope', fontSize: 12,
                color: Color(0xFF22D3EE), fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      children: [
        // Date
        GestureDetector(
          onTap: _pickDate,
          child: _glassCard(
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 20, color: Colors.white.withOpacity(0.4)),
                const SizedBox(width: 14),
                Text(
                  _selectedDate == null
                      ? 'Select preferred date'
                      : '${_selectedDate!.day} / ${_selectedDate!.month} / ${_selectedDate!.year}',
                  style: TextStyle(
                    fontFamily: 'Manrope', fontSize: 15,
                    color: _selectedDate == null
                        ? Colors.white.withOpacity(0.25)
                        : Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Time slots
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _timeSlots.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final slot = _timeSlots[i];
              final isSelected = _selectedTimeSlot == slot;
              return GestureDetector(
                onTap: () => setState(() => _selectedTimeSlot = slot),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6366F1).withOpacity(0.25)
                        : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF818CF8).withOpacity(0.7)
                          : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      slot,
                      style: TextStyle(
                        fontFamily: 'Manrope', fontSize: 12,
                        color: isSelected
                            ? const Color(0xFF818CF8)
                            : Colors.white.withOpacity(0.45),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0A0A0C).withOpacity(0.0),
                const Color(0xFF0A0A0C).withOpacity(0.95),
                const Color(0xFF0A0A0C),
              ],
            ),
          ),
          child: Row(
            children: [
              // Save as Draft
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Request saved as draft.',
                            style: TextStyle(fontFamily: 'Manrope')),
                        backgroundColor: const Color(0xFF1A1A2E),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      ),
                    );
                  },
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Center(
                      child: Text(
                        'Save Draft',
                        style: TextStyle(
                          fontFamily: 'Manrope', fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Submit
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _isSubmitting ? null : _submit,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Submit Request',
                                  style: TextStyle(
                                    fontFamily: 'Manrope', fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E12).withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _glassButton({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Success Dialog
// ─────────────────────────────────────────────────────────────────────────────
class _SuccessDialog extends StatefulWidget {
  final String ticketId;
  const _SuccessDialog({required this.ticketId});

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: const Color(0xFF111118).withOpacity(0.95),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF22D3EE).withOpacity(0.15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF22D3EE).withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 4,
                          )
                        ],
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Color(0xFF22D3EE), size: 42),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'REQUEST SUBMITTED',
                    style: TextStyle(
                      fontFamily: 'Manrope', fontSize: 11,
                      letterSpacing: 2.5, color: Color(0xFF818CF8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your request has been\nsuccessfully submitted.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Raleway', fontSize: 22,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFFFBF8F4), height: 1.4,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ticket ID  ',
                          style: TextStyle(
                            fontFamily: 'Manrope', fontSize: 13,
                            color: Colors.white.withOpacity(0.4),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          widget.ticketId,
                          style: const TextStyle(
                            fontFamily: 'Manrope', fontSize: 15,
                            color: Color(0xFF22D3EE),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.4),
                            blurRadius: 20, offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'TRACK REQUEST',
                          style: TextStyle(
                            fontFamily: 'Manrope', fontSize: 13,
                            letterSpacing: 2.0, color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Back to Home',
                      style: TextStyle(
                        fontFamily: 'Manrope', fontSize: 13,
                        color: Colors.white.withOpacity(0.35),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
