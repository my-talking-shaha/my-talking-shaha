# Auth Design Notes

## Screens From Design

- Accord to `docs/design/screenshots/auth/` for design example

## Visual Structure

The auth screens use a dark abstract background with a large centered brand title and a glass-like form card.

Login content:
- brand title `My Talking Shaha`;
- email input;
- password input with visibility toggle;
- forgot password link;
- primary CTA `Log in`;
- social auth divider;
- Yandex ID button placeholder;
- link to registration.

Registration content:
- title `Registration`;
- subtitle `Create your profile`;
- full name input;
- email input;
- password input;
- confirm password input;
- primary CTA `Register`;
- Yandex ID button placeholder;
- link to login.

## Implementation Notes

- Use a shared `AuthFormCard`.
- Use `AuthTextField` for all fields.
- Use `AuthPrimaryButton` for the main CTA.
- Use `AuthErrorBanner` for auth errors returned by `AuthController`.
- Use `AuthScreenScaffold` for the background and auth page layout.
- The login screen uses the brand-heavy layout with `useLoginBackground: true`.
- The registration screen keeps the form card as the primary focus.
- Social auth provider should not be hardcoded in business logic. The current UI shows Yandex ID, but it is a placeholder until OAuth/backend integration is implemented.
- Keep validation messages friendly and short.
- Visible copy should stay in English.

## States To Support

- idle;
- loading;
- validation error;
- backend auth error;
- password visibility on/off.
- restored session;
- unauthenticated redirect;
- authenticated redirect.

## Current Copy

Login:
- `Email`
- `Password`
- `Forgot password?`
- `Log in`
- `No account?`
- `Register`

Registration:
- `Registration`
- `Create your profile`
- `Full name`
- `Email`
- `Password`
- `Confirm password`
- `Register`
- `Already have an account?`
- `Log in`
