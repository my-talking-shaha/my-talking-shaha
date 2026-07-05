import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/garage/presentation/controllers/add_vehicle_controller.dart';
import 'package:frontend/features/garage/presentation/providers/garage_providers.dart';
import 'package:frontend/features/garage/presentation/state/add_vehicle_state.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

final class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({this.vehicleId, super.key});

  final String? vehicleId;

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

final class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  late final AddVehicleController _controller;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _mileageController;
  late final TextEditingController _colorController;
  late final TextEditingController _vinController;
  late final TextEditingController _engineSpecificationController;
  late final FocusNode _brandFocusNode;
  late final FocusNode _colorFocusNode;
  bool _isLoadingVehicle = false;

  static const _backgroundColor = Color(0xFF0D111A);
  static const _accentColor = Color(0xFFB8C3FF);
  static const _standardVehicleColors = [
    'White',
    'Black',
    'Silver',
    'Grey',
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Orange',
    'Brown',
    'Beige',
    'Gold',
    'Purple',
  ];

  @override
  void initState() {
    super.initState();
    _controller = ref.read(addVehicleControllerProvider);
    _brandController = TextEditingController();
    _modelController = TextEditingController();
    _yearController = TextEditingController();
    _mileageController = TextEditingController();
    _colorController = TextEditingController();
    _vinController = TextEditingController();
    _engineSpecificationController = TextEditingController();
    _brandFocusNode = FocusNode();
    _colorFocusNode = FocusNode();
    unawaited(_loadVehicleForEdit());
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _colorController.dispose();
    _vinController.dispose();
    _engineSpecificationController.dispose();
    _brandFocusNode.dispose();
    _colorFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadVehicleForEdit() async {
    final vehicleId = widget.vehicleId;
    if (vehicleId == null) {
      return;
    }

    setState(() {
      _isLoadingVehicle = true;
    });

    try {
      final vehicles = await ref.read(garageRepositoryProvider).getVehicles();
      final vehicle = vehicles.firstWhere((vehicle) => vehicle.id == vehicleId);
      _controller.loadVehicle(vehicle);
      _syncTextControllers();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).vehicleNotFound)),
      );
      context.go('/garage');
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingVehicle = false;
        });
      }
    }
  }

  void _syncTextControllers() {
    final state = _controller.state;
    final canonicalColor = _canonicalVehicleColor(state.color);
    if (canonicalColor != null && canonicalColor != state.color) {
      _controller.updateColor(canonicalColor);
    }
    final syncedState = _controller.state;
    _brandController.text = syncedState.brand;
    _modelController.text = syncedState.model;
    _yearController.text = syncedState.year;
    _mileageController.text = syncedState.currentMileage;
    _colorController.text = syncedState.color;
    _vinController.text = syncedState.vin;
    _engineSpecificationController.text = syncedState.engineSpecification;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = _controller.state;
    final vehicleBrands = ref.watch(vehicleBrandsProvider);
    final hasEngineType = state.engineType.isNotEmpty;
    final isEditing = widget.vehicleId != null;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: _accentColor),
        title: Text(
          isEditing ? l10n.editCar : l10n.carSpecifications,
          style: const TextStyle(
            color: _accentColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          onPressed: () => context.go('/garage'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _dismissKeyboard,
        child: SafeArea(
          child: _isLoadingVehicle
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GarageBrandField(
                        controller: _brandController,
                        focusNode: _brandFocusNode,
                        brands: _brandOptions(
                          vehicleBrands.whenOrNull(data: (brands) => brands),
                        ),
                        isLoading: vehicleBrands.isLoading,
                        errorText: _brandErrorText(l10n, vehicleBrands, state),
                        onRetry: () => ref.invalidate(vehicleBrandsProvider),
                        onChanged: (value) =>
                            _update(_controller.updateBrand, value),
                      ),
                      const SizedBox(height: 24),
                      _GarageTextField(
                        label: l10n.model,
                        hintText: '2106',
                        controller: _modelController,
                        errorText: _localizedVehicleError(
                          l10n,
                          state.fieldErrors['model'],
                        ),
                        textInputAction: TextInputAction.next,
                        onChanged: (value) =>
                            _update(_controller.updateModel, value),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _GarageTextField(
                              label: l10n.year,
                              hintText: '1998',
                              controller: _yearController,
                              errorText: _localizedVehicleError(
                                l10n,
                                state.fieldErrors['year'],
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textInputAction: TextInputAction.next,
                              onChanged: (value) =>
                                  _update(_controller.updateYear, value),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _GarageTextField(
                              label: l10n.currentMileage,
                              hintText: '124580',
                              controller: _mileageController,
                              errorText: _localizedVehicleError(
                                l10n,
                                state.fieldErrors['currentMileageKm'],
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textInputAction: TextInputAction.next,
                              onChanged: (value) => _update(
                                _controller.updateCurrentMileage,
                                value,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _GarageColorField(
                        controller: _colorController,
                        focusNode: _colorFocusNode,
                        colors: _standardVehicleColors,
                        onChanged: (value) =>
                            _update(_controller.updateColor, value),
                      ),
                      const SizedBox(height: 24),
                      _GarageTextField(
                        label: l10n.vinOptional,
                        hintText: 'XTA21060012345678',
                        controller: _vinController,
                        errorText: _localizedVehicleError(
                          l10n,
                          state.fieldErrors['vin'],
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(17),
                          FilteringTextInputFormatter.allow(
                            RegExp('[a-zA-Z0-9]'),
                          ),
                        ],
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: TextInputAction.next,
                        onChanged: (value) =>
                            _update(_controller.updateVin, value),
                      ),
                      const SizedBox(height: 24),
                      _GarageEngineTypeField(
                        selectedValue: state.engineType,
                        errorText: _localizedVehicleError(
                          l10n,
                          state.fieldErrors['engineType'],
                        ),
                        onChanged: state.isSubmitting
                            ? null
                            : _updateEngineType,
                      ),
                      if (hasEngineType) ...[
                        const SizedBox(height: 24),
                        _GarageTextField(
                          label: state.engineType == 'electric'
                              ? l10n.powerOutputHp
                              : l10n.engineVolumeL,
                          hintText: state.engineType == 'electric'
                              ? '283'
                              : '1.6',
                          controller: _engineSpecificationController,
                          errorText: _localizedVehicleError(
                            l10n,
                            state.fieldErrors['engineSpecification'],
                          ),
                          keyboardType: state.engineType == 'electric'
                              ? TextInputType.number
                              : const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                          inputFormatters: [
                            if (state.engineType == 'electric')
                              FilteringTextInputFormatter.digitsOnly
                            else
                              FilteringTextInputFormatter.allow(
                                RegExp('[0-9,.]'),
                              ),
                          ],
                          textInputAction: TextInputAction.done,
                          onChanged: (value) => _update(
                            _controller.updateEngineSpecification,
                            value,
                          ),
                        ),
                      ],
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          _localizedVehicleError(l10n, state.errorMessage)!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.error),
                        ),
                      ],
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF315BFF),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(
                              0xFF315BFF,
                            ).withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 12,
                            shadowColor: const Color(0xFF315BFF),
                          ),
                          onPressed: state.isSubmitting ? null : _submit,
                          child: state.isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/garage/rocket.svg',
                                      width: 20,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isEditing
                                          ? l10n.saveChanges
                                          : l10n.startNewShaha,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
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
      ),
    );
  }

  List<String> _brandOptions(List<String>? brands) {
    final options = <String>[...?brands];
    final selectedBrand = _controller.state.brand.trim();
    if (selectedBrand.isNotEmpty && !options.contains(selectedBrand)) {
      options.add(selectedBrand);
    }

    return List.unmodifiable(options);
  }

  String? _brandErrorText(
    AppLocalizations l10n,
    AsyncValue<List<String>> brands,
    AddVehicleState state,
  ) {
    final fieldError = _localizedVehicleError(l10n, state.fieldErrors['brand']);
    if (fieldError != null) {
      return fieldError;
    }

    if (brands.hasError) {
      return 'Could not load brands';
    }

    return null;
  }

  void _update(void Function(String value) update, String value) {
    setState(() {
      update(value);
    });
  }

  void _dismissKeyboard() {
    final focusScope = FocusScope.of(context);
    if (!focusScope.hasPrimaryFocus) {
      focusScope.unfocus();
    }
  }

  void _updateEngineType(String value) {
    _dismissKeyboard();
    setState(() {
      _controller.updateEngineType(value);
      _engineSpecificationController.text =
          _controller.state.engineSpecification;
    });
  }

  String? _canonicalVehicleColor(String color) {
    final normalizedColor = color.trim().toLowerCase();
    if (normalizedColor.isEmpty) {
      return null;
    }

    for (final standardColor in _standardVehicleColors) {
      if (standardColor.toLowerCase() == normalizedColor) {
        return standardColor;
      }
    }

    return null;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();
    final isEditing = widget.vehicleId != null;

    setState(() {});
    final vehicle = await _controller.submit();

    if (!mounted) {
      return;
    }

    setState(() {});

    if (vehicle == null) {
      return;
    }

    ref.invalidate(garageControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? l10n.vehicleUpdated : l10n.vehicleAdded),
      ),
    );
    context.go('/garage');
  }
}

