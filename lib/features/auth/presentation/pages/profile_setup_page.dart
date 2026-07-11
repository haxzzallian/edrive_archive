// lib/features/auth/presentation/pages/profile_setup_page.dart

import 'package:e_drive/features/auth/presentation/providers/profile_setup_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/data/nigeria_data.dart';
import '../providers/profile_setup_state.dart';
import '../widgets/address_autocomplete_field.dart';

class ProfileSetupPage extends ConsumerWidget {
  final String role;
  final String email;
  const ProfileSetupPage({super.key, required this.role, required this.email});

  bool get _isDriver => role == 'driver';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileSetupProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(profileSetupProvider.select((s) => s.error), (_, error) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        ref.read(profileSetupProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24)),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                if (state.step > 1)
                  GestureDetector(
                      onTap: () =>
                          ref.read(profileSetupProvider.notifier).prevStep(),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20)),
                if (state.step > 1) const SizedBox(width: 8),
                const Expanded(
                    child: Text('Complete Your Profile',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800))),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20)),
                    // ── Step label fix: always shows current/total correctly
                    child: Text('Step ${state.step}/2',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600))),
              ]),
              const SizedBox(height: 12),
              Row(
                  children: List.generate(
                      2,
                      (i) => Expanded(
                          child: Container(
                              height: 4,
                              margin: EdgeInsets.only(right: i == 0 ? 6 : 0),
                              decoration: BoxDecoration(
                                  color: i < state.step
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2)))))),
            ]),
          ),

          // ── Step routing ──────────────────────────────────────────────────
          Expanded(
              child: _isDriver
                  ? (state.step == 1
                      ? _DriverStep1(isDark: isDark)
                      : _DriverStep2(email: email, isDark: isDark))
                  : (state.step == 1
                      ? _ClientStep1(isDark: isDark)
                      : _ClientStep2(email: email, isDark: isDark))),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CLIENT STEP 1 — student or passenger?
// ══════════════════════════════════════════════════════════════════════════════
class _ClientStep1 extends ConsumerStatefulWidget {
  final bool isDark;
  const _ClientStep1({required this.isDark});
  @override
  ConsumerState<_ClientStep1> createState() => _ClientStep1State();
}

class _ClientStep1State extends ConsumerState<_ClientStep1> {
  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(profileSetupProvider.notifier);
    final question = ref.watch(profileSetupProvider.select((s) => s.question));
    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 12),
          Align(
              alignment: Alignment.centerRight,
              child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                      color:
                          widget.isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12)
                      ]),
                  child: const Icon(Icons.directions_car_rounded,
                      size: 40, color: AppColors.textSecondary))),
          const SizedBox(height: 20),
          _Card(
              isDark: widget.isDark,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Are you a student or passenger?', widget.isDark),
                    const SizedBox(height: 14),
                    _Dropdown(
                        hint: 'Select Option',
                        value: question.isEmpty ? null : question,
                        isDark: widget.isDark,
                        items: const ['student', 'passenger'],
                        labels: const ['Student', 'Passenger'],
                        onChanged: (v) {
                          if (v != null) notifier.setQuestion(v);
                        }),
                    const SizedBox(height: 20),
                    _PrimaryBtn(
                        label: 'Next',
                        enabled: question.isNotEmpty,
                        onTap: () => notifier.nextStep()),
                  ])),
        ]));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CLIENT STEP 2 — photo + location + phone + gender
// ══════════════════════════════════════════════════════════════════════════════
class _ClientStep2 extends ConsumerStatefulWidget {
  final String email;
  final bool isDark;
  const _ClientStep2({required this.email, required this.isDark});
  @override
  ConsumerState<_ClientStep2> createState() => _ClientStep2State();
}

class _ClientStep2State extends ConsumerState<_ClientStep2> {
  final _phoneCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  double? _lat, _lng;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _addrCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null || !mounted) return;
    await ref
        .read(profileSetupProvider.notifier)
        .uploadProfilePicture(picked.path);
  }

  Future<void> _submit() async {
    final n = ref.read(profileSetupProvider.notifier);
    n.setPhone(_phoneCtrl.text.trim());
    n.setAddress(_addrCtrl.text.trim());
    n.setCoordinates(_lat ?? 0.0, _lng ?? 0.0);
    final ok = await n.submitClientProfile(widget.email);
    if (ok && mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(profileSetupProvider.notifier);
    final state = ref.watch(profileSetupProvider);
    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Profile picture
          _Card(
              isDark: widget.isDark,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Upload Profile Picture', widget.isDark),
                    const SizedBox(height: 10),
                    GestureDetector(
                        onTap: state.isUploadingProfile ? null : _pickImage,
                        child: _UploadBox(
                            url: state.profilePictureUrl,
                            isLoading: state.isUploadingProfile,
                            isDark: widget.isDark,
                            placeholder: 'Tap to upload profile picture',
                            icon: Icons.person_rounded)),
                  ])),
          const SizedBox(height: 16),

          // Location
          _Card(
              isDark: widget.isDark,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Address', widget.isDark, required: true),
                    const SizedBox(height: 8),
                    AddressAutocompleteField(
                      isDark: widget.isDark,
                      controller: _addrCtrl,
                      onStateResolved: (s) {
                        notifier.setState_(s);
                        setState(() {});
                      },
                      onLgaResolved: (l) {
                        notifier.setLga(l);
                        setState(() {});
                      },
                      onCoordinatesResolved: (lat, lng) => setState(() {
                        _lat = lat;
                        _lng = lng;
                      }),
                    ),
                    const SizedBox(height: 14),
                    _Label('State', widget.isDark, required: true),
                    const SizedBox(height: 8),
                    _Dropdown(
                        hint: 'Select State',
                        value: state.state.isEmpty ? null : state.state,
                        isDark: widget.isDark,
                        items: NigeriaData.states,
                        labels: NigeriaData.states,
                        onChanged: (v) {
                          if (v != null) notifier.setState_(v);
                        }),
                    const SizedBox(height: 14),
                    _Label('LGA', widget.isDark, required: true),
                    const SizedBox(height: 8),
                    _Dropdown(
                        hint: 'Select LGA',
                        value: state.lga.isEmpty ? null : state.lga,
                        isDark: widget.isDark,
                        items: state.state.isNotEmpty
                            ? NigeriaData.getLgas(state.state)
                            : const [],
                        labels: state.state.isNotEmpty
                            ? NigeriaData.getLgas(state.state)
                            : const [],
                        onChanged: (v) {
                          if (v != null) notifier.setLga(v);
                        }),
                  ])),
          const SizedBox(height: 16),

          // Phone + Gender
          _Card(
              isDark: widget.isDark,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Phone Number', widget.isDark, required: true),
                    const SizedBox(height: 8),
                    _TF(
                        ctrl: _phoneCtrl,
                        hint: 'Enter phone number',
                        icon: Icons.phone_outlined,
                        isDark: widget.isDark,
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),
                    _Label('Gender', widget.isDark, required: true),
                    const SizedBox(height: 10),
                    _RadioRow(
                        options: const ['male', 'female'],
                        labels: const ['Male', 'Female'],
                        value: state.gender.isEmpty ? null : state.gender,
                        onChanged: (v) => notifier.setGender(v)),
                  ])),
          const SizedBox(height: 24),

          Row(children: [
            Expanded(
                child: _OutlineBtn(
                    label: 'Back',
                    isDark: widget.isDark,
                    onTap: () =>
                        ref.read(profileSetupProvider.notifier).prevStep())),
            const SizedBox(width: 12),
            Expanded(
                child: _PrimaryBtn(
                    label: 'Submit',
                    isLoading: state.isSubmitting,
                    enabled: !state.isSubmitting,
                    onTap: _submit)),
          ]),
          const SizedBox(height: 24),
        ]));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DRIVER STEP 1
