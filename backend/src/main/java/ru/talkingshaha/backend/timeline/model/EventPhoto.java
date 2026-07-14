package ru.talkingshaha.backend.timeline.model;

import java.time.OffsetDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import ru.talkingshaha.backend.common.model.BaseEntity;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "event_photos")
public class EventPhoto extends BaseEntity {

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "event_id", nullable = false)
    private MaintenanceEvent event;

    @NotBlank
    @Size(max = 255)
    @Column(name = "file_name", nullable = false, length = 255)
    private String fileName;

    @NotBlank
    @Size(max = 64)
    @Column(name = "content_type", nullable = false, length = 64)
    private String contentType;

    @NotNull
    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;
}