final class _GarageBrandField extends StatelessWidget {
  const _GarageBrandField({
    required this.controller,
    required this.focusNode,
    required this.brands,
    required this.isLoading,
    required this.onChanged,
    required this.onRetry,
    this.errorText,
  });

  static const _fieldColor = Color(0xFF20242D);
  static const _borderColor = Color(0xFF3B4252);
  static const _accentColor = Color(0xFFB8C3FF);
  static const _hintColor = Color(0xFF6F7482);

  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> brands;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback onRetry;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GarageDropdownLabel(label: l10n.brand),
        const SizedBox(height: 10),
        RawAutocomplete<String>(
          textEditingController: controller,
          focusNode: focusNode,
          displayStringForOption: (brand) => brand,
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.trim().toLowerCase();
            if (query.isEmpty) {
              return const Iterable<String>.empty();
            }

            return brands.where((brand) => brand.toLowerCase().contains(query));
          },
          onSelected: onChanged,
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  cursorColor: _accentColor,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Lada',
                    errorText: errorText,
                    hintStyle: const TextStyle(color: _hintColor),
                    suffixIcon: _suffixIcon(),
                    filled: true,
                    fillColor: _fieldColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _accentColor),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                  ),
                  onChanged: onChanged,
                  onSubmitted: (_) => onFieldSubmitted(),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                );
              },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: _fieldColor,
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 220,
                    maxWidth: 480,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final brand = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(brand),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Text(
                            brand,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget? _suffixIcon() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (errorText == 'Could not load brands') {
      return IconButton(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh, color: _accentColor),
      );
    }

    return const Icon(Icons.search, color: _accentColor);
  }
}

