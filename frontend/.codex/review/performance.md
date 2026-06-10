# Performance Review Checklist

## Flutter UI

Check:
- Avoid expensive computation in `build`.
- Use `const` widgets where useful and readable.
- Avoid rebuilding whole screens for small state changes.
- Avoid unnecessary nested scroll views.
- Use list virtualization for long timeline/history lists.
- Avoid large image decoding on the main thread where possible.
- Avoid repeatedly formatting dates/currency in every build when state can precompute UI models.

## Riverpod

Check:
- Providers do not refetch on every rebuild.
- `autoDispose` is used intentionally.
- Dependencies are watched at the narrowest useful scope.
- Long-lived state is not accidentally destroyed during navigation.

## Network

Check:
- Avoid repeated network calls on screen rebuild.
- Use repository methods with clear fetch/refresh semantics.
- Avoid parallel duplicate submissions.
- Add debounce to search/filter where needed.

## Product-specific

Check:
- Timeline lists remain smooth with many records.
- Analytics calculations are not recomputed excessively in widgets.
- Chat messages append efficiently.
- Vehicle images are cached or handled with reasonable sizing.
