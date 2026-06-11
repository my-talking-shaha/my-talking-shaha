# Auth Design Notes

## Screens From Design

- `Auth-log in.png`
- `Auth-sign up.png`

## Visual Structure

The auth screens use a dark abstract background with a large centered brand title and a glass-like form card.

Login content:
- brand title `Моя говорящая Шаха`;
- login/email input;
- password input with visibility toggle;
- forgot password link;
- primary CTA `Войти в систему`;
- social auth divider;
- social auth button;
- link to registration.

Registration content:
- title `Регистрация`;
- subtitle for account creation;
- name/login input;
- email input;
- password input;
- confirm password input;
- primary CTA `Зарегистрироваться`;
- social auth button;
- link to login.

## Implementation Notes

- Use a shared `AuthFormCard`.
- Use `ShahaTextField` for all fields.
- Use `ShahaButton.primary` for the main CTA.
- Social auth provider should not be hardcoded in business logic. The current design shows YandexID, while requirements mention Google OAuth. Use a generic `SocialAuthButton` and align provider text with backend/product decision.
- Keep validation messages friendly and short.

## States To Support

- idle;
- loading;
- validation error;
- backend auth error;
- password visibility on/off.
