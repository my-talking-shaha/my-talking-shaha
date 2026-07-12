import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';
import 'package:frontend/features/history/presentation/colors.dart';
import 'package:frontend/features/history/presentation/utils/history_event_form_utils.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

part '../utils/add_history_event_actions.dart';
part '../widgets/add_history_event_widgets.dart';

typedef SaveHistoryEvent = Future<void> Function(HistoryEvent event);
typedef PickHistoryPhoto = Future<XFile?> Function();
typedef PickHistoryPhotos = Future<List<XFile>> Function();
typedef PersistHistoryPhoto = Future<String> Function({
  required String sourcePath,
  required String originalName,
  required String eventId,
});
typedef DeleteHistoryPhoto = Future<void> Function(String path);

const _defaultFuelTypes = ['92 octane', '95 octane', '98 octane', 'Diesel'];
const _defaultChargerTypes = [
  'AC charging',
  'DC fast charging',
  'Home charging',
  'Supercharger',
];

final class AddHistoryEventScreen extends StatefulWidget {
  const AddHistoryEventScreen({
    required this.vehicleId,
    required this.onSave,
    required this.persistPhoto,
    required this.deletePhoto,
    this.pickPhoto,
    this.pickPhotos,
    this.initialEvent,
    this.initialMileageKm = 0,
    this.initialType = HistoryEventType.fuel,
    this.initialOccurredAt,
    this.isElectricVehicle = false,
    super.key,
  });

  final String vehicleId;
  final SaveHistoryEvent onSave;
  final PersistHistoryPhoto persistPhoto;
  final DeleteHistoryPhoto deletePhoto;
  final PickHistoryPhoto? pickPhoto;
  final PickHistoryPhotos? pickPhotos;
  final HistoryEvent? initialEvent;
  final int initialMileageKm;
  final HistoryEventType initialType;
  final DateTime? initialOccurredAt;
  final bool isElectricVehicle;

  @override
  State<AddHistoryEventScreen> createState() => _AddHistoryEventScreenState();
}

final class _AddHistoryEventScreenState extends State<AddHistoryEventScreen> {
  final _formKey = GlobalKey<FormState>();

  late HistoryEventType _type;
  late DateTime _occurredAt;
  bool _isSaving = false;
  bool _isPickingPhoto = false;
  final List<XFile> _selectedPhotos = [];
  final List<String> _removedExistingPhotoUrls = [];
  List<String>? _existingPhotoUrls;

  final _imagePicker = ImagePicker();

  final _titleController = TextEditingController();
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

  void _update(VoidCallback change) => setState(change);

  bool get _isEditing => widget.initialEvent != null;

  int get _minimumMileageKm {
    final initialEvent = widget.initialEvent;
    if (initialEvent == null) {
      return widget.initialMileageKm;
    }

    return switch (initialEvent.details) {
      TripDetails(:final startKm) => startKm,
      _ => initialEvent.currentMileageKm,
    };
  }

  @override
  void initState() {
    super.initState();
    final initialEvent = widget.initialEvent;
    _type = initialEvent?.type ?? widget.initialType;
    _occurredAt =
        initialEvent?.occurredAt ?? widget.initialOccurredAt ?? DateTime.now();
    if (initialEvent != null) {
      _populateFromEvent(initialEvent);
    } else if (widget.initialMileageKm > 0) {
      _mileageController.text = widget.initialMileageKm.toString();
      _tripStartController.text = widget.initialMileageKm.toString();
    }
    if (initialEvent == null && widget.isElectricVehicle) {
      _fuelType = _defaultChargerTypes.first;
    }
    if (!kIsWeb &&
        widget.pickPhoto == null &&
        widget.pickPhotos == null &&
        Platform.isAndroid) {
      unawaited(_restoreLostPhoto());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? HistoryEventFormUtils.editTitleFor(
                  _type,
                  l10n: l10n,
                  isElectricVehicle: widget.isElectricVehicle,
                )
              : HistoryEventFormUtils.titleFor(
                  _type,
                  l10n: l10n,
                  isElectricVehicle: widget.isElectricVehicle,
                ),
        ),
      ),
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
              _SectionLabel(l10n.eventType),
              const SizedBox(height: AppSpacing.sm),
              _EventTypeSelector(
                selectedType: _type,
                enabled: !_isEditing,
                isElectricVehicle: widget.isElectricVehicle,
                onSelected: (type) {
                  if (type == _type) return;
                  setState(() => _type = type);
                  _formKey.currentState?.reset();
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              _FormCard(
                label: l10n.dateAndTime,
                child: _ReadOnlyValue(
                  icon: Icons.calendar_today_outlined,
                  value: HistoryEventFormUtils.formatDateTime(_occurredAt),
                  onTap: _selectOccurredAt,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _FormCard(
                label: l10n.title,
                child: TextFormField(
                  key: const ValueKey('event-title'),
                  controller: _titleController,
                  decoration: InputDecoration(hintText: l10n.enterEventTitle),
                  textInputAction: TextInputAction.next,
                  validator: (value) => HistoryEventFormUtils.validateRequired(
                    value,
                    label: l10n.title,
                    l10n: l10n,
                  ),
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
                    : Text(_isEditing ? l10n.saveChanges : l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