// Uploads + Driver roles + Interstate + Gear type + Marital status
//   + Vehicle type + Current location (plain text)
// ══════════════════════════════════════════════════════════════════════════════
// Replace _DriverStep1 in profile_setup_page.dart with this version
// which shows the "Hired Driver Details" section when 'hired' is ticked

class _DriverStep1 extends ConsumerStatefulWidget {
  final bool isDark;
  const _DriverStep1({required this.isDark});
  @override
  ConsumerState<_DriverStep1> createState() => _DriverStep1State();
}

class _DriverStep1State extends ConsumerState<_DriverStep1> {
  final _currentLocCtrl = TextEditingController();
  final _minSalaryCtrl = TextEditingController();

  @override
  void dispose() {
    _currentLocCtrl.dispose();
    _minSalaryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(String type) async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null || !mounted) return;
    final n = ref.read(profileSetupProvider.notifier);
    switch (type) {
      case 'profile':
        await n.uploadProfilePicture(picked.path);
        break;
      case 'car':
        await n.uploadCarPicture(picked.path);
        break;
      case 'license':
        await n.uploadDriverLicense(picked.path);
        break;
    }
  }

  void _next() {
    final n = ref.read(profileSetupProvider.notifier);
    n.setCurrentLocation(_currentLocCtrl.text.trim());
    n.setHiredMinSalary(_minSalaryCtrl.text.trim());
    n.nextStep();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileSetupProvider);
    final notifier = ref.read(profileSetupProvider.notifier);
    final hasHired = state.driverRoles.contains('hired');

    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // ── Uploads ────────────────────────────────────────────────────────
          _Card(
              isDark: widget.isDark,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Upload Profile Picture', widget.isDark),
                    const SizedBox(height: 8),
                    GestureDetector(
                        onTap: state.isUploadingProfile
                            ? null
                            : () => _pick('profile'),
                        child: _UploadBox(
                            url: state.profilePictureUrl,
                            isLoading: state.isUploadingProfile,
                            isDark: widget.isDark,
                            placeholder: 'Tap to upload profile picture',
                            icon: Icons.person_rounded)),
                    const SizedBox(height: 14),
                    _Label('Upload Car Picture', widget.isDark),
                    const SizedBox(height: 8),
                    GestureDetector(
                        onTap: state.isUploadingCar ? null : () => _pick('car'),
                        child: _UploadBox(
                            url: state.carPictureUrl,
                            isLoading: state.isUploadingCar,
                            isDark: widget.isDark,
                            placeholder: 'Tap to upload car picture',
                            icon: Icons.directions_car_rounded)),
                    const SizedBox(height: 14),
                    _Label("Upload Driver's License", widget.isDark),
                    const SizedBox(height: 8),
                    GestureDetector(
                        onTap: state.isUploadingLicense
                            ? null
                            : () => _pick('license'),
                        child: _UploadBox(
                            url: state.driverLicenseUrl,
                            isLoading: state.isUploadingLicense,
                            isDark: widget.isDark,
                            placeholder: "Tap to upload driver's license",
                            icon: Icons.badge_rounded)),
                  ])),
          const SizedBox(height: 16),

          // ── Driver roles ────────────────────────────────────────────────────
          _Card(
              isDark: widget.isDark,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label(
                        'Driver Roles (Select all that apply)', widget.isDark),
                    const SizedBox(height: 12),
                    Wrap(
                        spacing: 16,
                        runSpacing: 10,
                        children: [
                          ['ride-hauling', 'Ride Hauling'],
                          ['airport', 'Airport'],
                          ['chartered', 'Chartered'],
                          ['hired', 'Hired'],
                        ]
                            .map((r) => _CheckItem(
                                  label: r[1],
                                  value: state.driverRoles.contains(r[0]),
                                  isDark: widget.isDark,
                                  onChanged: (_) =>
                                      notifier.toggleDriverRole(r[0]),
                                ))
                            .toList()),
                    const SizedBox(height: 14),
                    _Label('Willing to Travel Interstate?', widget.isDark),
                    const SizedBox(height: 8),
                    _CheckItem(
                        label: 'Yes',
                        value: state.interstate,
                        isDark: widget.isDark,
                        onChanged: (v) => notifier.setInterstate(v)),
                  ])),
          const SizedBox(height: 16),

          // ── Hired driver details (conditionally shown) ──────────────────────
          if (hasHired) ...[
            _Card(
                isDark: widget.isDark,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header with divider style
                      Row(children: [
                        Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 10),
                        Text('Hired Driver Details',
                            style: TextStyle(
                                color: widget.isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w800)),
                      ]),
                      const SizedBox(height: 16),

                      _Label('Duration Type', widget.isDark, required: true),
                      const SizedBox(height: 8),
                      _Dropdown(
                          hint: 'Select Duration Type',
                          value: state.hiredDurationType.isEmpty
                              ? null
                              : state.hiredDurationType,
                          isDark: widget.isDark,
                          items: const [
                            'day',
                            'days',
                            'week',
                            'weeks',
                            'month',
                            'months',
                            'temporary',
                            'permanent',
                          ],
                          labels: const [
                            'Day',
                            'Days',
                            'Week',
                            'Weeks',
                            'Month',
                            'Months',
                            'Temporary',
                            'Permanent',
                          ],
                          onChanged: (v) {
                            if (v != null) notifier.setHiredDurationType(v);
                          }),
                      const SizedBox(height: 14),

                      _Label('Minimum Salary (₦)', widget.isDark,
                          required: true),
                      const SizedBox(height: 8),
                      _TF(
                          ctrl: _minSalaryCtrl,
                          hint: 'Enter minimum salary',
                          icon: Icons.payments_outlined,
                          isDark: widget.isDark,
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 14),

                      _Label(
                          'Interstate Travel for Hired Role?', widget.isDark),
                      const SizedBox(height: 8),
                      _CheckItem(
                          label: 'Yes',
                          value: state.hiredInterstate,
                          isDark: widget.isDark,
                          onChanged: (v) => notifier.setHiredInterstate(v)),
                      const SizedBox(height: 14),

                      _Label('Type of Car', widget.isDark, required: true),
                      const SizedBox(height: 8),
                      _Dropdown(
                          hint: 'Select Car Type',
                          value: state.hiredTypeOfCar.isEmpty
                              ? null
                              : state.hiredTypeOfCar,
                          isDark: widget.isDark,
                          items: const [
                            'car',
                            'jeep',
                            'mini-bus',
                            'bus',
                            'trailer'
                          ],
                          labels: const [
                            'Car',
                            'Jeep',
                            'Mini-Bus',
                            'Bus',
                            'Trailer'
                          ],
                          onChanged: (v) {
                            if (v != null) notifier.setHiredTypeOfCar(v);
                          }),
                      const SizedBox(height: 14),

                      _Label('Type of Transmission', widget.isDark,
                          required: true),
                      const SizedBox(height: 8),
                      _Dropdown(
                          hint: 'Select Transmission Type',
                          value: state.hiredTransmission.isEmpty
                              ? null
                              : state.hiredTransmission,
                          isDark: widget.isDark,
                          items: const ['automatic', 'manual', 'both'],
                          labels: const ['Automatic', 'Manual', 'Both'],
                          onChanged: (v) {
                            if (v != null) notifier.setHiredTransmission(v);
                          }),
                      const SizedBox(height: 14),

                      _Label('Choice/Preference', widget.isDark,
                          required: true),
                      const SizedBox(height: 8),
                      _Dropdown(
                          hint: 'Select Preference',
                          value: state.hiredPreference.isEmpty
                              ? null
                              : state.hiredPreference,
                          isDark: widget.isDark,
                          items: const [
                            'private-with-accommodation',
                            'private-no-accommodation',
                            'commercial-with-accommodation',
                            'commercial-no-accommodation',
                          ],
                          labels: const [
                            'Private with Accommodation',
                            'Private with No Accommodation',
                            'Commercial with Accommodation',
                            'Commercial with No Accommodation',
                          ],
                          onChanged: (v) {
                            if (v != null) notifier.setHiredPreference(v);
                          }),
                    ])),
            const SizedBox(height: 16),
          ],

          // ── Gear + Marital + Vehicle ────────────────────────────────────────
          _Card(
              isDark: widget.isDark,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Gear Type', widget.isDark),
                    const SizedBox(height: 8),
                    _RadioWrap(
                        options: const ['manual', 'automatic', 'both'],
                        labels: const ['Manual', 'Automatic', 'Both'],
                        value: state.gearType.isEmpty ? null : state.gearType,
                        onChanged: (v) => notifier.setGearType(v)),
                    const SizedBox(height: 14),
                    _Label('Marital Status', widget.isDark),
                    const SizedBox(height: 8),
                    _RadioWrap(
                        options: const [
                          'single',
                          'married',
                          'divorced',
                          'widowed'
                        ],
                        labels: const [
                          'Single',
                          'Married',
                          'Divorced',
                          'Widowed'
                        ],
                        value: state.maritalStatus.isEmpty
                            ? null
                            : state.maritalStatus,
                        onChanged: (v) => notifier.setMaritalStatus(v)),
                    const SizedBox(height: 14),
                    _Label('Vehicle Type', widget.isDark),
                    const SizedBox(height: 8),
                    _RadioWrap(
                        options: const [
                          'car',
                          'jeep',
                          'mini-bus',
                          'bus',
                          'trailer'
                        ],
                        labels: const [
                          'Car',
                          'Jeep',
                          'Mini-Bus',
                          'Bus',
                          'Trailer'
                        ],
                        value: state.vehicleType.isEmpty
                            ? null
                            : state.vehicleType,
                        onChanged: (v) => notifier.setVehicleType(v)),
                  ])),
          const SizedBox(height: 16),

          // ── Current location ────────────────────────────────────────────────
          _Card(
              isDark: widget.isDark,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Current Location', widget.isDark),
                    const SizedBox(height: 8),
                    _TF(
                        ctrl: _currentLocCtrl,
                        hint: 'e.g. Alimosho',
                        icon: Icons.my_location_rounded,
                        isDark: widget.isDark),
                  ])),
          const SizedBox(height: 24),

          _PrimaryBtn(
              label: 'Next', onTap: _next, enabled: !state.isUploadingAny),
          const SizedBox(height: 24),
        ]));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DRIVER STEP 2
