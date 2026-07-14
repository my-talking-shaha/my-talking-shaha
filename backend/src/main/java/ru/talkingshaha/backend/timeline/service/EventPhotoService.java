package ru.talkingshaha.backend.timeline.service;

import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.time.OffsetDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import ru.talkingshaha.backend.common.storage.ImageValidator;
import ru.talkingshaha.backend.common.storage.ImageValidator.ValidatedImage;
import ru.talkingshaha.backend.common.storage.PhotoContent;
import ru.talkingshaha.backend.common.storage.PhotoStorageService;
import ru.talkingshaha.backend.timeline.model.EventPhoto;
import ru.talkingshaha.backend.timeline.model.MaintenanceEvent;
import ru.talkingshaha.backend.timeline.repository.EventPhotoRepository;

@Service
public class EventPhotoService {

    private final EventPhotoRepository photos;
    private final PhotoStorageService storage;

    public EventPhotoService(EventPhotoRepository photos, PhotoStorageService storage) {
        this.photos = photos;
        this.storage = storage;
    }

    public void attachPhotos(MaintenanceEvent event, List<MultipartFile> files) {
        if (files == null) {
            return;
        }
        for (MultipartFile file : files) {
            ValidatedImage image = ImageValidator.validate(file);
            EventPhoto photo = new EventPhoto();
            photo.setEvent(event);
            photo.setContentType(image.contentType());
            photo.setCreatedAt(OffsetDateTime.now());
            photo.setFileName(UUID.randomUUID() + image.extension());
            event.getPhotos().add(photo);
            try (InputStream content = file.getInputStream()) {
                storage.store(photo.getFileName(), content);
            } catch (IOException e) {
                throw new UncheckedIOException("Failed to read uploaded photo", e);
            }
        }
    }

    public void deleteFiles(Collection<EventPhoto> eventPhotos) {
        eventPhotos.forEach(photo -> storage.delete(photo.getFileName()));
    }

    @Transactional(readOnly = true)
    public Optional<PhotoContent> photoContent(UUID photoId) {
        return photos.findById(photoId)
                .flatMap(photo -> storage.load(photo.getFileName())
                        .map(resource -> new PhotoContent(
                                MediaType.parseMediaType(photo.getContentType()), resource)));
    }
}
