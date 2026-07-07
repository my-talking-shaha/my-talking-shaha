package ru.talkingshaha.backend.vehicle.service;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Comparator;
import java.util.List;

import org.springframework.stereotype.Service;

@Service
public class VehicleBrandService {

    private static final List<Path> CANDIDATE_PATHS = List.of(
            Path.of("cars", "csv", "marks.csv"),
            Path.of("..", "cars", "csv", "marks.csv"));

    public List<String> brands() {
        Path path = CANDIDATE_PATHS.stream()
                .filter(Files::isRegularFile)
                .findFirst()
                .orElseThrow(() -> new IllegalStateException("Vehicle brands list is not available"));
        try {
            return Files.readAllLines(path, StandardCharsets.UTF_8).stream()
                    .skip(1)
                    .map(this::brandName)
                    .filter(name -> !name.isBlank())
                    .distinct()
                    .sorted(Comparator.comparing(String::toLowerCase))
                    .toList();
        } catch (IOException exception) {
            throw new IllegalStateException("Vehicle brands list is not available", exception);
        }
    }

    private String brandName(String csvLine) {
        String[] columns = csvLine.split(",", -1);
        return columns.length > 1 ? columns[1].strip() : "";
    }
}