// Car details + Address autocomplete (→ state/LGA) + Phone + YOE
//   + Language + Gender → Submit
// ══════════════════════════════════════════════════════════════════════════════
class _DriverStep2 extends ConsumerStatefulWidget {
  final String email;
  final bool isDark;
  const _DriverStep2({required this.email, required this.isDark});
  @override
  ConsumerState<_DriverStep2> createState() => _DriverStep2State();
}

class _DriverStep2State extends ConsumerState<_DriverStep2> {
  final _modelCtrl = TextEditingController();
  final _productCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _yoeCtrl = TextEditingController();
  final _langCtrl = TextEditingController();
  double? _lat, _lng;

  @override
  void dispose() {
    for (final c in [
      _modelCtrl,
      _productCtrl,
      _yearCtrl,
      _colorCtrl,
      _plateCtrl,
      _addrCtrl,
      _phoneCtrl,
      _yoeCtrl,
      _langCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final n = ref.read(profileSetupProvider.notifier);
    n.setCarModel(_modelCtrl.text.trim());
    n.setCarProduct(_productCtrl.text.trim());
    n.setCarYear(_yearCtrl.text.trim());
    n.setCarColor(_colorCtrl.text.trim());
    n.setPlateNumber(_plateCtrl.text.trim());
    n.setAddress(_addrCtrl.text.trim());
    n.setPhone(_phoneCtrl.text.trim());
    n.setYoe(_yoeCtrl.text.trim());
    n.setLanguage(_langCtrl.text.trim());
    n.setCoordinates(_lat ?? 0.0, _lng ?? 0.0);
    final ok = await n.submitDriverProfile(widget.email);
    if (ok && mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(profileSetupProvider.notifier);
    final state = ref.watch(profileSetupProvider);

    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // ── Car details ───────────────────────────────────────────────────────
          _Card(
              isDark: widget.isDark,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Car Details', widget.isDark),
                    const SizedBox(height: 12),
                    _TF(
                        ctrl: _modelCtrl,
                        hint: 'Car Model (e.g. Camry)',
                        icon: Icons.directions_car_outlined,
                        isDark: widget.isDark),
                    const SizedBox(height: 10),
                    _TF(
                        ctrl: _productCtrl,
                        hint: 'Car Product (e.g. Toyota)',
                        icon: Icons.branding_watermark_outlined,
                        isDark: widget.isDark),
                    const SizedBox(height: 10),
                    _TF(
                        ctrl: _yearCtrl,
                        hint: 'Year (e.g. 2020)',
                        icon: Icons.calendar_today_outlined,
                        isDark: widget.isDark,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 10),
                    _TF(
                        ctrl: _colorCtrl,
                        hint: 'Color (e.g. Black)',
                        icon: Icons.color_lens_outlined,
                        isDark: widget.isDark),
                    const SizedBox(height: 10),
                    _TF(
                        ctrl: _plateCtrl,
                        hint: 'Plate Number',
                        icon: Icons.confirmation_number_outlined,
                        isDark: widget.isDark),
                  ])),
          const SizedBox(height: 16),

          // ── Location (autocomplete → state + LGA) ─────────────────────────────
          _Card(
              isDark: widget.isDark,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Location', widget.isDark),
                    const SizedBox(height: 12),
                    _Label('Address', widget.isDark, required: true),
                    const SizedBox(height: 8),
                    AddressAutocompleteField(
                      isDark: widget.isDark,
                      controller: _addrCtrl,
                      onStateResolved: (s) {
                        notifier.setState_(s);
                        setState(() {});
                      },
                      onLgaResolved: (l) {
                        notifier.setLga(l);
                        setState(() {});
                      },
                      onCoordinatesResolved: (lat, lng) => setState(() {
                        _lat = lat;
                        _lng = lng;
                      }),
                    ),
                    const SizedBox(height: 12),
                    _Label('State', widget.isDark, required: true),
                    const SizedBox(height: 6),
                    _Dropdown(
                        hint: 'Select State',
                        value: state.state.isEmpty ? null : state.state,
                        isDark: widget.isDark,
                        items: NigeriaData.states,
                        labels: NigeriaData.states,
                        onChanged: (v) {
                          if (v != null) notifier.setState_(v);
                        }),
                    const SizedBox(height: 12),
                    _Label('LGA', widget.isDark, required: true),
                    const SizedBox(height: 6),
                    _Dropdown(
                        hint: 'Select LGA',
                        value: state.lga.isEmpty ? null : state.lga,
                        isDark: widget.isDark,
                        items: state.state.isNotEmpty
                            ? NigeriaData.getLgas(state.state)
                            : const [],
                        labels: state.state.isNotEmpty
                            ? NigeriaData.getLgas(state.state)
                            : const [],
                        onChanged: (v) {
                          if (v != null) notifier.setLga(v);
                        }),
                  ])),
          const SizedBox(height: 16),

