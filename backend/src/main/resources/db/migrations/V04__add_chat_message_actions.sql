ALTER TABLE chat_messages
    ADD COLUMN IF NOT EXISTS action_type VARCHAR(50),
    ADD COLUMN IF NOT EXISTS action_form VARCHAR(50),
    ADD COLUMN IF NOT EXISTS action_screen VARCHAR(50),
    ADD COLUMN IF NOT EXISTS action_prefill TEXT;

UPDATE chat_messages
SET action_type = 'OPEN_SCREEN',
    action_screen = 'ANALYTICS',
    action_prefill = '{}'
WHERE role = 'ASSISTANT'
  AND action_type IS NULL
  AND (
    LOWER(text) LIKE '%analytics%'
        OR LOWER(text) LIKE '%аналитик%'
    );

UPDATE chat_messages
SET action_type = 'OPEN_SCREEN',
    action_screen = 'MAINTENANCE_FORECAST',
    action_prefill = '{}'
WHERE role = 'ASSISTANT'
  AND action_type IS NULL
  AND (
    LOWER(text) LIKE '%maintenance forecast%'
        OR LOWER(text) LIKE '%прогноз обслуж%'
    );

UPDATE chat_messages
SET action_type = 'OPEN_SCREEN',
    action_screen = 'DASHBOARD',
    action_prefill = '{}'
WHERE role = 'ASSISTANT'
  AND action_type IS NULL
  AND (
    LOWER(text) LIKE '%dashboard%'
        OR LOWER(text) LIKE '%current mileage%'
        OR LOWER(text) LIKE '%maintenance status%'
        OR LOWER(text) LIKE '%экран состояния%'
        OR LOWER(text) LIKE '%сейчас пробег%'
    );

UPDATE chat_messages
SET action_type = 'OPEN_FORM',
    action_form = 'REFUEL',
    action_prefill = '{}'
WHERE role = 'ASSISTANT'
  AND action_type IS NULL
  AND (
    LOWER(text) LIKE '%refuel%'
        OR LOWER(text) LIKE '%refueling%'
        OR LOWER(text) LIKE '%заправ%'
    );

UPDATE chat_messages
SET action_type = 'OPEN_FORM',
    action_form = 'TRIP',
    action_prefill = '{}'
WHERE role = 'ASSISTANT'
  AND action_type IS NULL
  AND (
    LOWER(text) LIKE '%trip%'
        OR LOWER(text) LIKE '%поезд%'
    );

UPDATE chat_messages
SET action_type = 'OPEN_FORM',
    action_form = 'PART_REPLACEMENT',
    action_prefill = '{}'
WHERE role = 'ASSISTANT'
  AND action_type IS NULL
  AND (
    LOWER(text) LIKE '%part_replacement%'
        OR LOWER(text) LIKE '%part replacement%'
        OR LOWER(text) LIKE '%детал%'
    );

UPDATE chat_messages
SET action_type = 'OPEN_FORM',
    action_form = 'MAINTENANCE',
    action_prefill = '{}'
WHERE role = 'ASSISTANT'
  AND action_type IS NULL
  AND (
    LOWER(text) LIKE '%maintenance%'
        OR LOWER(text) LIKE '%repair%'
        OR LOWER(text) LIKE '%ремонт%'
        OR LOWER(text) LIKE '%обслуж%'
    );
