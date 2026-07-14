## Database description

The schema is centred on **`vehicles`**: a `user` owns many vehicles, and everything else
hangs off a vehicle  its installed `parts`, its service-history `timeline_events`, and its
`chat_sessions`. Photos (`vehicle_photos`, `part_photos`, `event_photos`) and `chat_messages`
are child collections of their owner. `vehicle_photos` and `event_photos` store uploaded photo
metadata (server-generated file name and content type) for vehicles and maintenance/repair
timeline events respectively; the bytes live on the file system under the directory configured
by `app.storage.photos-dir`. `part_photos` still holds plain photo URL strings.

Service-history events use **JOINED inheritance**: the shared fields (`vehicle_id`, `type`,
`event_date_time`) live in `timeline_events`, while each concrete kind - `trips`, `refuel`,
`maintenance` - keeps its own columns in a separate table whose `id` is both the primary key
and a foreign key back to the parent (`PK_FK`). `RECHARGE` events use the same `refuel`
table because their amount/cost/provider fields match the refuel payload; for recharge
events the `refuel.liters` column stores the charged energy in kWh and is exposed through
the API as `kwh` plus a legacy `liters` alias for current mobile compatibility. The event
semantics are distinguished by `timeline_events.type`. One logical event is therefore
stored as two rows sharing the same `id`.

**Notation.** `A <|-- B` - B *is a* kind of A (inheritance). `A "1" --> "0..*" B` - a
foreign key: one A is referenced by many B. `PK` primary key, `FK` foreign key, `UK` unique,
`PK_FK` both at once.
