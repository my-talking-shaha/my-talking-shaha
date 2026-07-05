package ru.talkingshaha.backend.vehicle.service;

import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.time.OffsetDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import ru.talkingshaha.backend.common.error.ResourceNotFoundException;
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
        ImageFormat format = requireSupportedImage(file);

        VehiclePhoto photo = new VehiclePhoto();
        photo.setVehicle(vehicle);
        photo.setContentType(format.contentType());
        photo.setCreatedAt(OffsetDateTime.now());
        photo.setFileName(UUID.randomUUID() + format.extension());
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
    public PhotoContent photoContent(UUID photoId) {
        VehiclePhoto photo = photos.findById(photoId)
                .orElseThrow(() -> new ResourceNotFoundException("Photo not found"));
        Resource resource = storage.load(photo.getFileName())
                .orElseThrow(() -> new ResourceNotFoundException("Photo not found"));
        return new PhotoContent(MediaType.parseMediaType(photo.getContentType()), resource);
    }

    private VehiclePhotoResponse toResponse(VehiclePhoto photo) {
        return new VehiclePhotoResponse(photo.getId(), PhotoUrls.publicUrl(photo.getId()));
    }

    private ImageFormat requireSupportedImage(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("Photo file must not be empty");
        }
        byte[] header = readHeader(file);
        ImageFormat format = ImageFormat.fromHeader(header);
        if (format == null || !format.contentType().equals(file.getContentType())) {
            throw new IllegalArgumentException("Only JPG and PNG images are supported");
        }
        return format;
    }

    private byte[] readHeader(MultipartFile file) {
        try (InputStream content = file.getInputStream()) {
            return content.readNBytes(8);
        } catch (IOException e) {
            throw new UncheckedIOException("Failed to read uploaded photo", e);
        }
    }

    public record PhotoContent(MediaType contentType, Resource resource) {
    }

    private enum ImageFormat {
        JPEG(MediaType.IMAGE_JPEG_VALUE, ".jpg", new byte[] {(byte) 0xFF, (byte) 0xD8, (byte) 0xFF}),
        PNG(MediaType.IMAGE_PNG_VALUE, ".png",
                new byte[] {(byte) 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A});

        private final String contentType;
        private final String extension;
        private final byte[] magicBytes;

        ImageFormat(String contentType, String extension, byte[] magicBytes) {
            this.contentType = contentType;
            this.extension = extension;
            this.magicBytes = magicBytes;
        }

        String contentType() {
            return contentType;
        }

        String extension() {
            return extension;
        }

        static ImageFormat fromHeader(byte[] header) {
            return Arrays.stream(values())
                    .filter(format -> startsWith(header, format.magicBytes))
                    .findFirst()
                    .orElse(null);
        }

        private static boolean startsWith(byte[] header, byte[] prefix) {
            if (header.length < prefix.length) {
                return false;
            }
            return Arrays.equals(Arrays.copyOf(header, prefix.length), prefix);
        }
    }
}