          // ── Personal details ──────────────────────────────────────────────────
          _Card(
              isDark: widget.isDark,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Personal Details', widget.isDark),
                    const SizedBox(height: 12),
                    _TF(
                        ctrl: _phoneCtrl,
                        hint: 'Phone Number',
                        icon: Icons.phone_outlined,
                        isDark: widget.isDark,
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 10),
                    _TF(
                        ctrl: _yoeCtrl,
                        hint: 'Years of Experience',
                        icon: Icons.work_outline_rounded,
                        isDark: widget.isDark,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 10),
                    _TF(
                        ctrl: _langCtrl,
                        hint: 'Languages Spoken (e.g. English)',
                        icon: Icons.language_rounded,
                        isDark: widget.isDark),
                    const SizedBox(height: 14),
                    _Label('Gender', widget.isDark, required: true),
                    const SizedBox(height: 8),
                    _RadioRow(
                        options: const ['male', 'female'],
                        labels: const ['Male', 'Female'],
                        value: state.gender.isEmpty ? null : state.gender,
                        onChanged: (v) => notifier.setGender(v)),
                  ])),
          const SizedBox(height: 24),

          Row(children: [
            Expanded(
                child: _OutlineBtn(
                    label: 'Back',
                    isDark: widget.isDark,
                    onTap: () =>
                        ref.read(profileSetupProvider.notifier).prevStep())),
            const SizedBox(width: 12),
            Expanded(
                child: _PrimaryBtn(
                    label: 'Submit',
                    isLoading: state.isSubmitting,
                    enabled: !state.isSubmitting,
                    onTap: _submit)),
          ]),
          const SizedBox(height: 32),
        ]));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _Card({required this.child, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ]),
      child: child);
}

Widget _Label(String t, bool isDark, {bool required = false}) => RichText(
    text: TextSpan(
        text: t,
        style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600),
        children: required
            ? [
                const TextSpan(
                    text: ' *', style: TextStyle(color: AppColors.error))
              ]
            : []));

Widget _SectionTitle(String t, bool isDark) => Text(t,
    style: TextStyle(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w700));

class _TF extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final bool isDark;
  final IconData icon;
  final TextInputType? keyboardType;
  const _TF(
      {required this.ctrl,
      required this.hint,
      required this.isDark,
      required this.icon,
      this.keyboardType});
  @override
  Widget build(BuildContext context) => TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          fontSize: 14),
      decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.textHint, size: 18),
          filled: true,
          fillColor:
              isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.secondary, width: 2))));
}

class _Dropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final bool isDark;
  final List<String> items, labels;
  final void Function(String?) onChanged;
  const _Dropdown(
      {required this.hint,
      required this.value,
      required this.isDark,
      required this.items,
      required this.labels,
      required this.onChanged});
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      dropdownColor: isDark ? AppColors.darkSurface : AppColors.surface,
      hint: Text(hint,
          style: const TextStyle(color: AppColors.textHint, fontSize: 14)),
      style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          fontSize: 14),
      items: List.generate(items.length,
          (i) => DropdownMenuItem(value: items[i], child: Text(labels[i]))),
      decoration: InputDecoration(
          filled: true,
          fillColor:
              isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.secondary, width: 2))));
}

class _RadioRow extends StatelessWidget {
  final List<String> options, labels;
  final String? value;
  final void Function(String) onChanged;
  const _RadioRow(
      {required this.options,
      required this.labels,
      required this.value,
      required this.onChanged});
  @override
  Widget build(BuildContext context) => Wrap(
      spacing: 24,
      children: List.generate(
          options.length,
          (i) => GestureDetector(
              onTap: () => onChanged(options[i]),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _Radio(selected: value == options[i]),
                const SizedBox(width: 6),
                Text(options[i] == value ? labels[i] : labels[i],
                    style: TextStyle(
                        fontSize: 14,
                        color: value == options[i]
                            ? AppColors.secondary
                            : AppColors.textSecondary)),
              ]))));
}

class _RadioWrap extends StatelessWidget {
  final List<String> options, labels;
  final String? value;
  final void Function(String) onChanged;
  const _RadioWrap(
      {required this.options,
      required this.labels,
      required this.value,
      required this.onChanged});
  @override
  Widget build(BuildContext context) => Wrap(
      spacing: 16,
      runSpacing: 8,
      children: List.generate(
          options.length,
          (i) => GestureDetector(
              onTap: () => onChanged(options[i]),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _Radio(selected: value == options[i]),
                const SizedBox(width: 6),
                Text(labels[i],
                    style: TextStyle(
                        fontSize: 13,
                        color: value == options[i]
                            ? AppColors.secondary
                            : AppColors.textSecondary)),
              ]))));
}

class _Radio extends StatelessWidget {
  final bool selected;
  const _Radio({required this.selected});
  @override
  Widget build(BuildContext context) => Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: selected ? AppColors.secondary : AppColors.textHint,
              width: 2)),
      child: selected
          ? Center(
              child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.secondary)))
          : null);
}

class _CheckItem extends StatelessWidget {
  final String label;
  final bool value, isDark;
  final void Function(bool) onChanged;
  const _CheckItem(
      {required this.label,
      required this.value,
      required this.isDark,
      required this.onChanged});
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                color: value ? AppColors.secondary : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: value ? AppColors.secondary : AppColors.textHint,
                    width: 1.5)),
            child: value
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : null),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary)),
      ]));
}

class _UploadBox extends StatelessWidget {
  final String? url;
  final bool isDark, isLoading;
  final String placeholder;
  final IconData icon;
  const _UploadBox(
      {this.url,
      required this.isDark,
      this.isLoading = false,
      required this.placeholder,
      required this.icon});
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      height: 110,
      decoration: BoxDecoration(
          color:
              isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF0F0F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.textHint.withOpacity(0.35), width: 1.5)),
      clipBehavior: Clip.hardEdge,
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.secondary, strokeWidth: 2))
          : url != null
              ? Stack(fit: StackFit.expand, children: [
                  Image.network(url!, fit: BoxFit.cover),
                  Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 14))),
                ])
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(icon, color: AppColors.textHint, size: 26),
                  const SizedBox(height: 8),
                  Text(placeholder,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 13)),
                ]));
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool isLoading;
  const _PrimaryBtn(
      {required this.label,
      required this.onTap,
      this.enabled = true,
      this.isLoading = false});
  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
          onPressed: enabled && !isLoading ? onTap : null,
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              disabledBackgroundColor: AppColors.secondary.withOpacity(0.4),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14))),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700))));
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  const _OutlineBtn(
      {required this.label, required this.onTap, required this.isDark});
  @override
  Widget build(BuildContext context) => SizedBox(
      height: 52,
      child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.textHint, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14))),
          child: Text(label,
              style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700))));
}

// // lib/features/auth/presentation/pages/profile_setup_page.dart
// // Updated: address fields now use AddressAutocompleteField
// // which auto-fills state, LGA and captures real coordinates.
// // Hardcoded lat/lng removed — real coordinates from Places API.

// import 'package:e_drive/features/auth/presentation/providers/profile_setup_notifier.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../../../core/router/app_routes.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/data/nigeria_data.dart';

// import '../providers/profile_setup_state.dart';
// import '../widgets/address_autocomplete_field.dart';

// class ProfileSetupPage extends ConsumerWidget {
//   final String role;
//   final String email;
//   const ProfileSetupPage({super.key, required this.role, required this.email});

