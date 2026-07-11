// lib/features/ride/presentation/pages/book_ride_page.dart
//
// Flow:
// 1. User searches pickup + destination via autocomplete
// 2. Selects ride option (Economy / Premium / Shared)
// 3. Optionally enters desired price, passengers, payment method
// 4. Taps "Calculate Fare" → POST /rides → shows calculatedPrice + distance
// 5. Taps "Book Ride" → starts polling → shows "Finding Driver" modal
// 6. Driver offers appear → user sees driver list
// 7. User can cancel anytime

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/services/places_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ride_entity.dart';
import '../providers/ride_notifier.dart';
import '../providers/ride_state.dart';

class BookRidePage extends ConsumerStatefulWidget {
  final LatLng? origin;
  const BookRidePage({super.key, this.origin});
  @override
  ConsumerState<BookRidePage> createState() => _BookRidePageState();
}

class _BookRidePageState extends ConsumerState<BookRidePage> {
  // Controllers
  final _pickupCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _desiredPriceCtrl = TextEditingController();
  final _passengersCtrl = TextEditingController(text: '1');

  // Autocomplete state
  List<PlacePrediction> _pickupPredictions = [];
  List<PlacePrediction> _destPredictions = [];
  bool _searchingPickup = false;
  bool _searchingDest = false;
  bool _pickupFocused = false;

  // Selected locations
  LatLng? _pickupLatLng;
  LatLng? _destLatLng;
  String _pickupAddress = '';
  String _destAddress = '';

  // Form state
  String _rideOption = 'economy';
  String _paymentMethod = 'cash';

  // Map
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  late LatLng _defaultOrigin;

  @override
  void initState() {
    super.initState();
    _defaultOrigin = widget.origin ?? const LatLng(6.5244, 3.3792);
    if (widget.origin != null) {
      _pickupLatLng = widget.origin;
      // Reverse geocode GPS coords to fill the pickup text field.
      // User sees their current location address, not a blank field.
      // They can still clear it and type a custom pickup address.
      _prefillPickupFromGps(widget.origin!);
    }
  }

  Future<void> _prefillPickupFromGps(LatLng latLng) async {
    try {
      final address = await LocationService.instance
          .getAddressFromLatLng(latLng.latitude, latLng.longitude);
      if (!mounted) return;
      setState(() {
        _pickupAddress = address;
        _pickupCtrl.text = address;
      });
    } catch (_) {
      // Silent — user can type a custom pickup manually
    }
  }

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _destCtrl.dispose();
    _desiredPriceCtrl.dispose();
    _passengersCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ── Autocomplete ───────────────────────────────────────────────────────────
  Future<void> _onPickupChanged(String v) async {
    if (v.length < 3) {
      setState(() => _pickupPredictions = []);
      return;
    }
    setState(() => _searchingPickup = true);
    final results = await PlacesService.instance.autocomplete(v);
    if (mounted)
      setState(() {
        _pickupPredictions = results;
        _searchingPickup = false;
      });
  }

  Future<void> _onDestChanged(String v) async {
    if (v.length < 3) {
      setState(() => _destPredictions = []);
      return;
    }
    setState(() => _searchingDest = true);
    final results = await PlacesService.instance.autocomplete(v);
    if (mounted)
      setState(() {
        _destPredictions = results;
        _searchingDest = false;
      });
  }

  Future<void> _selectPickup(PlacePrediction p) async {
    _pickupCtrl.text = p.fullText;
    setState(() {
      _pickupPredictions = [];
    });
    final place = await PlacesService.instance.fetchPlace(p.placeId);
    if (place == null || !mounted) return;
    setState(() {
      _pickupLatLng = LatLng(place.lat, place.lng);
      _pickupAddress = p.fullText;
    });
    _updateMap();
  }

  Future<void> _selectDest(PlacePrediction p) async {
    _destCtrl.text = p.fullText;
    setState(() {
      _destPredictions = [];
    });
    final place = await PlacesService.instance.fetchPlace(p.placeId);
    if (place == null || !mounted) return;
    setState(() {
      _destLatLng = LatLng(place.lat, place.lng);
      _destAddress = p.fullText;
    });
    _updateMap();
  }

