import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/core/ui/native_ui.dart';
import 'package:frontend/features/garage/di/garage_providers.dart';
import 'package:frontend/features/garage/presentation/controllers/add_vehicle_controller.dart';
import 'package:frontend/features/garage/presentation/controllers/power_output_unit_controller.dart';
import 'package:frontend/features/garage/presentation/utils/garage_form_utils.dart';
import 'package:frontend/features/garage/presentation/widgets/common/garage_text_field.dart';
import 'package:frontend/features/garage/presentation/widgets/form/garage_brand_field.dart';
import 'package:frontend/features/garage/presentation/widgets/form/garage_color_field.dart';
import 'package:frontend/features/garage/presentation/widgets/form/garage_engine_type_field.dart';
import 'package:frontend/features/garage/presentation/widgets/form/garage_power_output_field.dart';
import 'package:frontend/features/garage/presentation/widgets/form/garage_submit_button.dart';
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

      showNativeMessage(context, AppLocalizations.of(context).vehicleNotFound);
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
    final canonicalColor = canonicalGarageVehicleColor(state.color);
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
    final powerOutputUnit = ref.watch(powerOutputUnitControllerProvider);
    powerOutputUnit.whenData(_schedulePowerOutputUnitSync);
    ref.listen(powerOutputUnitControllerProvider, (_, next) {
      next.whenData(_schedulePowerOutputUnitSync);
    });
    final hasEngineType = state.engineType.isNotEmpty;
    final isEditing = widget.vehicleId != null;

    return Scaffold(
      backgroundColor: context.appColors.formBackground,
      appBar: AppBar(
        backgroundColor: context.appColors.formBackground,
        elevation: 0,
        titleSpacing: 0,
        iconTheme: IconThemeData(color: context.appColors.primaryLight),
        title: Text(
          isEditing ? l10n.editCar : l10n.carSpecifications,
          style: TextStyle(
            color: context.appColors.primaryLight,
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
              ? const Center(child: NativeActivityIndicator())
              : SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GarageBrandField(
                        controller: _brandController,
                        focusNode: _brandFocusNode,
                        brands: garageBrandOptions(
                          brands: vehicleBrands.whenOrNull(
                            data: (brands) => brands,
                          ),
                          selectedBrand: _controller.state.brand,
                        ),
                        isLoading: vehicleBrands.isLoading,
                        errorText: garageBrandErrorText(
                          l10n,
                          vehicleBrands,
                          state,
                        ),
                        onRetry: () => ref.invalidate(vehicleBrandsProvider),
                        onChanged: (value) =>
                            _update(_controller.updateBrand, value),
                      ),
                      const SizedBox(height: 24),
                      GarageTextField(
                        label: l10n.model,
                        hintText: '2106',
                        controller: _modelController,
                        errorText: localizedGarageVehicleError(
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
                            child: GarageTextField(
                              label: l10n.year,
                              hintText: '1998',
                              controller: _yearController,
                              errorText: localizedGarageVehicleError(
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
                            child: GarageTextField(
                              label: l10n.currentMileage,
                              hintText: '124580',
                              controller: _mileageController,
                              errorText: localizedGarageVehicleError(
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
                      GarageColorField(
                        controller: _colorController,
                        focusNode: _colorFocusNode,
                        colors: standardGarageVehicleColors,
                        onChanged: (value) =>
                            _update(_controller.updateColor, value),
                      ),
                      const SizedBox(height: 24),
                      GarageTextField(
                        label: l10n.vinOptional,
                        hintText: 'XTA21060012345678',
                        controller: _vinController,
                        errorText: localizedGarageVehicleError(
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
                      GarageEngineTypeField(
                        selectedValue: state.engineType,
                        errorText: localizedGarageVehicleError(
                          l10n,
                          state.fieldErrors['engineType'],
                        ),
                        onChanged: state.isSubmitting
                            ? null
                            : _updateEngineType,
                      ),
                      if (hasEngineType) ...[
                        const SizedBox(height: 24),
                        if (state.engineType == 'electric')
                          GaragePowerOutputField(
                            controller: _engineSpecificationController,
                            selectedUnit: garagePowerOutputUnit(
                              powerOutputUnit,
                              _controller.state.powerOutputUnit,
                            ),
                            errorText: localizedGarageVehicleError(
                              l10n,
                              state.fieldErrors['engineSpecification'],
                            ),
                            onUnitChanged: _updatePowerOutputUnit,
                            onChanged: (value) => _update(
                              _controller.updateEngineSpecification,
                              value,
                            ),
                          )
                        else
                          GarageTextField(
                            label: l10n.engineVolumeL,
                            hintText: '1.6',
                            controller: _engineSpecificationController,
                            errorText: localizedGarageVehicleError(
                              l10n,
                              state.fieldErrors['engineSpecification'],
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
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
                          localizedGarageVehicleError(
                            l10n,
                            state.errorMessage,
                          )!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: context.appColors.error),
                        ),
                      ],
                      const SizedBox(height: 40),
                      GarageSubmitButton(
                        label: isEditing
                            ? l10n.saveChanges
                            : l10n.startNewShaha,
                        isSubmitting: state.isSubmitting,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
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

  void _syncPowerOutputUnit(PowerOutputUnit unit) {
    if (_controller.state.powerOutputUnit == unit.value) {
      return;
    }

    setState(() {
      _controller.updatePowerOutputUnit(unit.value);
      _engineSpecificationController.text =
          _controller.state.engineSpecification;
    });
  }

  void _schedulePowerOutputUnitSync(PowerOutputUnit unit) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncPowerOutputUnit(unit);
      }
    });
  }

  void _updatePowerOutputUnit(PowerOutputUnit unit) {
    setState(() {
      _controller.updatePowerOutputUnit(unit.value);
      _engineSpecificationController.text =
          _controller.state.engineSpecification;
    });
    unawaited(
      ref.read(powerOutputUnitControllerProvider.notifier).setUnit(unit),
    );
  }

  void _updateEngineType(String value) {
    _dismissKeyboard();
    setState(() {
      _controller.updateEngineType(value);
      _engineSpecificationController.text =
          _controller.state.engineSpecification;
    });
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
    showNativeMessage(
      context,
      isEditing ? l10n.vehicleUpdated : l10n.vehicleAdded,
    );
    context.go('/garage');
  }
}