//   bool get _isDriver => role == 'driver';

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(profileSetupProvider);
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     ref.listen(profileSetupProvider.select((s) => s.error), (_, error) {
//       if (error != null) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text(error),
//           backgroundColor: AppColors.error,
//           behavior: SnackBarBehavior.floating,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         ));
//         ref.read(profileSetupProvider.notifier).clearError();
//       }
//     });

//     return Scaffold(
//       backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
//       body: SafeArea(
//           child: Column(children: [
//         // ── Header ──────────────────────────────────────────────────────────
//         Container(
//           padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
//           decoration: const BoxDecoration(
//             color: AppColors.secondary,
//             borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(24),
//                 bottomRight: Radius.circular(24)),
//           ),
//           child:
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Row(children: [
//               if (state.step > 1)
//                 GestureDetector(
//                     onTap: () =>
//                         ref.read(profileSetupProvider.notifier).prevStep(),
//                     child: const Icon(Icons.arrow_back_ios_new_rounded,
//                         color: Colors.white, size: 20)),
//               if (state.step > 1) const SizedBox(width: 8),
//               const Expanded(
//                   child: Text('Complete Your Profile',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 17,
//                           fontWeight: FontWeight.w800))),
//               Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(20)),
//                   child: Text('Step ${state.step}/2',
//                       style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600))),
//             ]),
//             const SizedBox(height: 12),
//             Row(
//                 children: List.generate(
//                     2,
//                     (i) => Expanded(
//                         child: Container(
//                             height: 4,
//                             margin: EdgeInsets.only(right: i == 0 ? 6 : 0),
//                             decoration: BoxDecoration(
//                                 color: i < state.step
//                                     ? Colors.white
//                                     : Colors.white.withOpacity(0.3),
//                                 borderRadius: BorderRadius.circular(2)))))),
//           ]),
//         ),

//         Expanded(
//             child: _isDriver
//                 ? (state.step == 1
//                     ? _DriverStep1(email: email, isDark: isDark)
//                     : _DriverStep2(email: email, isDark: isDark))
//                 : (state.step == 1
//                     ? _ClientStep1(isDark: isDark)
//                     : _ClientStep2(email: email, isDark: isDark))),
//       ])),
//     );
//   }
// }

// // ══════════════════════════════════════════════════════════════════════════════
// // CLIENT — STEP 1
// // ══════════════════════════════════════════════════════════════════════════════
// class _ClientStep1 extends ConsumerStatefulWidget {
//   final bool isDark;
//   const _ClientStep1({required this.isDark});
//   @override
//   ConsumerState<_ClientStep1> createState() => _ClientStep1State();
// }

// class _ClientStep1State extends ConsumerState<_ClientStep1> {
//   @override
//   Widget build(BuildContext context) {
//     final notifier = ref.read(profileSetupProvider.notifier);
//     final question = ref.watch(profileSetupProvider.select((s) => s.question));

//     return SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(children: [
//           const SizedBox(height: 12),
//           Align(
//               alignment: Alignment.centerRight,
//               child: Container(
//                   width: 72,
//                   height: 72,
//                   decoration: BoxDecoration(
//                       color:
//                           widget.isDark ? AppColors.darkSurface : Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                             color: Colors.black.withOpacity(0.08),
//                             blurRadius: 12)
//                       ]),
//                   child: const Icon(Icons.directions_car_rounded,
//                       size: 40, color: AppColors.textSecondary))),
//           const SizedBox(height: 20),
//           _Card(
//               isDark: widget.isDark,
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _Label('Are you a student or passenger?', widget.isDark),
//                     const SizedBox(height: 14),
//                     _Dropdown(
//                         hint: 'Select Option',
//                         value: question.isEmpty ? null : question,
//                         isDark: widget.isDark,
//                         items: const ['student', 'passenger'],
//                         labels: const ['Student', 'Passenger'],
//                         onChanged: (v) {
//                           if (v != null) notifier.setQuestion(v);
//                         }),
//                     const SizedBox(height: 20),
//                     _PrimaryBtn(
//                         label: 'Next',
//                         enabled: question.isNotEmpty,
//                         onTap: () => notifier.nextStep()),
//                   ])),
//         ]));
//   }
// }

// // ══════════════════════════════════════════════════════════════════════════════
// // CLIENT — STEP 2  (with Google Places autocomplete)
// // ══════════════════════════════════════════════════════════════════════════════
// class _ClientStep2 extends ConsumerStatefulWidget {
//   final String email;
//   final bool isDark;
//   const _ClientStep2({required this.email, required this.isDark});
//   @override
//   ConsumerState<_ClientStep2> createState() => _ClientStep2State();
// }

// class _ClientStep2State extends ConsumerState<_ClientStep2> {
//   final _phoneCtrl = TextEditingController();
//   final _addrCtrl = TextEditingController();

//   // Real coordinates captured from Places API — no hardcoding
//   double? _lat, _lng;

//   @override
//   void dispose() {
//     _phoneCtrl.dispose();
//     _addrCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage() async {
//     final picked = await ImagePicker()
//         .pickImage(source: ImageSource.gallery, imageQuality: 80);
//     if (picked == null || !mounted) return;
//     await ref
//         .read(profileSetupProvider.notifier)
//         .uploadProfilePicture(picked.path);
//   }

//   Future<void> _submit() async {
//     final notifier = ref.read(profileSetupProvider.notifier);
//     notifier.setPhone(_phoneCtrl.text.trim());
//     notifier.setAddress(_addrCtrl.text.trim());
//     // Set real coordinates — falls back to 0,0 if user didn't use autocomplete
//     notifier.setCoordinates(_lat ?? 0.0, _lng ?? 0.0);
//     final ok = await notifier.submitClientProfile(widget.email);
//     if (ok && mounted) context.go(AppRoutes.home);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final notifier = ref.read(profileSetupProvider.notifier);
//     final state = ref.watch(profileSetupProvider);

//     return SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(children: [
//           // Profile picture
//           _Card(
//               isDark: widget.isDark,
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _Label('Upload Profile Picture', widget.isDark),
//                     const SizedBox(height: 10),
//                     GestureDetector(
//                         onTap: state.isUploadingProfile ? null : _pickImage,
//                         child: _UploadBox(
//                             url: state.profilePictureUrl,
//                             isLoading: state.isUploadingProfile,
//                             isDark: widget.isDark,
//                             placeholder: 'Tap to upload profile picture',
//                             icon: Icons.person_rounded)),
//                   ])),
//           const SizedBox(height: 16),

//           // Location — address autocomplete auto-fills state + LGA
//           _Card(
//               isDark: widget.isDark,
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _Label('Address', widget.isDark, required: true),
//                     const SizedBox(height: 8),
//                     AddressAutocompleteField(
//                       isDark: widget.isDark,
//                       controller: _addrCtrl,
//                       onStateResolved: (s) {
//                         notifier.setState_(s);
//                         setState(() {}); // rebuild dropdowns
//                       },
//                       onLgaResolved: (l) {
//                         notifier.setLga(l);
//                         setState(() {});
//                       },
//                       onCoordinatesResolved: (lat, lng) {
//                         setState(() {
//                           _lat = lat;
//                           _lng = lng;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 14),
//                     _Label('State', widget.isDark, required: true),
//                     const SizedBox(height: 8),
//                     _Dropdown(
//                         hint: 'Select State',
//                         value: state.state.isEmpty ? null : state.state,
//                         isDark: widget.isDark,
//                         items: NigeriaData.states,
//                         labels: NigeriaData.states,
//                         onChanged: (v) {
//                           if (v != null) notifier.setState_(v);
//                         }),
//                     const SizedBox(height: 14),
//                     _Label('LGA', widget.isDark, required: true),
//                     const SizedBox(height: 8),
//                     _Dropdown(
//                         hint: 'Select LGA',
//                         value: state.lga.isEmpty ? null : state.lga,
//                         isDark: widget.isDark,
//                         items: state.state.isNotEmpty
//                             ? NigeriaData.getLgas(state.state)
//                             : const [],
//                         labels: state.state.isNotEmpty
//                             ? NigeriaData.getLgas(state.state)
//                             : const [],
//                         onChanged: (v) {
//                           if (v != null) notifier.setLga(v);
//                         }),
//                   ])),
//           const SizedBox(height: 16),

//           // Phone + Gender
//           _Card(
//               isDark: widget.isDark,
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _Label('Phone Number', widget.isDark, required: true),
//                     const SizedBox(height: 8),
//                     _TextField(
//                         ctrl: _phoneCtrl,
//                         hint: 'Enter phone number',
//                         icon: Icons.phone_outlined,
//                         isDark: widget.isDark,
//                         keyboardType: TextInputType.phone),
//                     const SizedBox(height: 16),
//                     _Label('Gender', widget.isDark, required: true),
//                     const SizedBox(height: 10),
//                     _RadioRow(
//                         options: const ['male', 'female'],
//                         labels: const ['Male', 'Female'],
//                         value: state.gender.isEmpty ? null : state.gender,
//                         onChanged: (v) => notifier.setGender(v)),
//                   ])),
//           const SizedBox(height: 24),

//           Row(children: [
//             Expanded(
//                 child: _OutlineBtn(
//                     label: 'Back',
//                     isDark: widget.isDark,
//                     onTap: () =>
//                         ref.read(profileSetupProvider.notifier).prevStep())),
//             const SizedBox(width: 12),
//             Expanded(
//                 child: _PrimaryBtn(
//                     label: 'Submit',
//                     isLoading: state.isSubmitting,
//                     enabled: !state.isSubmitting,
//                     onTap: _submit)),
//           ]),
//           const SizedBox(height: 24),
//         ]));
//   }
// }

// // ══════════════════════════════════════════════════════════════════════════════
// // DRIVER — STEP 1
// // ══════════════════════════════════════════════════════════════════════════════
// class _DriverStep1 extends ConsumerWidget {
//   final String email;
//   final bool isDark;
//   const _DriverStep1({required this.email, required this.isDark});

//   Future<void> _pick(WidgetRef ref, String type) async {
//     final picked = await ImagePicker()
//         .pickImage(source: ImageSource.gallery, imageQuality: 80);
//     if (picked == null) return;
//     final n = ref.read(profileSetupProvider.notifier);
//     switch (type) {
//       case 'profile':
//         await n.uploadProfilePicture(picked.path);
//         break;
//       case 'car':
//         await n.uploadCarPicture(picked.path);
//         break;
//       case 'license':
//         await n.uploadDriverLicense(picked.path);
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(profileSetupProvider);
//     final notifier = ref.read(profileSetupProvider.notifier);

//     return SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(children: [
//           _Card(
//               isDark: isDark,
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _Label('Upload Profile Picture', isDark),
//                     const SizedBox(height: 8),
//                     GestureDetector(
//                         onTap: state.isUploadingProfile
//                             ? null
//                             : () => _pick(ref, 'profile'),
//                         child: _UploadBox(
//                             url: state.profilePictureUrl,
//                             isLoading: state.isUploadingProfile,
//                             isDark: isDark,
//                             placeholder: 'Tap to upload profile picture',
//                             icon: Icons.person_rounded)),
//                     const SizedBox(height: 14),
//                     _Label('Upload Car Picture', isDark),
//                     const SizedBox(height: 8),
//                     GestureDetector(
//                         onTap: state.isUploadingCar
//                             ? null
//                             : () => _pick(ref, 'car'),
//                         child: _UploadBox(
//                             url: state.carPictureUrl,
//                             isLoading: state.isUploadingCar,
//                             isDark: isDark,
//                             placeholder: 'Tap to upload car picture',
//                             icon: Icons.directions_car_rounded)),
//                     const SizedBox(height: 14),
//                     _Label("Upload Driver's License", isDark),
//                     const SizedBox(height: 8),
//                     GestureDetector(
//                         onTap: state.isUploadingLicense
//                             ? null
//                             : () => _pick(ref, 'license'),
//                         child: _UploadBox(
//                             url: state.driverLicenseUrl,
//                             isLoading: state.isUploadingLicense,
//                             isDark: isDark,
//                             placeholder: "Tap to upload driver's license",
//                             icon: Icons.badge_rounded)),
//                   ])),
//           const SizedBox(height: 16),
//           _Card(
//               isDark: isDark,
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _Label('Driver Roles (Select all that apply)', isDark),
//                     const SizedBox(height: 12),
//                     Wrap(
//                         spacing: 16,
//                         runSpacing: 10,
//                         children: [
//                           ['ride-hauling', 'Ride Hauling'],
//                           ['airport', 'Airport'],
//                           ['chartered', 'Chartered'],
//                           ['hired', 'Hired'],
//                         ]
//                             .map((r) => _CheckItem(
//                                 label: r[1],
//                                 value: state.driverRoles.contains(r[0]),
//                                 isDark: isDark,
//                                 onChanged: (_) =>
//                                     notifier.toggleDriverRole(r[0])))
//                             .toList()),
//                     const SizedBox(height: 14),
//                     _Label('Willing to Travel Interstate?', isDark),
//                     const SizedBox(height: 8),
//                     _CheckItem(
//                         label: 'Yes',
//                         value: state.interstate,
//                         isDark: isDark,
//                         onChanged: (v) => notifier.setInterstate(v)),
//                   ])),
//           const SizedBox(height: 16),
//           _Card(
//               isDark: isDark,
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _Label('Gear Type', isDark),
//                     const SizedBox(height: 8),
//                     _RadioWrap(
//                         options: const ['manual', 'automatic', 'both'],
//                         labels: const ['Manual', 'Automatic', 'Both'],
//                         value: state.gearType.isEmpty ? null : state.gearType,
//                         onChanged: (v) => notifier.setGearType(v)),
//                     const SizedBox(height: 14),
//                     _Label('Marital Status', isDark),
//                     const SizedBox(height: 8),
//                     _RadioWrap(
//                         options: const [
//                           'single',
//                           'married',
//                           'divorced',
//                           'widowed'
//                         ],
//                         labels: const [
//                           'Single',
//                           'Married',
//                           'Divorced',
//                           'Widowed'
//                         ],
//                         value: state.maritalStatus.isEmpty
//                             ? null
//                             : state.maritalStatus,
//                         onChanged: (v) => notifier.setMaritalStatus(v)),
//                     const SizedBox(height: 14),
//                     _Label('Vehicle Type', isDark),
//                     const SizedBox(height: 8),
//                     _RadioWrap(
//                         options: const [
//                           'car',
//                           'jeep',
//                           'mini-bus',
//                           'bus',
//                           'trailer'
//                         ],
//                         labels: const [
//                           'Car',
//                           'Jeep',
//                           'Mini-Bus',
//                           'Bus',
//                           'Trailer'
//                         ],
//                         value: state.vehicleType.isEmpty
//                             ? null
//                             : state.vehicleType,
//                         onChanged: (v) => notifier.setVehicleType(v)),
//                   ])),
//           const SizedBox(height: 24),
//           _PrimaryBtn(
//               label: 'Next',
//               onTap: notifier.nextStep,
//               enabled: !state.isUploadingAny),
//           const SizedBox(height: 24),
//         ]));
//   }
// }

// // ══════════════════════════════════════════════════════════════════════════════
// // DRIVER — STEP 2  (with Google Places autocomplete)
// // ══════════════════════════════════════════════════════════════════════════════
// class _DriverStep2 extends ConsumerStatefulWidget {
//   final String email;
//   final bool isDark;
//   const _DriverStep2({required this.email, required this.isDark});
//   @override
//   ConsumerState<_DriverStep2> createState() => _DriverStep2State();
// }

// class _DriverStep2State extends ConsumerState<_DriverStep2> {
//   final _locCtrl = TextEditingController();
//   final _yoeCtrl = TextEditingController();
//   final _langCtrl = TextEditingController();
//   final _modelCtrl = TextEditingController();
//   final _productCtrl = TextEditingController();
//   final _yearCtrl = TextEditingController();
//   final _colorCtrl = TextEditingController();
//   final _plateCtrl = TextEditingController();
//   final _phoneCtrl = TextEditingController();
//   final _addrCtrl = TextEditingController();

//   double? _lat, _lng;

//   @override
//   void dispose() {
//     for (final c in [
//       _locCtrl,
//       _yoeCtrl,
//       _langCtrl,
//       _modelCtrl,
//       _productCtrl,
//       _yearCtrl,
//       _colorCtrl,
//       _plateCtrl,
//       _phoneCtrl,
//       _addrCtrl
//     ]) {
//       c.dispose();
//     }
//     super.dispose();
//   }

//   Future<void> _submit() async {
//     final n = ref.read(profileSetupProvider.notifier);
//     n.setCurrentLocation(_locCtrl.text.trim());
//     n.setYoe(_yoeCtrl.text.trim());
//     n.setLanguage(_langCtrl.text.trim());
//     n.setCarModel(_modelCtrl.text.trim());
//     n.setCarProduct(_productCtrl.text.trim());
//     n.setCarYear(_yearCtrl.text.trim());
//     n.setCarColor(_colorCtrl.text.trim());
//     n.setPlateNumber(_plateCtrl.text.trim());
//     n.setPhone(_phoneCtrl.text.trim());
//     n.setAddress(_addrCtrl.text.trim());
//     n.setCoordinates(_lat ?? 0.0, _lng ?? 0.0);
//     final ok = await n.submitDriverProfile(widget.email);
//     if (ok && mounted) context.go(AppRoutes.home);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final notifier = ref.read(profileSetupProvider.notifier);
//     final state = ref.watch(profileSetupProvider);

//     return SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(children: [
//           // Car details
//           _Card(
//               isDark: widget.isDark,
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _SectionTitle('Car Details', widget.isDark),
//                     const SizedBox(height: 12),
//                     _TextField(
//                         ctrl: _modelCtrl,
//                         hint: 'Car Model (e.g. Camry)',
//                         icon: Icons.directions_car_outlined,
//                         isDark: widget.isDark),
//                     const SizedBox(height: 10),
//                     _TextField(
//                         ctrl: _productCtrl,
//                         hint: 'Car Product (e.g. Toyota)',
//                         icon: Icons.branding_watermark_outlined,
//                         isDark: widget.isDark),
//                     const SizedBox(height: 10),
//                     _TextField(
//                         ctrl: _yearCtrl,
//                         hint: 'Year (e.g. 2020)',
//                         icon: Icons.calendar_today_outlined,
//                         isDark: widget.isDark,
//                         keyboardType: TextInputType.number),
//                     const SizedBox(height: 10),
//                     _TextField(
//                         ctrl: _colorCtrl,
//                         hint: 'Color (e.g. Black)',
//                         icon: Icons.color_lens_outlined,
//                         isDark: widget.isDark),
//                     const SizedBox(height: 10),
//                     _TextField(
//                         ctrl: _plateCtrl,
//                         hint: 'Plate Number',
//                         icon: Icons.confirmation_number_outlined,
//                         isDark: widget.isDark),
//                   ])),
//           const SizedBox(height: 16),

//           // Location with autocomplete
//           _Card(
//               isDark: widget.isDark,
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _SectionTitle('Location', widget.isDark),
//                     const SizedBox(height: 12),
//                     _Label('Address', widget.isDark, required: true),
//                     const SizedBox(height: 8),
//                     AddressAutocompleteField(
//                       isDark: widget.isDark,
//                       controller: _addrCtrl,
//                       onStateResolved: (s) {
//                         notifier.setState_(s);
//                         setState(() {});
//                       },
//                       onLgaResolved: (l) {
//                         notifier.setLga(l);
//                         setState(() {});
//                       },
//                       onCoordinatesResolved: (lat, lng) {
//                         setState(() {
//                           _lat = lat;
//                           _lng = lng;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 12),
//                     _Label('State', widget.isDark, required: true),
//                     const SizedBox(height: 6),
//                     _Dropdown(
//                         hint: 'Select State',
//                         value: state.state.isEmpty ? null : state.state,
//                         isDark: widget.isDark,
//                         items: NigeriaData.states,
//                         labels: NigeriaData.states,
//                         onChanged: (v) {
//                           if (v != null) notifier.setState_(v);
//                         }),
//                     const SizedBox(height: 12),
//                     _Label('LGA', widget.isDark, required: true),
//                     const SizedBox(height: 6),
//                     _Dropdown(
//                         hint: 'Select LGA',
//                         value: state.lga.isEmpty ? null : state.lga,
//                         isDark: widget.isDark,
//                         items: state.state.isNotEmpty
//                             ? NigeriaData.getLgas(state.state)
//                             : const [],
//                         labels: state.state.isNotEmpty
//                             ? NigeriaData.getLgas(state.state)
//                             : const [],
//                         onChanged: (v) {
//                           if (v != null) notifier.setLga(v);
//                         }),
//                     const SizedBox(height: 10),
//                     _TextField(
//                         ctrl: _locCtrl,
//                         hint: 'Current Location (e.g. Alimosho)',
//                         icon: Icons.my_location_rounded,
//                         isDark: widget.isDark),
//                   ])),
//           const SizedBox(height: 16),

//           // Personal
//           _Card(
//               isDark: widget.isDark,
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _SectionTitle('Personal Details', widget.isDark),
//                     const SizedBox(height: 12),
//                     _TextField(
//                         ctrl: _phoneCtrl,
//                         hint: 'Phone Number',
//                         icon: Icons.phone_outlined,
//                         isDark: widget.isDark,
//                         keyboardType: TextInputType.phone),
//                     const SizedBox(height: 10),
//                     _TextField(
//                         ctrl: _yoeCtrl,
//                         hint: 'Years of Experience',
//                         icon: Icons.work_outline_rounded,
//                         isDark: widget.isDark,
//                         keyboardType: TextInputType.number),
//                     const SizedBox(height: 10),
//                     _TextField(
//                         ctrl: _langCtrl,
//                         hint: 'Languages Spoken',
//                         icon: Icons.language_rounded,
//                         isDark: widget.isDark),
//                     const SizedBox(height: 14),
//                     _Label('Gender', widget.isDark, required: true),
//                     const SizedBox(height: 8),
//                     _RadioRow(
//                         options: const ['male', 'female'],
//                         labels: const ['Male', 'Female'],
//                         value: state.gender.isEmpty ? null : state.gender,
//                         onChanged: (v) => notifier.setGender(v)),
//                   ])),
//           const SizedBox(height: 24),

//           Row(children: [
//             Expanded(
//                 child: _OutlineBtn(
//                     label: 'Back',
//                     isDark: widget.isDark,
//                     onTap: () =>
//                         ref.read(profileSetupProvider.notifier).prevStep())),
//             const SizedBox(width: 12),
//             Expanded(
//                 child: _PrimaryBtn(
//                     label: 'Submit',
//                     isLoading: state.isSubmitting,
//                     enabled: !state.isSubmitting,
//                     onTap: _submit)),
//           ]),
//           const SizedBox(height: 32),
//         ]));
//   }
// }

// // ── Shared widgets (unchanged from previous version) ──────────────────────────

// class _Card extends StatelessWidget {
//   final Widget child;
//   final bool isDark;
//   const _Card({required this.child, required this.isDark});
//   @override
//   Widget build(BuildContext context) => Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//           color: isDark ? AppColors.darkSurface : AppColors.surface,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 3))
//           ]),
//       child: child);
// }

// Widget _Label(String t, bool isDark, {bool required = false}) => RichText(
//     text: TextSpan(
//         text: t,
//         style: TextStyle(
//             color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
//             fontSize: 13,
//             fontWeight: FontWeight.w600),
//         children: required
//             ? [
//                 const TextSpan(
//                     text: ' *', style: TextStyle(color: AppColors.error))
//               ]
//             : []));

// Widget _SectionTitle(String t, bool isDark) => Text(t,
//     style: TextStyle(
//         color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
//         fontSize: 15,
//         fontWeight: FontWeight.w700));

// class _TextField extends StatelessWidget {
//   final TextEditingController ctrl;
//   final String hint;
//   final bool isDark;
//   final IconData icon;
//   final TextInputType? keyboardType;
//   const _TextField(
//       {required this.ctrl,
//       required this.hint,
//       required this.isDark,
//       required this.icon,
//       this.keyboardType});
//   @override
//   Widget build(BuildContext context) => TextFormField(
//       controller: ctrl,
//       keyboardType: keyboardType,
//       style: TextStyle(
//           color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
//           fontSize: 14),
//       decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
//           prefixIcon: Icon(icon, color: AppColors.textHint, size: 18),
//           filled: true,
//           fillColor:
//               isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//           border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide.none),
//           enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide.none),
//           focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide:
//                   const BorderSide(color: AppColors.secondary, width: 2))));
// }

// class _Dropdown extends StatelessWidget {
//   final String hint;
//   final String? value;
//   final bool isDark;
//   final List<String> items, labels;
//   final void Function(String?) onChanged;
//   const _Dropdown(
//       {required this.hint,
//       required this.value,
//       required this.isDark,
//       required this.items,
//       required this.labels,
//       required this.onChanged});
//   @override
//   Widget build(BuildContext context) => DropdownButtonFormField<String>(
//       value: value,
//       onChanged: onChanged,
//       dropdownColor: isDark ? AppColors.darkSurface : AppColors.surface,
//       hint: Text(hint,
//           style: const TextStyle(color: AppColors.textHint, fontSize: 14)),
//       style: TextStyle(
//           color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
//           fontSize: 14),
//       items: List.generate(items.length,
//           (i) => DropdownMenuItem(value: items[i], child: Text(labels[i]))),
//       decoration: InputDecoration(
//           filled: true,
//           fillColor:
//               isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//           border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide.none),
//           enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide.none),
//           focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide:
//                   const BorderSide(color: AppColors.secondary, width: 2))));
// }

// class _RadioRow extends StatelessWidget {
//   final List<String> options, labels;
//   final String? value;
//   final void Function(String) onChanged;
//   const _RadioRow(
//       {required this.options,
//       required this.labels,
//       required this.value,
//       required this.onChanged});
//   @override
//   Widget build(BuildContext context) => Wrap(
//       spacing: 24,
//       children: List.generate(
//           options.length,
//           (i) => GestureDetector(
//               onTap: () => onChanged(options[i]),
//               child: Row(mainAxisSize: MainAxisSize.min, children: [
//                 _Radio(selected: value == options[i]),
//                 const SizedBox(width: 6),
//                 Text(labels[i],
//                     style: TextStyle(
//                         fontSize: 14,
//                         color: value == options[i]
//                             ? AppColors.secondary
//                             : AppColors.textSecondary)),
//               ]))));
// }

// class _RadioWrap extends StatelessWidget {
//   final List<String> options, labels;
//   final String? value;
//   final void Function(String) onChanged;
//   const _RadioWrap(
//       {required this.options,
//       required this.labels,
//       required this.value,
//       required this.onChanged});
//   @override
//   Widget build(BuildContext context) => Wrap(
//       spacing: 16,
//       runSpacing: 8,
//       children: List.generate(
//           options.length,
//           (i) => GestureDetector(
//               onTap: () => onChanged(options[i]),
//               child: Row(mainAxisSize: MainAxisSize.min, children: [
//                 _Radio(selected: value == options[i]),
//                 const SizedBox(width: 6),
//                 Text(labels[i],
//                     style: TextStyle(
//                         fontSize: 13,
//                         color: value == options[i]
//                             ? AppColors.secondary
//                             : AppColors.textSecondary)),
//               ]))));
// }

// class _Radio extends StatelessWidget {
//   final bool selected;
//   const _Radio({required this.selected});
//   @override
//   Widget build(BuildContext context) => Container(
//       width: 20,
//       height: 20,
//       decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(
//               color: selected ? AppColors.secondary : AppColors.textHint,
//               width: 2)),
//       child: selected
//           ? Center(
//               child: Container(
//                   width: 10,
//                   height: 10,
//                   decoration: const BoxDecoration(
//                       shape: BoxShape.circle, color: AppColors.secondary)))
//           : null);
// }

// class _CheckItem extends StatelessWidget {
//   final String label;
//   final bool value, isDark;
//   final void Function(bool) onChanged;
//   const _CheckItem(
//       {required this.label,
//       required this.value,
//       required this.isDark,
//       required this.onChanged});
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//       onTap: () => onChanged(!value),
//       child: Row(mainAxisSize: MainAxisSize.min, children: [
//         AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             width: 20,
//             height: 20,
//             decoration: BoxDecoration(
//                 color: value ? AppColors.secondary : Colors.transparent,
//                 borderRadius: BorderRadius.circular(4),
//                 border: Border.all(
//                     color: value ? AppColors.secondary : AppColors.textHint,
//                     width: 1.5)),
//             child: value
//                 ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
//                 : null),
//         const SizedBox(width: 8),
//         Text(label,
//             style: TextStyle(
//                 fontSize: 14,
//                 color: isDark
//                     ? AppColors.darkTextPrimary
//                     : AppColors.textPrimary)),
//       ]));
// }

// class _UploadBox extends StatelessWidget {
//   final String? url;
//   final bool isDark, isLoading;
//   final String placeholder;
//   final IconData icon;
//   const _UploadBox(
//       {this.url,
//       required this.isDark,
//       this.isLoading = false,
//       required this.placeholder,
//       required this.icon});
//   @override
//   Widget build(BuildContext context) => Container(
//       width: double.infinity,
//       height: 110,
//       decoration: BoxDecoration(
//           color:
//               isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF0F0F5),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//               color: AppColors.textHint.withOpacity(0.35), width: 1.5)),
//       clipBehavior: Clip.hardEdge,
//       child: isLoading
//           ? const Center(
//               child: CircularProgressIndicator(
//                   color: AppColors.secondary, strokeWidth: 2))
//           : url != null
//               ? Stack(fit: StackFit.expand, children: [
//                   Image.network(url!, fit: BoxFit.cover),
//                   Positioned(
//                       top: 8,
//                       right: 8,
//                       child: Container(
//                           padding: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                               color: AppColors.secondary,
//                               borderRadius: BorderRadius.circular(8)),
//                           child: const Icon(Icons.check_rounded,
//                               color: Colors.white, size: 14))),
//                 ])
//               : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//                   Icon(icon, color: AppColors.textHint, size: 26),
//                   const SizedBox(height: 8),
//                   Text(placeholder,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                           color: AppColors.textHint, fontSize: 13)),
//                 ]));
// }

// class _PrimaryBtn extends StatelessWidget {
//   final String label;
//   final VoidCallback onTap;
//   final bool enabled;
//   final bool isLoading;
//   const _PrimaryBtn(
//       {required this.label,
//       required this.onTap,
//       this.enabled = true,
//       this.isLoading = false});
//   @override
//   Widget build(BuildContext context) => SizedBox(
//       width: double.infinity,
//       height: 52,
//       child: ElevatedButton(
//           onPressed: enabled && !isLoading ? onTap : null,
//           style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.secondary,
//               disabledBackgroundColor: AppColors.secondary.withOpacity(0.4),
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14))),
//           child: isLoading
//               ? const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                       color: Colors.white, strokeWidth: 2.5))
//               : Text(label,
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 15,
//                       fontWeight: FontWeight.w700))));
// }

// class _OutlineBtn extends StatelessWidget {
//   final String label;
//   final VoidCallback onTap;
//   final bool isDark;
//   const _OutlineBtn(
//       {required this.label, required this.onTap, required this.isDark});
//   @override
//   Widget build(BuildContext context) => SizedBox(
//       height: 52,
//       child: OutlinedButton(
//           onPressed: onTap,
//           style: OutlinedButton.styleFrom(
//               side: const BorderSide(color: AppColors.textHint, width: 1.5),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14))),
//           child: Text(label,
//               style: TextStyle(
//                   color: isDark
//                       ? AppColors.darkTextPrimary
//                       : AppColors.textPrimary,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w700))));
// }
