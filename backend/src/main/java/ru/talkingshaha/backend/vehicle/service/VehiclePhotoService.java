package ru.talkingshaha.backend.vehicle.service;

import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import ru.talkingshaha.backend.common.error.ResourceNotFoundException;
import ru.talkingshaha.backend.common.storage.ImageValidator;
import ru.talkingshaha.backend.common.storage.ImageValidator.ValidatedImage;
import ru.talkingshaha.backend.common.storage.PhotoContent;
import ru.talkingshaha.backend.common.storage.PhotoStorageService;
import ru.talkingshaha.backend.vehicle.dto.VehiclePhotoListResponse;
import ru.talkingshaha.backend.vehicle.dto.VehiclePhotoResponse;
import ru.talkingshaha.backend.vehicle.model.Vehicle;
import ru.talkingshaha.backend.vehicle.model.VehiclePhoto;
import ru.talkingshaha.backend.vehicle.repository.VehiclePhotoRepository;

@Service
public class VehiclePhotoService {

    private final VehiclePhotoRepository photos;
    private final PhotoStorageService storage;
    private final VehicleService vehicles;

    public VehiclePhotoService(
            VehiclePhotoRepository photos, PhotoStorageService storage, VehicleService vehicles) {
        this.photos = photos;
        this.storage = storage;
        this.vehicles = vehicles;
    }

    @Transactional
    public VehiclePhotoResponse uploadPhoto(UUID vehicleId, MultipartFile file) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        ValidatedImage image = ImageValidator.validate(file);

        VehiclePhoto photo = new VehiclePhoto();
        photo.setVehicle(vehicle);
        photo.setContentType(image.contentType());
        photo.setCreatedAt(OffsetDateTime.now());
        photo.setFileName(UUID.randomUUID() + image.extension());
        photo = photos.save(photo);

        try (InputStream content = file.getInputStream()) {
            storage.store(photo.getFileName(), content);
        } catch (IOException e) {
            throw new UncheckedIOException("Failed to read uploaded photo", e);
        }
        return toResponse(photo);
    }

    @Transactional(readOnly = true)
    public VehiclePhotoListResponse listPhotos(UUID vehicleId) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        List<VehiclePhotoResponse> items =
                photos.findAllByVehicleOrderByCreatedAtAscIdAsc(vehicle).stream().map(this::toResponse).toList();
        return new VehiclePhotoListResponse(items);
    }

    @Transactional
    public void deletePhoto(UUID vehicleId, UUID photoId) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        VehiclePhoto photo = photos.findById(photoId)
                .filter(candidate -> candidate.getVehicle().getId().equals(vehicle.getId()))
                .orElseThrow(() -> new ResourceNotFoundException("Photo not found"));
        photos.delete(photo);
        storage.delete(photo.getFileName());
    }

    @Transactional(readOnly = true)
    public Optional<PhotoContent> photoContent(UUID photoId) {
        return photos.findById(photoId)
                .flatMap(photo -> storage.load(photo.getFileName())
                        .map(resource -> new PhotoContent(
                                MediaType.parseMediaType(photo.getContentType()), resource)));
    }

    private VehiclePhotoResponse toResponse(VehiclePhoto photo) {
        return new VehiclePhotoResponse(photo.getId(), PhotoUrls.publicUrl(photo.getId()));
    }
}
