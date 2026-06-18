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
      appBar: AppBar(
        title: const Text(
          'Car Specifications',
          style: TextStyle(color: Color(0xFFB8C3FF)),
        ),
        leading: IconButton(
          onPressed: () => context.go('/garage'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              _GarageTextField(
                label: 'Brand',
                hintText: 'Lada',
                errorText: state.fieldErrors['brand'],
                textInputAction: TextInputAction.next,
                onChanged: (value) => _update(_controller.updateBrand, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              _GarageTextField(
                label: 'Model',
                hintText: '2106',
                errorText: state.fieldErrors['model'],
                textInputAction: TextInputAction.next,
                onChanged: (value) => _update(_controller.updateModel, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              _GarageTextField(
                label: 'Year',
                hintText: '1998',
                errorText: state.fieldErrors['year'],
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
                onChanged: (value) => _update(_controller.updateYear, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              _GarageTextField(
                label: 'Color',
                hintText: 'blue',
                textInputAction: TextInputAction.next,
                onChanged: (value) => _update(_controller.updateColor, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              _GarageTextField(
                label: 'Current mileage',
                hintText: '124580',
                errorText: state.fieldErrors['currentMileageKm'],
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.done,
                onChanged: (value) =>
                    _update(_controller.updateCurrentMileage, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<String>(
                key: ValueKey(state.engineType),
                initialValue: state.engineType.isEmpty
                    ? null
                    : state.engineType,
                decoration: InputDecoration(
                  labelText: 'Engine type',
                  errorText: state.fieldErrors['engineType'],
                  floatingLabelStyle: hasEngineType
                      ? const TextStyle(color: Color(0xFFB8C3FF))
                      : null,
                ),
                hint: const Text('Select engine type'),
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
                const SizedBox(height: AppSpacing.lg),
                Text(
                  state.errorMessage!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
                            const Text('Start new shaha!'),
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

  final String label;
  final String hintText;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: errorText,
        floatingLabelStyle: const TextStyle(color: Color(0xFFB8C3FF)),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      onChanged: onChanged,
    );
  }
}