final class _GarageColorField extends StatelessWidget {
  const _GarageColorField({
    required this.controller,
    required this.focusNode,
    required this.colors,
    required this.onChanged,
  });

  static const _fieldColor = Color(0xFF20242D);
  static const _borderColor = Color(0xFF3B4252);
  static const _accentColor = Color(0xFFB8C3FF);
  static const _hintColor = Color(0xFF6F7482);

  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> colors;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GarageDropdownLabel(label: l10n.color),
        const SizedBox(height: 10),
        RawAutocomplete<String>(
          textEditingController: controller,
          focusNode: focusNode,
          displayStringForOption: (color) =>
              _localizedVehicleColor(l10n, color),
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.trim().toLowerCase();
            if (query.isEmpty) {
              return const Iterable<String>.empty();
            }

            return colors.where((color) {
              return color.toLowerCase().contains(query) ||
                  _localizedVehicleColor(
                    l10n,
                    color,
                  ).toLowerCase().contains(query);
            });
          },
          onSelected: (color) {
            controller.text = _localizedVehicleColor(l10n, color);
            onChanged(color);
          },
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  key: const ValueKey('vehicle_color_field'),
                  controller: textEditingController,
                  focusNode: focusNode,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  cursorColor: _accentColor,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: l10n.selectColor,
                    hintStyle: const TextStyle(color: _hintColor),
                    suffixIcon: const Icon(Icons.search, color: _accentColor),
                    filled: true,
                    fillColor: _fieldColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _accentColor),
                    ),
                  ),
                  onChanged: onChanged,
                  onSubmitted: (_) => onFieldSubmitted(),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                );
              },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: _fieldColor,
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 220,
                    maxWidth: 480,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final color = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(color),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Text(
                            _localizedVehicleColor(l10n, color),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _localizedVehicleColor(AppLocalizations l10n, String color) {
    return switch (color) {
      'White' => l10n.vehicleColorWhite,
      'Black' => l10n.vehicleColorBlack,
      'Silver' => l10n.vehicleColorSilver,
      'Grey' => l10n.vehicleColorGrey,
      'Red' => l10n.vehicleColorRed,
      'Blue' => l10n.vehicleColorBlue,
      'Green' => l10n.vehicleColorGreen,
      'Yellow' => l10n.vehicleColorYellow,
      'Orange' => l10n.vehicleColorOrange,
      'Brown' => l10n.vehicleColorBrown,
      'Beige' => l10n.vehicleColorBeige,
      'Gold' => l10n.vehicleColorGold,
      'Purple' => l10n.vehicleColorPurple,
      _ => color,
    };
  }
}

