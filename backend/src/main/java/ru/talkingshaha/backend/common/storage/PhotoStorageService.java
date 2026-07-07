package ru.talkingshaha.backend.common.storage;

import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;

@Service
public class PhotoStorageService {

    private final Path photosDir;

    public PhotoStorageService(@Value("${app.storage.photos-dir}") String photosDir) {
        this.photosDir = Path.of(photosDir).toAbsolutePath().normalize();
    }

    public void store(String fileName, InputStream content) {
        try {
            Files.createDirectories(photosDir);
            Files.copy(content, resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            throw new UncheckedIOException("Failed to store photo file " + fileName, e);
        }
    }

    public Optional<Resource> load(String fileName) {
        Path file = resolve(fileName);
        return Files.isRegularFile(file) ? Optional.of(new FileSystemResource(file)) : Optional.empty();
    }

    public void delete(String fileName) {
        try {
            Files.deleteIfExists(resolve(fileName));
        } catch (IOException e) {
            throw new UncheckedIOException("Failed to delete photo file " + fileName, e);
        }
    }

    private Path resolve(String fileName) {
        Path file = photosDir.resolve(fileName).normalize();
        if (!file.startsWith(photosDir)) {
            throw new IllegalArgumentException("Invalid photo file name");
        }
        return file;
    }
}
