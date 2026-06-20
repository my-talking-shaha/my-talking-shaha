import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/history/domain/event_detais.dart';
import 'package:frontend/features/history/domain/history_event.dart';
import 'package:frontend/features/history/domain/history_event_type.dart';
import 'package:frontend/features/history/presentation/utils/history_event_form_utils.dart';

typedef SaveHistoryEvent = Future<void> Function(HistoryEvent event);

final class AddHistoryEventScreen extends StatefulWidget {
  const AddHistoryEventScreen({
    required this.vehicleId,
    required this.onSave,
    this.initialMileageKm = 0,
    this.initialType = HistoryEventType.fuel,
    this.initialOccurredAt,
    super.key,
  });

  final String vehicleId;
  final SaveHistoryEvent onSave;
  final int initialMileageKm;
  final HistoryEventType initialType;
  final DateTime? initialOccurredAt;

  @override
  State<AddHistoryEventScreen> createState() => _AddHistoryEventScreenState();
}

final class _AddHistoryEventScreenState extends State<AddHistoryEventScreen> {
  final _formKey = GlobalKey<FormState>();

  late HistoryEventType _type;
  late DateTime _occurredAt;
  bool _isSaving = false;

  final _mileageController = TextEditingController();
  final _fuelLitersController = TextEditingController();
  final _fuelCostController = TextEditingController();
  final _maintenanceDescriptionController = TextEditingController();
  final _maintenanceCostController = TextEditingController();
  final _replacedPartsController = TextEditingController();
  final _tripStartController = TextEditingController();
  final _tripEndController = TextEditingController();
  final _tripRouteController = TextEditingController();
  final _tripDurationController = TextEditingController();

