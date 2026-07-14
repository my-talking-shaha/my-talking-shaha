package ru.talkingshaha.backend.common.storage;

import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.util.Arrays;

import org.springframework.http.MediaType;
import org.springframework.web.multipart.MultipartFile;

public final class ImageValidator {

    private ImageValidator() {
    }

    public record ValidatedImage(String contentType, String extension) {
    }

    public static ValidatedImage validate(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("Photo file must not be empty");
        }
        ImageFormat format = ImageFormat.fromHeader(readHeader(file));
        if (format == null || !format.contentType.equals(file.getContentType())) {
            throw new IllegalArgumentException("Only JPG and PNG images are supported");
        }
        return new ValidatedImage(format.contentType, format.extension);
    }

    private static byte[] readHeader(MultipartFile file) {
        try (InputStream content = file.getInputStream()) {
            return content.readNBytes(8);
        } catch (IOException e) {
            throw new UncheckedIOException("Failed to read uploaded photo", e);
        }
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
