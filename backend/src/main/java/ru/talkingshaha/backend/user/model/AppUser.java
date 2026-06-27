package ru.talkingshaha.backend.user.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import ru.talkingshaha.backend.common.model.BaseEntity;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(
        name = "app_users",
        uniqueConstraints = @UniqueConstraint(name = "uk_app_users_email", columnNames = "email"))
public class AppUser extends BaseEntity {

    @NotBlank
    @Size(max = 255)
    @Column(nullable = false, length = 255)
    private String email;

    @NotBlank
    @Size(max = 255)
    @Column(nullable = false)
    private String passwordHash;

    @NotBlank
    @Size(max = 120)
    @Column(nullable = false, length = 120)
    private String displayName;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    private UserRole role = UserRole.USER;

    @Column(nullable = false)
    private boolean enabled = true;
}