  void _updateMap() {
    if (_pickupLatLng == null || _destLatLng == null) return;
    setState(() {
      _markers = {
        Marker(
            markerId: const MarkerId('pickup'),
            position: _pickupLatLng!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: const InfoWindow(title: 'Pickup')),
        Marker(
            markerId: const MarkerId('dest'),
            position: _destLatLng!,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(title: 'Drop off')),
      };
      _polylines = {
        Polyline(
            polylineId: const PolylineId('route'),
            points: [_pickupLatLng!, _destLatLng!],
            color: AppColors.secondary,
            width: 4,
            patterns: [PatternItem.dash(20), PatternItem.gap(10)]),
      };
    });
    final sw = LatLng(min(_pickupLatLng!.latitude, _destLatLng!.latitude),
        min(_pickupLatLng!.longitude, _destLatLng!.longitude));
    final ne = LatLng(max(_pickupLatLng!.latitude, _destLatLng!.latitude),
        max(_pickupLatLng!.longitude, _destLatLng!.longitude));
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: sw, northeast: ne), 80));
  }

  // ── Book ride ──────────────────────────────────────────────────────────────
  // POST /rides — the fare comes back in the response
  Future<void> _bookRide() async {
    if (_pickupLatLng == null || _destLatLng == null) {
      _showSnack('Please select pickup and destination', isError: true);
      return;
    }
    final passengers = int.tryParse(_passengersCtrl.text.trim()) ?? 1;
    final desired = double.tryParse(_desiredPriceCtrl.text.trim());

    final params = CreateRideParams(
      pickupAddress: _pickupAddress,
      destinationAddress: _destAddress,
      pickupCoordinates: RideCoordinatesEntity(
          lat: _pickupLatLng!.latitude, lng: _pickupLatLng!.longitude),
      destinationCoordinates: RideCoordinatesEntity(
          lat: _destLatLng!.latitude, lng: _destLatLng!.longitude),
      rideOption: _rideOption,
      paymentMethod: _paymentMethod,
      passengerNum: passengers,
      desiredPrice: desired,
    );

    await ref.read(rideProvider.notifier).createRide(params);
  }

  Future<void> _cancelRide() async {
    final ok = await ref.read(rideProvider.notifier).cancelRide();
    if (ok && mounted) _showSnack('Ride cancelled');
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rideState = ref.watch(rideProvider);

    // Error listener
    ref.listen(rideProvider.select((s) => s.error), (_, error) {
      if (error != null) {
        _showSnack(error, isError: true);
        ref.read(rideProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(children: [
        // ── Map ──────────────────────────────────────────────────────────────
        GoogleMap(
          onMapCreated: (c) => _mapController = c,
          initialCameraPosition:
              CameraPosition(target: _defaultOrigin, zoom: 12),
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),

        // ── Scrollable form ───────────────────────────────────────────────
        DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (_, ctrl) => Container(
            decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, -4))
                ]),
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                // Handle
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkDivider
                                : AppColors.divider,
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),

                Text('Book a Ride',
                    style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),

                // ── Pickup ─────────────────────────────────────────────────
                _buildSearchField(
                  ctrl: _pickupCtrl,
                  hint: 'Enter pickup location',
                  icon: Icons.radio_button_checked,
                  iconColor: AppColors.secondary,
                  isDark: isDark,
                  isLoading: _searchingPickup,
                  onChanged: _onPickupChanged,
                  onFocus: (f) => setState(() => _pickupFocused = f),
                ),
                if (_pickupPredictions.isNotEmpty)
                  _buildPredictionList(
                      _pickupPredictions, _selectPickup, isDark),
                const SizedBox(height: 10),

                // ── Destination ────────────────────────────────────────────
                _buildSearchField(
                  ctrl: _destCtrl,
                  hint: 'Enter destination',
                  icon: Icons.place_rounded,
                  iconColor: AppColors.error,
                  isDark: isDark,
                  isLoading: _searchingDest,
                  onChanged: _onDestChanged,
                  onFocus: (_) {},
                ),
                if (_destPredictions.isNotEmpty)
                  _buildPredictionList(_destPredictions, _selectDest, isDark),
                const SizedBox(height: 16),

                // ── Ride option ─────────────────────────────────────────────
                Text('Ride Option',
                    style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                _buildRideOptions(isDark),
                const SizedBox(height: 16),

                // ── Desired price (optional) ────────────────────────────────
                Text('Your Offered Fare (₦) — optional',
                    style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _inputField(
                    ctrl: _desiredPriceCtrl,
                    hint: 'Enter your offered fare (optional)',
                    isDark: isDark,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 14),

                // ── Passengers ─────────────────────────────────────────────
                Text('How many passengers',
                    style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _inputField(
                    ctrl: _passengersCtrl,
                    hint: 'Number of passengers',
                    isDark: isDark,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 14),

                // ── Payment method ──────────────────────────────────────────
                Text('Payment Method',
                    style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildPaymentDropdown(isDark),
                const SizedBox(height: 20),

                // ── Fare result (shown after booking) ───────────────────────
                if (rideState.activeRide != null) ...[
                  Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.secondary.withOpacity(0.2))),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Distance: ${rideState.activeRide!.distance.toStringAsFixed(2)} km',
                                style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                    fontSize: 13)),
                            const SizedBox(height: 4),
                            Row(children: [
                              Text('Calculated Price: ',
                                  style: TextStyle(
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary,
                                      fontSize: 13)),
                              Text(
                                  '₦${rideState.activeRide!.calculatedPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                            ]),
                            if (rideState.activeRide!.desiredPrice != null) ...[
                              const SizedBox(height: 4),
                              Row(children: [
                                Text('Desired Price: ',
                                    style: TextStyle(
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary,
                                        fontSize: 13)),
                                Text(
                                    '₦${rideState.activeRide!.desiredPrice!.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        color: Color(0xFF3F51B5),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700)),
                              ]),
                            ],
                          ])),
                  const SizedBox(height: 16),
                ],

                // ── Book button ─────────────────────────────────────────────
                if (!rideState.hasActiveRide)
                  SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: rideState.status == RideStatus.creatingRide
                            ? null
                            : _bookRide,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            disabledBackgroundColor:
                                AppColors.secondary.withOpacity(0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        child: rideState.status == RideStatus.creatingRide
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : const Text('Calculate Fare & Book Ride',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                      )),
              ],
            ),
          ),
        ),

        // ── Back button ───────────────────────────────────────────────────
        SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(12),
          child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 8)
                      ]),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      size: 18))),
        )),

        // ── Finding driver modal ───────────────────────────────────────────
        if (rideState.status == RideStatus.findingDriver ||
            rideState.status == RideStatus.driversFound ||
            rideState.status == RideStatus.cancelling)
          _FindingDriverModal(
            rideState: rideState,
            isDark: isDark,
            onCancel: _cancelRide,
          ),
      ]),
    );
  }

  // ── Helper widgets ─────────────────────────────────────────────────────────

  Widget _buildSearchField({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required bool isLoading,
    required void Function(String) onChanged,
    required void Function(bool) onFocus,
  }) =>
      Focus(
          onFocusChange: onFocus,
          child: TextFormField(
              controller: ctrl,
              onChanged: onChanged,
              style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontSize: 14),
              decoration: InputDecoration(
                  hintText: hint,
                  hintStyle:
                      const TextStyle(color: AppColors.textHint, fontSize: 14),
                  prefixIcon: Icon(icon, color: iconColor, size: 20),
                  suffixIcon: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: AppColors.secondary, strokeWidth: 2)))
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.surfaceVariant,
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
                      borderSide: const BorderSide(
                          color: AppColors.secondary, width: 2)))));

  Widget _buildPredictionList(
    List<PlacePrediction> predictions,
    Future<void> Function(PlacePrediction) onSelect,
    bool isDark,
  ) {
    final items = <Widget>[];
    for (final p in predictions) {
      items.add(InkWell(
          onTap: () => onSelect(p),
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(children: [
                const Icon(Icons.place_outlined,
                    color: AppColors.secondary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(p.mainText,
                          style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      if (p.secondaryText.isNotEmpty)
                        Text(p.secondaryText,
                            style: const TextStyle(
                                color: AppColors.textHint, fontSize: 11)),
                    ])),
              ]))));
    }
    return Container(
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ]),
        child: Column(children: items));
  }

  Widget _buildRideOptions(bool isDark) {
    const options = [
      ('economy', 'Economy', Icons.directions_car_rounded),
      ('premium', 'Premium', Icons.airport_shuttle_rounded),
      ('shared', 'Shared', Icons.people_rounded),
    ];
    return Row(
        children: options.map((o) {
      final selected = _rideOption == o.$1;
      return Expanded(
          child: GestureDetector(
              onTap: () => setState(() => _rideOption = o.$1),
              child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: o.$1 != 'shared' ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                      color: selected
                          ? AppColors.secondary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: selected
                              ? AppColors.secondary
                              : AppColors.divider,
                          width: selected ? 2 : 1.5)),
                  child: Column(children: [
                    Icon(o.$3,
                        color:
                            selected ? AppColors.secondary : AppColors.textHint,
                        size: 24),
                    const SizedBox(height: 4),
                    Text(o.$2,
                        style: TextStyle(
                            color: selected
                                ? AppColors.secondary
                                : AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ]))));
    }).toList());
  }

  Widget _buildPaymentDropdown(bool isDark) => DropdownButtonFormField<String>(
      value: _paymentMethod,
      onChanged: (v) {
        if (v != null) setState(() => _paymentMethod = v);
      },
      dropdownColor: isDark ? AppColors.darkSurface : AppColors.surface,
      style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          fontSize: 14),
      items: const [
        DropdownMenuItem(value: 'cash', child: Text('Cash')),
        DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
      ],
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

  Widget _inputField({
    required TextEditingController ctrl,
    required String hint,
    required bool isDark,
    TextInputType? keyboardType,
  }) =>
      TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontSize: 14),
          decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: AppColors.textHint, fontSize: 14),
              filled: true,
              fillColor: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.surfaceVariant,
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

