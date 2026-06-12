# Error Handling Skill

## Goal

Provide reliable, understandable, and secure error handling.

## UI States

Every async screen should support:
- loading;
- content;
- empty;
- error;
- retry when possible.

Every mutation should support:
- idle;
- submitting;
- success;
- validation error;
- generic error.

## Error Sources

Handle:
- network unavailable;
- timeout;
- unauthorized;
- forbidden;
- not found;
- conflict;
- validation error;
- server error;
- unknown error.

## User Messages

Use clear messages:
- `Нет соединения. Проверьте интернет и попробуйте снова.`
- `Сессия истекла. Войдите снова.`
- `Автомобиль не найден.`
- `Пробег не может быть меньше предыдущего значения.`
- `Недостаточно данных для ответа`

Do not show:
- stack traces;
- raw JSON;
- token values;
- internal server details.

## Product-specific Cases

Garage:
- empty garage is not an error;
- deleted vehicle should return to garage.

History:
- empty timeline is not an error;
- invalid mileage should be field-level error.

Parts:
- missing lifetime should display `Ресурс не задан`, not crash.

Analytics:
- insufficient data should show empty/placeholder state, not fake numbers.

Chat:
- if AI has no data, show the contract fallback;
- failed send should allow retry;
- chat history should not be lost after a failed send.