  String _fuelType = '95 octane';

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _occurredAt = widget.initialOccurredAt ?? DateTime.now();
    if (widget.initialMileageKm > 0) {
      _mileageController.text = widget.initialMileageKm.toString();
      _tripStartController.text = widget.initialMileageKm.toString();
    }
  }

  @override
  void dispose() {
    _mileageController.dispose();
    _fuelLitersController.dispose();
    _fuelCostController.dispose();
    _maintenanceDescriptionController.dispose();
    _maintenanceCostController.dispose();
    _replacedPartsController.dispose();
    _tripStartController.dispose();
    _tripEndController.dispose();
    _tripRouteController.dispose();
    _tripDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(HistoryEventFormUtils.titleFor(_type))),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.xxl,
            ),
            children: [
              const _SectionLabel('EVENT TYPE'),
              const SizedBox(height: AppSpacing.sm),
              _EventTypeSelector(
                selectedType: _type,
                onSelected: (type) {
                  if (type == _type) return;
                  setState(() => _type = type);
                  _formKey.currentState?.reset();
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              _FormCard(
                label: 'DATE AND TIME',
                child: _ReadOnlyValue(
                  icon: Icons.calendar_today_outlined,
                  value: HistoryEventFormUtils.formatDateTime(_occurredAt),
                  onTap: _selectOccurredAt,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...switch (_type) {
                HistoryEventType.fuel => _fuelFields(),
                HistoryEventType.maintenance => _maintenanceFields(),
                HistoryEventType.trip => _tripFields(),
              },
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _fuelFields() {
    return [
      _FormCard(
        label: 'CURRENT MILEAGE',
        child: _NumberField(
          key: const ValueKey('fuel-mileage'),
          controller: _mileageController,
          hintText: '124,500',
          suffixText: 'km',
          icon: Icons.speed_outlined,
          validator: (value) => HistoryEventFormUtils.validateMileage(
            value,
            minimumMileageKm: widget.initialMileageKm,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _FormCard(
        label: 'REFUELING DETAILS',
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _NumberField(
                    key: const ValueKey('fuel-liters'),
                    controller: _fuelLitersController,
                    hintText: '0',
                    suffixText: 'L',
                    labelText: 'AMOUNT',
                    validator: (value) =>
                        HistoryEventFormUtils.validatePositiveInt(
                          value,
                          label: 'Amount',
                        ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _NumberField(
                    key: const ValueKey('fuel-cost'),
                    controller: _fuelCostController,
                    hintText: '0',
                    suffixText: '₽',
                    labelText: 'COST',
                    validator: (value) =>
                        HistoryEventFormUtils.validatePositiveInt(
                          value,
                          label: 'Cost',
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              key: const ValueKey('fuel-type'),
              initialValue: _fuelType,
              decoration: const InputDecoration(labelText: 'FUEL TYPE'),
              items: const [
                DropdownMenuItem(value: '92 octane', child: Text('92 octane')),
                DropdownMenuItem(value: '95 octane', child: Text('95 octane')),
                DropdownMenuItem(value: '98 octane', child: Text('98 octane')),
                DropdownMenuItem(value: 'Diesel', child: Text('Diesel')),
              ],
              onChanged: (value) {
                if (value != null) _fuelType = value;
              },
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      const _InformationCard(
        message:
            'Mileage data will be used to update service intervals and forecasts.',
      ),
    ];
  }

  List<Widget> _maintenanceFields() {
    return [
      _FormCard(
        label: 'CURRENT MILEAGE',
        child: _NumberField(
          key: const ValueKey('maintenance-mileage'),
          controller: _mileageController,
          hintText: '124,500',
          suffixText: 'km',
          icon: Icons.speed_outlined,
          validator: (value) => HistoryEventFormUtils.validateMileage(
            value,
            minimumMileageKm: widget.initialMileageKm,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _FormCard(
        label: 'WORK DESCRIPTION',
        child: TextFormField(
          key: const ValueKey('maintenance-description'),
          controller: _maintenanceDescriptionController,
          minLines: 4,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Describe the work performed...',
            alignLabelWithHint: true,
          ),
          validator: (value) => HistoryEventFormUtils.validateRequired(
            value,
            label: 'Description',
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _FormCard(
        label: 'COST',
        optional: true,
        child: _NumberField(
          key: const ValueKey('maintenance-cost'),
          controller: _maintenanceCostController,
          hintText: '0',
          suffixText: '₽',
          icon: Icons.payments_outlined,
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _FormCard(
        label: 'REPLACED PARTS',
        optional: true,
        child: TextFormField(
          key: const ValueKey('maintenance-parts'),
          controller: _replacedPartsController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Enter parts separated by commas...',
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      const _PhotoCard(),
    ];
  }

  List<Widget> _tripFields() {
    return [
      _FormCard(
        label: 'MILEAGE',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _NumberField(
                key: const ValueKey('trip-start'),
                controller: _tripStartController,
                hintText: '124,500',
                suffixText: 'km',
                labelText: 'START',
                validator: (value) => HistoryEventFormUtils.validateTripStart(
                  value,
                  minimumMileageKm: widget.initialMileageKm,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _NumberField(
                key: const ValueKey('trip-end'),
                controller: _tripEndController,
                hintText: '124,650',
                suffixText: 'km',
                labelText: 'END',
                validator: (value) => HistoryEventFormUtils.validateTripEnd(
                  value,
                  startMileage: _tripStartController.text,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _FormCard(
        label: 'ROUTE',
        optional: true,
        child: TextFormField(
          key: const ValueKey('trip-route'),
          controller: _tripRouteController,
          decoration: const InputDecoration(
            hintText: 'London — Oxford — London',
            prefixIcon: Icon(Icons.map_outlined),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _FormCard(
        label: 'TRIP DETAILS',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _NumberField(
                key: const ValueKey('trip-duration'),
                controller: _tripDurationController,
                hintText: '90',
                suffixText: 'min',
                labelText: 'DURATION',
                icon: Icons.timer_outlined,
                validator: (value) => HistoryEventFormUtils.validatePositiveInt(
                  value,
                  label: 'Duration',
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final event = _createEvent();
      await widget.onSave(event);
      if (mounted) Navigator.of(context).pop(event);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the event. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _selectOccurredAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (time == null) return;

    setState(() {
      _occurredAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  HistoryEvent _createEvent() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;

    return switch (_type) {
      HistoryEventType.fuel => HistoryEvent(
        id: 'local-$timestamp',
        carId: widget.vehicleId,
        type: _type,
        occurredAt: _occurredAt,
        title: 'Refueling · $_fuelType',
        currentMileageKm: int.parse(_mileageController.text),
        details: FuelDetails(
          cost: int.parse(_fuelCostController.text),
          liters: int.parse(_fuelLitersController.text),
          fuelType: _fuelType,
        ),
      ),
      HistoryEventType.maintenance => HistoryEvent(
        id: 'local-$timestamp',
        carId: widget.vehicleId,
        type: _type,
        occurredAt: _occurredAt,
        title: 'Maintenance',
        currentMileageKm: int.parse(_mileageController.text),
        details: MaintenanceDetails(
          description: _maintenanceDescriptionController.text.trim(),
          cost: int.tryParse(_maintenanceCostController.text),
          replacedParts: HistoryEventFormUtils.parseCommaSeparated(
            _replacedPartsController.text,
          ),
        ),
      ),
      HistoryEventType.trip => HistoryEvent(
        id: 'local-$timestamp',
        carId: widget.vehicleId,
        type: _type,
        occurredAt: _occurredAt,
        title: 'Trip',
        currentMileageKm: int.parse(_tripEndController.text),
        details: TripDetails(
          startKm: int.parse(_tripStartController.text),
          endKm: int.parse(_tripEndController.text),
          route: HistoryEventFormUtils.trimToNull(_tripRouteController.text),
          duration: Duration(minutes: int.parse(_tripDurationController.text)),
        ),
      ),
    };
  }
}

final class _EventTypeSelector extends StatelessWidget {
  const _EventTypeSelector({
    required this.selectedType,
    required this.onSelected,
  });

  final HistoryEventType selectedType;
  final ValueChanged<HistoryEventType> onSelected;

  @override
  Widget build(BuildContext context) {
    const options = [
      (HistoryEventType.fuel, 'Fuel', 'assets/icons/events/gas.svg'),
      (
        HistoryEventType.maintenance,
        'Maintenance',
        'assets/icons/events/spanner.svg',
      ),
      (HistoryEventType.trip, 'Trip', 'assets/icons/events/trip.svg'),
    ];

    return Container(
      height: 58,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: const BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: AppRadius.card,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: AnimatedAlign(
              key: const ValueKey('event-type-selection'),
              alignment: switch (selectedType) {
                HistoryEventType.fuel => Alignment.centerLeft,
                HistoryEventType.maintenance => Alignment.center,
                HistoryEventType.trip => Alignment.centerRight,
              },
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              child: FractionallySizedBox(
                widthFactor: 1 / options.length,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primaryPressed.withValues(alpha: 0.45),
                    borderRadius: AppRadius.input,
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final (type, label, asset) in options)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: type == selectedType,
                    label: label,
                    child: InkWell(
                      key: ValueKey('event-type-${type.name}'),
                      onTap: () => onSelected(type),
                      borderRadius: AppRadius.input,
                      child: Center(
                        child: SvgPicture.asset(
                          asset,
                          width: 22,
                          height: 22,
                          colorFilter: ColorFilter.mode(
                            type == selectedType
                                ? AppColors.primaryLight
                                : AppColors.textSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.label,
    required this.child,
    this.optional = false,
  });

  final String label;
  final Widget child;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _SectionLabel(label)),
              if (optional)
                Text('optional', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

final class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.labelMedium?.copyWith(fontSize: 10, letterSpacing: 0.65),
    );
  }
}

final class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.hintText,
    this.suffixText,
    this.labelText,
    this.icon,
    this.validator,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final String? suffixText;
  final String? labelText;
  final IconData? icon;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: icon == null ? null : Icon(icon),
        suffixText: suffixText,
      ),
      validator: validator,
    );
  }
}

final class _ReadOnlyValue extends StatelessWidget {
  const _ReadOnlyValue({
    required this.icon,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundDark,
      borderRadius: AppRadius.input,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.input,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, size: 17, color: AppColors.primaryLight),
              const SizedBox(width: AppSpacing.sm),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

final class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        border: Border.all(
          color: AppColors.primaryPressed.withValues(alpha: 0.4),
        ),
        borderRadius: AppRadius.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.primaryLight,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

final class _PhotoCard extends StatelessWidget {
  const _PhotoCard();

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      label: 'PART PHOTO',
      optional: true,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add_circle_outline, size: 18),
        label: const Text('Add photo from gallery'),
      ),
    );
  }
}