// ══════════════════════════════════════════════════════════════════════════════
// Finding Driver Modal
// ══════════════════════════════════════════════════════════════════════════════
class _FindingDriverModal extends StatefulWidget {
  final RideState rideState;
  final bool isDark;
  final VoidCallback onCancel;
  const _FindingDriverModal({
    required this.rideState,
    required this.isDark,
    required this.onCancel,
  });
  @override
  State<_FindingDriverModal> createState() => _FindingDriverModalState();
}

class _FindingDriverModalState extends State<_FindingDriverModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotCtrl;

  @override
  void initState() {
    super.initState();
    _dotCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCancelling = widget.rideState.status == RideStatus.cancelling;
    final hasDrivers = widget.rideState.driverOffers.isNotEmpty;

    return Container(
        color: Colors.black54,
        child: Center(
            child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: widget.isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(hasDrivers ? 'Drivers Found!' : 'Finding Your Driver',
                  style: TextStyle(
                      color: widget.isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
              TextButton(
                  onPressed: isCancelling ? null : widget.onCancel,
                  style: TextButton.styleFrom(
                      backgroundColor: AppColors.surfaceVariant,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6)),
                  child: isCancelling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: AppColors.error, strokeWidth: 2))
                      : const Text('Cancel Ride',
                          style: TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w600))),
            ]),
            const SizedBox(height: 20),

            // Animated car icon
            AnimatedBuilder(
                animation: _dotCtrl,
                builder: (_, __) => Icon(Icons.directions_car_rounded,
                    color: AppColors.secondary, size: 40 + _dotCtrl.value * 6)),
            const SizedBox(height: 16),

            if (!hasDrivers) ...[
              Text('Waiting for available drivers\nto accept your ride...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: widget.isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      fontSize: 14)),
              const SizedBox(height: 12),
              // Animated dots
              AnimatedBuilder(
                animation: _dotCtrl,
                builder: (_, __) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        3,
                        (i) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.secondary.withOpacity(0.3 +
                                    (_dotCtrl.value * 0.7) *
                                        (i == 1 ? 1 : 0.5)))))),
              ),
            ] else ...[
              // Driver list
              Text(
                  '${widget.rideState.driverOffers.length} driver(s) responded',
                  style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ...widget.rideState.driverOffers.map((d) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.secondary.withOpacity(0.2))),
                  child: Row(children: [
                    const CircleAvatar(
                        backgroundColor: AppColors.secondary,
                        radius: 18,
                        child: Icon(Icons.person_rounded,
                            color: Colors.white, size: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                              d.driverName.isNotEmpty ? d.driverName : 'Driver',
                              style: TextStyle(
                                  color: widget.isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          Text(d.status,
                              style: const TextStyle(
                                  color: AppColors.textHint, fontSize: 11)),
                        ])),
                    if (d.offeredPrice != null)
                      Text('₦${d.offeredPrice!.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800)),
                  ]))),
            ],
          ]),
        )));
  }
}
