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
import 'package:frontend/features/history/presentation/utils/history_event_form_utils.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

part 'add_history_event_widgets.dart';

typedef SaveHistoryEvent = Future<void> Function(HistoryEvent event);
typedef PickHistoryPhoto = Future<XFile?> Function();
typedef PickHistoryPhotos = Future<List<XFile>> Function();
typedef PersistHistoryPhoto =
    Future<String> Function({
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
                    : Text(_isEditing ? 'Save changes' : l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _fuelFields() {
    final l10n = AppLocalizations.of(context);
    final fuelTypeItems = widget.isElectricVehicle
        ? [
            if (!_defaultChargerTypes.contains(_fuelType)) _fuelType,
            ..._defaultChargerTypes,
          ]
        : [
            if (!_defaultFuelTypes.contains(_fuelType)) _fuelType,
            ..._defaultFuelTypes,
          ];

    return [
      _FormCard(
        label: l10n.currentMileageLabel,
        child: _NumberField(
          key: const ValueKey('fuel-mileage'),
          controller: _mileageController,
          hintText: '124,500',
          suffixText: 'km',
          icon: Icons.speed_outlined,
          validator: (value) => HistoryEventFormUtils.validateMileage(
            value,
            minimumMileageKm: _minimumMileageKm,
            l10n: l10n,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _FormCard(
        label: widget.isElectricVehicle
            ? l10n.rechargeDetails
            : l10n.refuelingDetails,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _LabeledField(
                    label: widget.isElectricVehicle ? l10n.energy : l10n.amount,
                    child: _NumberField(
                      key: const ValueKey('fuel-liters'),
                      controller: _fuelLitersController,
                      hintText: '0',
                      suffixText: widget.isElectricVehicle ? 'kWh' : 'L',
                      allowDecimal: true,
                      validator: (value) => widget.isElectricVehicle
                          ? HistoryEventFormUtils.validateEnergyKwh(
                              value,
                              l10n: l10n,
                            )
                          : HistoryEventFormUtils.validateFuelLiters(
                              value,
                              l10n: l10n,
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _LabeledField(
                    label: l10n.cost,
                    child: _NumberField(
                      key: const ValueKey('fuel-cost'),
                      controller: _fuelCostController,
                      hintText: '0',
                      suffixText: '₽',
                      validator: (value) =>
                          HistoryEventFormUtils.validateStoredCost(
                            value,
                            l10n: l10n,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _LabeledField(
              label: widget.isElectricVehicle
                  ? l10n.chargerType
                  : l10n.fuelType,
              child: DropdownButtonFormField<String>(
                key: const ValueKey('fuel-type'),
                initialValue: _fuelType,
                decoration: const InputDecoration(),
                items: [
                  for (final value in fuelTypeItems)
                    DropdownMenuItem(value: value, child: Text(value)),
                ],
                onChanged: (value) {
                  if (value != null) _fuelType = value;
                },
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _InformationCard(message: l10n.mileageForecastInfo),
    ];
  }

  List<Widget> _maintenanceFields() {
    return [
      _FormCard(
        label: AppLocalizations.of(context).currentMileageLabel,
        child: _NumberField(
          key: const ValueKey('maintenance-mileage'),
          controller: _mileageController,
          hintText: '124,500',
          suffixText: 'km',
          icon: Icons.speed_outlined,
          validator: (value) => HistoryEventFormUtils.validateMileage(
            value,
            minimumMileageKm: _minimumMileageKm,
            l10n: AppLocalizations.of(context),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _FormCard(
        label: AppLocalizations.of(context).workDescription,
        child: TextFormField(
          key: const ValueKey('maintenance-description'),
          controller: _maintenanceDescriptionController,
          minLines: 4,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).describeWorkPerformed,
            alignLabelWithHint: true,
          ),
          validator: (value) => HistoryEventFormUtils.validateRequired(
            value,
            label: AppLocalizations.of(context).workDescription,
            l10n: AppLocalizations.of(context),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _FormCard(
        label: AppLocalizations.of(context).cost,
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
        label: AppLocalizations.of(context).replacedParts,
        optional: true,
        child: TextFormField(
          key: const ValueKey('maintenance-parts'),
          controller: _replacedPartsController,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).enterPartsSeparated,
          ),
        ),
      ),
      if (!kIsWeb) ...[
        const SizedBox(height: AppSpacing.md),
        _PhotoCard(
          existingPhotoUrls: _existingPhotoUrls ?? const [],
          photos: _selectedPhotos,
          isPicking: _isPickingPhoto,
          onPick: _pickPhotos,
          onRemove: _removePhoto,
          onRemoveExisting: _removeExistingPhoto,
        ),
      ],
    ];
  }

  List<Widget> _tripFields() {
    return [
      _FormCard(
        label: AppLocalizations.of(context).mileage,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _LabeledField(
                label: AppLocalizations.of(context).start,
                child: _NumberField(
                  key: const ValueKey('trip-start'),
                  controller: _tripStartController,
                  hintText: '124,500',
                  suffixText: 'km',
                  validator: (value) => HistoryEventFormUtils.validateTripStart(
                    value,
                    minimumMileageKm: _minimumMileageKm,
                    l10n: AppLocalizations.of(context),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _LabeledField(
                label: AppLocalizations.of(context).end,
                child: _NumberField(
                  key: const ValueKey('trip-end'),
                  controller: _tripEndController,
                  hintText: '124,650',
                  suffixText: 'km',
                  validator: (value) => HistoryEventFormUtils.validateTripEnd(
                    value,
                    startMileage: _tripStartController.text,
                    l10n: AppLocalizations.of(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _FormCard(
        label: AppLocalizations.of(context).route,
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
        label: AppLocalizations.of(context).duration,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _NumberField(
                key: const ValueKey('trip-duration'),
                controller: _tripDurationController,
                hintText: '90',
                suffixText: 'min',
                icon: Icons.timer_outlined,
                validator: (value) => HistoryEventFormUtils.validatePositiveInt(
                  value,
                  label: AppLocalizations.of(context).duration,
                  l10n: AppLocalizations.of(context),
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
    final persistedPhotoPaths = <String>[];
    try {
      final eventId =
          widget.initialEvent?.id ??
          'local-${DateTime.now().microsecondsSinceEpoch}';
      final eventWithoutPhotos = _createEvent(
        id: eventId,
        photoPaths: const [],
      );
      final photoCacheKey = _photoCacheKey(eventWithoutPhotos);
      final photos = _type == HistoryEventType.maintenance
          ? List<XFile>.of(_selectedPhotos)
          : const <XFile>[];
      for (final photo in photos) {
        persistedPhotoPaths.add(
          await widget.persistPhoto(
            sourcePath: photo.path,
            originalName: photo.name,
            eventId: photoCacheKey,
          ),
        );
      }

      final event = _createEvent(id: eventId, photoPaths: persistedPhotoPaths);
      await widget.onSave(event);
      await _deleteRemovedExistingPhotos();
      if (mounted) Navigator.of(context).pop(event);
    } catch (_) {
      for (final photoPath in persistedPhotoPaths) {
        try {
          await widget.deletePhoto(photoPath);
        } catch (_) {
          // The original save error is more useful to the user.
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).couldNotSaveEvent)),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _populateFromEvent(HistoryEvent event) {
    _titleController.text = event.title;

    switch (event.details) {
      case FuelDetails(:final liters, :final cost, :final fuelType):
        _mileageController.text = event.currentMileageKm.toString();
        _fuelLitersController.text = liters.toString();
        _fuelCostController.text = cost.toString();
        _fuelType = fuelType;
      case MaintenanceDetails(
        :final description,
        :final cost,
        :final replacedParts,
        :final photoUrls,
      ):
        _mileageController.text = event.currentMileageKm.toString();
        _maintenanceDescriptionController.text = description;
        _maintenanceCostController.text = cost?.toString() ?? '';
        _replacedPartsController.text = replacedParts?.join(', ') ?? '';
        _existingPhotoUrls = photoUrls
            ?.where((url) => url.trim().isNotEmpty)
            .toList(growable: false);
      case TripDetails(
        :final startKm,
        :final endKm,
        :final route,
        :final duration,
      ):
        _tripStartController.text = startKm.toString();
        _tripEndController.text = endKm.toString();
        _tripRouteController.text = route ?? '';
        _tripDurationController.text = duration.inMinutes.toString();
    }
  }

  Future<void> _pickPhotos() async {
    if (_isPickingPhoto) return;
    final l10n = AppLocalizations.of(context);
    final accessError = l10n.couldNotAccessPhotoLibrary;
    final selectError = l10n.couldNotSelectPhoto;
    setState(() => _isPickingPhoto = true);

    try {
      final photos = await _selectPhotosFromGallery();
      if (photos.isNotEmpty && mounted) {
        setState(() => _selectedPhotos.addAll(photos));
      }
    } on PlatformException {
      _showPhotoError(accessError);
    } catch (_) {
      _showPhotoError(selectError);
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  Future<List<XFile>> _selectPhotosFromGallery() async {
    if (widget.pickPhotos != null) {
      return widget.pickPhotos!();
    }

    if (widget.pickPhoto != null) {
      final photo = await widget.pickPhoto!();
      return photo == null ? const [] : [photo];
    }

    return _imagePicker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1600,
      requestFullMetadata: false,
    );
  }

  Future<void> _restoreLostPhoto() async {
    final restoreError = AppLocalizations.of(context).couldNotRestorePhoto;
    try {
      final response = await _imagePicker.retrieveLostData();
      final files = response.files;
      if (files != null && files.isNotEmpty && mounted) {
        setState(() => _selectedPhotos.addAll(files));
      } else if (response.exception != null) {
        _showPhotoError(restoreError);
      }
    } on PlatformException {
      _showPhotoError(restoreError);
    }
  }

  void _showPhotoError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }

  void _removePhoto(XFile photo) {
    setState(() => _selectedPhotos.remove(photo));
  }

  void _removeExistingPhoto(String url) {
    setState(() {
      _existingPhotoUrls = (_existingPhotoUrls ?? const <String>[])
          .where((item) => item != url)
          .toList(growable: false);
      _removedExistingPhotoUrls.add(url);
    });
  }

  Future<void> _deleteRemovedExistingPhotos() async {
    for (final url in _removedExistingPhotoUrls) {
      final path = url.trim();
      if (path.isEmpty || _isRemoteUrl(path)) continue;
      try {
        await widget.deletePhoto(path);
      } catch (_) {
        // The event was saved; stale local files can be retried on event delete.
      }
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

  HistoryEvent _createEvent({
    required String id,
    required List<String> photoPaths,
  }) {
    return switch (_type) {
      HistoryEventType.fuel => HistoryEvent(
        id: id,
        carId: widget.vehicleId,
        type: _type,
        occurredAt: _occurredAt,
        title: _titleController.text.trim(),
        currentMileageKm: int.parse(_mileageController.text),
        details: FuelDetails(
          cost: int.parse(_fuelCostController.text),
          liters: HistoryEventFormUtils.parseDecimal(
            _fuelLitersController.text,
          )!,
          fuelType: _fuelType,
          isRecharge: widget.isElectricVehicle,
        ),
      ),
      HistoryEventType.maintenance => HistoryEvent(
        id: id,
        carId: widget.vehicleId,
        type: _type,
        occurredAt: _occurredAt,
        title: _titleController.text.trim(),
        currentMileageKm: int.parse(_mileageController.text),
        details: MaintenanceDetails(
          description: _maintenanceDescriptionController.text.trim(),
          cost: int.tryParse(_maintenanceCostController.text),
          replacedParts: HistoryEventFormUtils.parseCommaSeparated(
            _replacedPartsController.text,
          ),
          photoUrls: _maintenancePhotoUrls(photoPaths),
        ),
      ),
      HistoryEventType.trip => HistoryEvent(
        id: id,
        carId: widget.vehicleId,
        type: _type,
        occurredAt: _occurredAt,
        title: _titleController.text.trim(),
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

  List<String>? _maintenancePhotoUrls(List<String> photoPaths) {
    final urls = [
      ...?_existingPhotoUrls,
      ...photoPaths,
    ].where((url) => url.trim().isNotEmpty).toList(growable: false);

    return urls.isEmpty ? null : List.unmodifiable(urls);
  }

  String _photoCacheKey(HistoryEvent event) {
    return [
      event.carId,
      event.type.name,
      event.occurredAt.toUtc().toIso8601String(),
      event.title.trim().toLowerCase(),
      event.currentMileageKm,
    ].join('|');
  }

  bool _isRemoteUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }
}
