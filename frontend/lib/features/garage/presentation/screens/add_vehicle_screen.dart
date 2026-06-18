import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/garage/presentation/controllers/add_vehicle_controller.dart';
import 'package:frontend/features/garage/presentation/providers/garage_providers.dart';
import 'package:go_router/go_router.dart';

final class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

final class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  late final AddVehicleController _controller;

  static const _backgroundColor = Color(0xFF0D111A);
  static const _fieldColor = Color(0xFF20242D);
  static const _borderColor = Color(0xFF3B4252);
  static const _accentColor = Color(0xFFB8C3FF);
  static const _hintColor = Color(0xFF6F7482);

  @override
  void initState() {
    super.initState();
    _controller = ref.read(addVehicleControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final hasEngineType = state.engineType.isNotEmpty;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: _accentColor),
        title: const Text(
          'Car Specifications',
          style: TextStyle(color: _accentColor, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          onPressed: () => context.go('/garage'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GarageTextField(
                label: 'Brand',
                hintText: 'Lada',
                errorText: state.fieldErrors['brand'],
                textInputAction: TextInputAction.next,
                onChanged: (value) => _update(_controller.updateBrand, value),
              ),
              const SizedBox(height: 24),

              _GarageTextField(
                label: 'Model',
                hintText: '2106',
                errorText: state.fieldErrors['model'],
                textInputAction: TextInputAction.next,
                onChanged: (value) => _update(_controller.updateModel, value),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _GarageTextField(
                      label: 'Year',
                      hintText: '1998',
                      errorText: state.fieldErrors['year'],
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                      onChanged: (value) =>
                          _update(_controller.updateYear, value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _GarageTextField(
                      label: 'Current mileage',
                      hintText: '124580',
                      errorText: state.fieldErrors['currentMileageKm'],
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                      onChanged: (value) =>
                          _update(_controller.updateCurrentMileage, value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _GarageTextField(
                label: 'Color',
                hintText: 'blue',
                textInputAction: TextInputAction.next,
                onChanged: (value) => _update(_controller.updateColor, value),
              ),
              const SizedBox(height: 24),

              const _GarageDropdownLabel(label: 'Engine type'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                key: ValueKey(state.engineType),
                initialValue: state.engineType.isEmpty
                    ? null
                    : state.engineType,
                dropdownColor: _fieldColor,
                borderRadius: BorderRadius.circular(8),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _accentColor,
                ),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  errorText: state.fieldErrors['engineType'],
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
                  floatingLabelStyle: hasEngineType
                      ? const TextStyle(color: _accentColor)
                      : null,
                ),
                hint: const Text(
                  'Select engine type',
                  style: TextStyle(color: _hintColor),
                ),
                items: const [
                  DropdownMenuItem(value: 'gasoline', child: Text('gasoline')),
                  DropdownMenuItem(value: 'diesel', child: Text('diesel')),
                  DropdownMenuItem(value: 'hybrid', child: Text('hybrid')),
                  DropdownMenuItem(value: 'electric', child: Text('electric')),
                ],
                onChanged: state.isSubmitting
                    ? null
                    : (value) {
                        _update(_controller.updateEngineType, value ?? '');
                      },
              ),

              if (state.errorMessage != null) ...[
                const SizedBox(height: 24),
                Text(
                  state.errorMessage!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
                ),
              ],

              const SizedBox(height: 84),

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
                          child: CircularProgressIndicator(strokeWidth: 2),
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
                            const Text(
                              'Start new shaha!',
                              style: TextStyle(
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
    );
  }

  void _update(void Function(String value) update, String value) {
    setState(() {
      update(value);
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

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
    context.go('/garage');
  }
}

final class _GarageTextField extends StatelessWidget {
  const _GarageTextField({
    required this.label,
    required this.hintText,
    required this.onChanged,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
  });

  static const _fieldColor = Color(0xFF20242D);
  static const _borderColor = Color(0xFF3B4252);
  static const _accentColor = Color(0xFFB8C3FF);
  static const _hintColor = Color(0xFF6F7482);

  final String label;
  final String hintText;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GarageDropdownLabel(label: label),
        const SizedBox(height: 10),
        TextField(
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
          onChanged: onChanged,
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
