// lib/features/auth/presentation/widgets/address_autocomplete_field.dart

import 'package:flutter/material.dart';
import '../../../../core/services/places_service.dart';
import '../../../../core/data/nigeria_data.dart';
import '../../../../core/theme/app_colors.dart';

class AddressAutocompleteField extends StatefulWidget {
  final bool isDark;
  final TextEditingController controller;
  final void Function(String state)? onStateResolved;
  final void Function(String lga)? onLgaResolved;
  final void Function(double lat, double lng)? onCoordinatesResolved;

  const AddressAutocompleteField({
    super.key,
    required this.isDark,
    required this.controller,
    this.onStateResolved,
    this.onLgaResolved,
    this.onCoordinatesResolved,
  });

  @override
  State<AddressAutocompleteField> createState() =>
      _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  List<PlacePrediction> _predictions = [];
  bool _loading = false;

  Future<void> _onChanged(String value) async {
    if (value.length < 3) {
      setState(() {
        _predictions = [];
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    final results = await PlacesService.instance.autocomplete(value);
    if (mounted)
      setState(() {
        _predictions = results;
        _loading = false;
      });
  }

  Future<void> _onSelected(PlacePrediction prediction) async {
    widget.controller.text = prediction.fullText;
    setState(() {
      _predictions = [];
    });

    final place = await PlacesService.instance.fetchPlace(prediction.placeId);
    if (place == null || !mounted) return;

    widget.onCoordinatesResolved?.call(place.lat, place.lng);

    final stateName = PlacesService.instance.extractState(place);
    if (stateName != null) {
      final matched = NigeriaData.states.firstWhere(
        (s) => s.toLowerCase() == stateName.toLowerCase(),
        orElse: () => '',
      );
      if (matched.isNotEmpty) widget.onStateResolved?.call(matched);

      final lgaName = PlacesService.instance.extractLga(place);
      if (lgaName != null) {
        final lgas =
            NigeriaData.getLgas(matched.isNotEmpty ? matched : stateName);
        final matchedLga = lgas.firstWhere(
          (l) =>
              l.toLowerCase().contains(lgaName.toLowerCase()) ||
              lgaName.toLowerCase().contains(l.toLowerCase()),
          orElse: () => '',
        );
        if (matchedLga.isNotEmpty) widget.onLgaResolved?.call(matchedLga);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextFormField(
        controller: widget.controller,
        onChanged: _onChanged,
        style: TextStyle(
            color: widget.isDark
                ? AppColors.darkTextPrimary
                : AppColors.textPrimary,
            fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Enter your address',
          hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
          prefixIcon: const Icon(Icons.location_on_outlined,
              color: AppColors.textHint, size: 18),
          suffixIcon: _loading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: AppColors.secondary, strokeWidth: 2)))
              : null,
          filled: true,
          fillColor: widget.isDark
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
                  const BorderSide(color: AppColors.secondary, width: 2)),
        ),
      ),
      if (_predictions.isNotEmpty)
        Container(
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
              color: widget.isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: _predictions
                  .map((p) => InkWell(
                        onTap: () => _onSelected(p),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(children: [
                              const Icon(Icons.place_outlined,
                                  color: AppColors.secondary, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(p.mainText,
                                        style: TextStyle(
                                            color: widget.isDark
                                                ? AppColors.darkTextPrimary
                                                : AppColors.textPrimary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                    if (p.secondaryText.isNotEmpty)
                                      Text(p.secondaryText,
                                          style: const TextStyle(
                                              color: AppColors.textHint,
                                              fontSize: 12)),
                                  ])),
                            ])),
                      ))
                  .toList(),
            ),
          ),
        ),
    ]);
  }
}