final class _GarageEngineTypeField extends StatelessWidget {
  const _GarageEngineTypeField({
    required this.selectedValue,
    required this.onChanged,
    this.errorText,
  });

  static const _fieldColor = Color(0xFF20242D);
  static const _borderColor = Color(0xFF3B4252);
  static const _accentColor = Color(0xFFB8C3FF);
  static const _hintColor = Color(0xFF6F7482);

  final String selectedValue;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final valueText = selectedValue.isEmpty
        ? l10n.selectEngineType
        : _localizedEngineType(l10n, selectedValue);
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GarageDropdownLabel(label: l10n.engineType),
        const SizedBox(height: 10),
        PopupMenuButton<String>(
          enabled: onChanged != null,
          color: _fieldColor,
          elevation: 8,
          onOpened: () => FocusScope.of(context).unfocus(),
          constraints: const BoxConstraints(minWidth: 220, maxWidth: 260),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: _borderColor),
          ),
          onSelected: onChanged,
          itemBuilder: (context) => [
            _engineItem(l10n, 'gasoline'),
            _engineItem(l10n, 'diesel'),
            _engineItem(l10n, 'hybrid'),
            _engineItem(l10n, 'electric'),
          ],
          child: InputDecorator(
            decoration: InputDecoration(
              errorText: errorText,
              filled: true,
              fillColor: _fieldColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : _borderColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _accentColor),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.error),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    valueText,
                    style: TextStyle(
                      color: selectedValue.isEmpty ? _hintColor : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _accentColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _engineItem(AppLocalizations l10n, String value) {
    return PopupMenuItem(
      value: value,
      child: Text(
        _localizedEngineType(l10n, value),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  String _localizedEngineType(AppLocalizations l10n, String value) {
    return switch (value) {
      'gasoline' => l10n.gasoline,
      'diesel' => l10n.diesel,
      'hybrid' => l10n.hybrid,
      'electric' => l10n.electric,
      _ => value,
    };
  }
}

String? _localizedVehicleError(AppLocalizations l10n, String? message) {
  if (message == null) return null;

  final yearMatch = RegExp(
    r'Enter a production year from 1900 to (\d+)',
  ).firstMatch(message);
  if (yearMatch != null) {
    return l10n.enterProductionYearRange(int.parse(yearMatch.group(1)!));
  }

  return switch (message) {
    'Check the vehicle details' => l10n.checkVehicleDetails,
    'Could not update the vehicle' => l10n.couldNotUpdateVehicle,
    'Could not save the vehicle' => l10n.couldNotSaveVehicle,
    'Enter a brand' => l10n.enterBrand,
    'Enter a model' => l10n.enterModel,
    'Enter a production year' => l10n.enterProductionYear,
    'Mileage cannot be negative' => l10n.mileageCannotBeNegative,
    'Enter current mileage' => l10n.enterCurrentMileage,
    'Select an engine type' => l10n.selectEngineType,
    'Enter either engine volume or power output' =>
      l10n.enterEngineSpecification,
    'Power output must be greater than zero' => l10n.powerOutputPositive,
    'Engine volume must be greater than zero' => l10n.engineVolumePositive,
    'Enter power output' => l10n.enterPowerOutput,
    'Enter engine volume' => l10n.enterEngineVolume,
    'VIN must contain exactly 17 characters' => l10n.vinLengthError,
    _ => message,
  };
}

final class _GarageTextField extends StatelessWidget {
  const _GarageTextField({
    required this.label,
    required this.hintText,
    required this.onChanged,
    required this.controller,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
  });

  static const _fieldColor = Color(0xFF20242D);
  static const _borderColor = Color(0xFF3B4252);
  static const _accentColor = Color(0xFFB8C3FF);
  static const _hintColor = Color(0xFF6F7482);

  final String label;
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GarageDropdownLabel(label: label),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          cursorColor: _accentColor,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            hintStyle: const TextStyle(color: _hintColor),
            filled: true,
            fillColor: _fieldColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _accentColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
        ),
      ],
    );
  }
}

final class _GarageDropdownLabel extends StatelessWidget {
  const _GarageDropdownLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFFB8C3FF),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }
}
