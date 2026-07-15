part of '../screens/add_history_event_screen.dart';

extension _AddHistoryEventActions on _AddHistoryEventScreenState {
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
              child: NativeDropdownFormField<String>(
                key: const ValueKey('fuel-type'),
                value: _fuelType,
                title: widget.isElectricVehicle
                    ? l10n.chargerType
                    : l10n.fuelType,
                iconColor: context.appColors.primaryLight,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.appColors.textPrimary,
                ),
                decoration: const InputDecoration(),
                items: [
                  for (final value in fuelTypeItems)
                    NativePickerItem(value: value, label: value),
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

  List<Widget> _serviceFields() {
    return [
      _ServiceTypeSelector(
        selectedType: _type,
        enabled: !_isEditing,
        onSelected: (type) {
          if (type == _type) return;
          _update(() => _type = type);
          _formKey.currentState?.reset();
        },
      ),
      const SizedBox(height: AppSpacing.md),
      _titleField(
        label: _type == HistoryEventType.part
            ? _partLabel()
            : AppLocalizations.of(context).title,
        hintText: _type == HistoryEventType.part
            ? _partNameHint()
            : AppLocalizations.of(context).enterEventTitle,
      ),
      const SizedBox(height: AppSpacing.md),
      ...switch (_type) {
        HistoryEventType.part => _partFields(),
        _ => _maintenanceFields(
          eventMileageLabel: _serviceMileageLabel(),
          eventMileageHint: '120,000',
        ),
      },
    ];
  }

  Widget _titleField({String? label, String? hintText}) {
    final l10n = AppLocalizations.of(context);
    return _FormCard(
      label: label ?? l10n.title,
      child: TextFormField(
        key: const ValueKey('event-title'),
        controller: _titleController,
        decoration: InputDecoration(hintText: hintText ?? l10n.enterEventTitle),
        textInputAction: TextInputAction.next,
        validator: (value) => HistoryEventFormUtils.validateRequired(
          value,
          label: label ?? l10n.title,
          l10n: l10n,
        ),
      ),
    );
  }

  List<Widget> _maintenanceFields({
    bool includeReplacedParts = true,
    required String eventMileageLabel,
    required String eventMileageHint,
  }) {
    final l10n = AppLocalizations.of(context);

    return [
      _FormCard(
        label: l10n.currentMileageLabel,
        child: _NumberField(
          key: const ValueKey('service-current-mileage'),
          controller: _currentMileageController,
          hintText: '124,500',
          suffixText: 'km',
          icon: Icons.speed_outlined,
          validator: (value) => _validateCurrentServiceMileage(value),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _FormCard(
        label: eventMileageLabel,
        child: _NumberField(
          key: const ValueKey('service-event-mileage'),
          controller: _mileageController,
          hintText: eventMileageHint,
          suffixText: 'km',
          icon: Icons.speed_outlined,
          validator: (value) => HistoryEventFormUtils.validateMileage(
            value,
            minimumMileageKm: 0,
            allowZero: true,
            l10n: l10n,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _FormCard(
        label: l10n.workDescription,
        optional: _type == HistoryEventType.part,
        child: TextFormField(
          key: const ValueKey('maintenance-description'),
          controller: _maintenanceDescriptionController,
          minLines: 4,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: _type == HistoryEventType.part
                ? _partDescriptionHint()
                : l10n.describeWorkPerformed,
            alignLabelWithHint: true,
          ),
          validator: _type == HistoryEventType.part
              ? null
              : (value) => HistoryEventFormUtils.validateRequired(
                  value,
                  label: l10n.workDescription,
                  l10n: l10n,
                ),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _FormCard(
        label: l10n.cost,
        optional: true,
        child: _NumberField(
          key: const ValueKey('maintenance-cost'),
          controller: _maintenanceCostController,
          hintText: '0',
          suffixText: '₽',
          icon: Icons.payments_outlined,
        ),
      ),
      if (includeReplacedParts) ...[
        const SizedBox(height: AppSpacing.md),
        _FormCard(
          label: l10n.replacedParts,
          optional: true,
          child: TextFormField(
            key: const ValueKey('maintenance-parts'),
            controller: _replacedPartsController,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(hintText: l10n.enterPartsSeparated),
          ),
        ),
      ],
      if (!kIsWeb &&
          (!_isEditing || (_existingPhotoUrls?.isNotEmpty ?? false))) ...[
        const SizedBox(height: AppSpacing.md),
        _PhotoCard(
          existingPhotoUrls: _existingPhotoUrls ?? const [],
          photos: _selectedPhotos,
          isPicking: _isPickingPhoto,
          readOnly: _isEditing,
          onPick: _pickPhotos,
          onRemove: _removePhoto,
          onRemoveExisting: _removeExistingPhoto,
        ),
      ],
    ];
  }

  List<Widget> _partFields() => _maintenanceFields(
    includeReplacedParts: false,
    eventMileageLabel: _installedMileageLabel(),
    eventMileageHint: '80,000',
  );

  String? _validateCurrentServiceMileage(String? value) {
    final l10n = AppLocalizations.of(context);
    final positiveError = HistoryEventFormUtils.validateMileage(
      value,
      minimumMileageKm: _minimumMileageKm,
      allowZero: _minimumMileageKm == 0,
      l10n: l10n,
    );
    if (positiveError != null) return positiveError;

    final current = int.tryParse(value ?? '');
    final eventMileage = int.tryParse(_mileageController.text);
    if (current != null && eventMileage != null && current < eventMileage) {
      return _currentMileageBeforeEventError();
    }
    return null;
  }

  String _partLabel() {
    return _serviceModePartLabel(context).toUpperCase();
  }

  String _partNameHint() {
    return _isRussian(context)
        ? 'Например, аккумулятор'
        : 'For example, battery';
  }

  String _partDescriptionHint() {
    return _isRussian(context)
        ? 'Где установлена, состояние, заметки...'
        : 'Where it was installed, condition, notes...';
  }

  String _installedMileageLabel() {
    return _isRussian(context)
        ? 'ПРОБЕГ ПРИ УСТАНОВКЕ'
        : 'MILEAGE AT INSTALLATION';
  }

  String _serviceMileageLabel() {
    return _isRussian(context) ? 'ПРОБЕГ ПРИ РЕМОНТЕ' : 'MILEAGE AT REPAIR';
  }

  String _currentMileageBeforeEventError() {
    return _isRussian(context)
        ? 'Текущий пробег не может быть меньше пробега события'
        : 'Current mileage cannot be less than event mileage';
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

    _update(() => _isSaving = true);
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
      final photos =
          (_type == HistoryEventType.maintenance ||
              _type == HistoryEventType.part)
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
      showNativeMessage(
        context,
        AppLocalizations.of(context).couldNotSaveEvent,
      );
    } finally {
      if (mounted) _update(() => _isSaving = false);
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
        :final currentMileageKm,
      ):
        _mileageController.text = event.currentMileageKm.toString();
        _currentMileageController.text =
            (currentMileageKm ?? event.currentMileageKm).toString();
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
    _update(() => _isPickingPhoto = true);

    try {
      final photos = await _selectPhotosFromGallery();
      if (photos.isNotEmpty && mounted) {
        _update(() => _selectedPhotos.addAll(photos));
      }
    } on PlatformException {
      _showPhotoError(accessError);
    } catch (_) {
      _showPhotoError(selectError);
    } finally {
      if (mounted) _update(() => _isPickingPhoto = false);
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
        _update(() => _selectedPhotos.addAll(files));
      } else if (response.exception != null) {
        _showPhotoError(restoreError);
      }
    } on PlatformException {
      _showPhotoError(restoreError);
    }
  }

  void _showPhotoError(String message) {
    if (!mounted) return;
    showNativeMessage(context, message);
  }

  void _removePhoto(XFile photo) {
    _update(() => _selectedPhotos.remove(photo));
  }

  void _removeExistingPhoto(String url) {
    _update(() {
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
    final date = await showNativeDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;

    final time = await showNativeTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (time == null) return;

    _update(() {
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
          currentMileageKm: int.parse(_currentMileageController.text),
        ),
      ),
      HistoryEventType.part => HistoryEvent(
        id: id,
        carId: widget.vehicleId,
        type: _type,
        occurredAt: _occurredAt,
        title: _titleController.text.trim(),
        currentMileageKm: int.parse(_mileageController.text),
        details: MaintenanceDetails(
          description: _maintenanceDescriptionController.text.trim(),
          cost: int.tryParse(_maintenanceCostController.text),
          photoUrls: _maintenancePhotoUrls(photoPaths),
          currentMileageKm: int.parse(_currentMileageController.text),
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
