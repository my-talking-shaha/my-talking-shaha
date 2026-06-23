package ru.talkingshaha.backend.analytics.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.Month;
import java.time.OffsetDateTime;
import java.time.YearMonth;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.talkingshaha.backend.analytics.dto.AnalyticsOverviewResponse;
import ru.talkingshaha.backend.analytics.dto.CostPerKilometerResponse;
import ru.talkingshaha.backend.analytics.dto.FuelAnalyticsResponse;
import ru.talkingshaha.backend.analytics.dto.HistoryAnalysisResponse;
import ru.talkingshaha.backend.analytics.dto.MonthlyExpenseResponse;
import ru.talkingshaha.backend.analytics.dto.SeasonalExpenseResponse;
import ru.talkingshaha.backend.analytics.model.AnalyticsPeriod;
import ru.talkingshaha.backend.common.model.BaseEvent;
import ru.talkingshaha.backend.part.model.Part;
import ru.talkingshaha.backend.part.repository.PartRepository;
import ru.talkingshaha.backend.timeline.model.MaintenanceEvent;
import ru.talkingshaha.backend.timeline.model.RefuelEvent;
import ru.talkingshaha.backend.timeline.model.TimelineEventType;
import ru.talkingshaha.backend.timeline.model.TripEvent;
import ru.talkingshaha.backend.timeline.repository.TimelineEventRepository;
import ru.talkingshaha.backend.vehicle.model.Vehicle;
import ru.talkingshaha.backend.vehicle.service.VehicleService;

@Service
public class AnalyticsService {

    private static final String CURRENCY = "RUB";
    private static final DateTimeFormatter MONTH_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM");

    private final VehicleService vehicles;
    private final TimelineEventRepository events;
    private final PartRepository parts;

    public AnalyticsService(VehicleService vehicles, TimelineEventRepository events, PartRepository parts) {
        this.vehicles = vehicles;
        this.events = events;
        this.parts = parts;
    }

    @Transactional(readOnly = true)
    public AnalyticsOverviewResponse overview(UUID vehicleId, AnalyticsPeriod period) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        PeriodRange range = range(period);
        List<BaseEvent> filteredEvents = events.findAllByVehicleOrderByEventDateTimeDesc(vehicle).stream()
                .filter(event -> inRange(event.getEventDateTime(), range))
                .toList();
        List<Part> filteredParts = parts.findAllByVehicleOrderByInstalledAtDescNameAsc(vehicle).stream()
                .filter(part -> inRange(part.getInstalledAt(), range))
                .toList();
        Map<String, BigDecimal> categoryTotals = categoryTotals(filteredEvents, filteredParts);
        BigDecimal totalExpenses = categoryTotals.values().stream().reduce(BigDecimal.ZERO, BigDecimal::add);
        int totalKm = totalTripKm(filteredEvents);
        BigDecimal totalLiters = totalLiters(filteredEvents);
        return new AnalyticsOverviewResponse(
                period,
                totalExpenses,
                CURRENCY,
                categoryTotals,
                monthlyExpenses(filteredEvents, filteredParts),
                seasonalExpenses(filteredEvents, filteredParts),
                new CostPerKilometerResponse(totalKm, totalExpenses, divideMoney(totalExpenses, totalKm)),
                new FuelAnalyticsResponse(totalLiters, consumptionPer100Km(totalLiters, totalKm)),
                historyAnalysis(filteredEvents, totalKm),
                !filteredEvents.isEmpty() || !filteredParts.isEmpty());
    }

    private Map<String, BigDecimal> categoryTotals(List<BaseEvent> filteredEvents, List<Part> filteredParts) {
        Map<String, BigDecimal> totals = emptyCategories();
        for (BaseEvent event : filteredEvents) {
            if (event instanceof RefuelEvent refuel) {
                add(totals, "FUEL", refuel.getCost());
            } else if (event instanceof MaintenanceEvent maintenance) {
                String category = maintenance.getType() == TimelineEventType.PART_REPLACEMENT ? "PARTS" : "MAINTENANCE";
                add(totals, category, maintenance.getCost());
            }
        }
        for (Part part : filteredParts) {
            add(totals, "PARTS", part.getCost());
        }
        return totals;
    }

    private List<MonthlyExpenseResponse> monthlyExpenses(List<BaseEvent> filteredEvents, List<Part> filteredParts) {
        Map<YearMonth, Map<String, BigDecimal>> months = new LinkedHashMap<>();
        for (BaseEvent event : filteredEvents) {
            YearMonth month = YearMonth.from(event.getEventDateTime().atZoneSameInstant(ZoneOffset.UTC));
            addEventCost(months.computeIfAbsent(month, ignored -> emptyCategories()), event);
        }
        for (Part part : filteredParts) {
            YearMonth month = YearMonth.from(part.getInstalledAt());
            add(months.computeIfAbsent(month, ignored -> emptyCategories()), "PARTS", part.getCost());
        }
        return months.entrySet().stream()
                .sorted(Map.Entry.comparingByKey())
                .map(entry -> new MonthlyExpenseResponse(
                        entry.getKey().format(MONTH_FORMATTER),
                        entry.getValue().values().stream().reduce(BigDecimal.ZERO, BigDecimal::add),
                        entry.getValue()))
                .toList();
    }

    private List<SeasonalExpenseResponse> seasonalExpenses(List<BaseEvent> filteredEvents, List<Part> filteredParts) {
        Map<String, BigDecimal> seasons = new LinkedHashMap<>();
        seasons.put("WINTER", BigDecimal.ZERO);
        seasons.put("SPRING", BigDecimal.ZERO);
        seasons.put("SUMMER", BigDecimal.ZERO);
        seasons.put("AUTUMN", BigDecimal.ZERO);
        for (BaseEvent event : filteredEvents) {
            add(seasons, season(event.getEventDateTime().getMonth()), eventCost(event));
        }
        for (Part part : filteredParts) {
            add(seasons, season(part.getInstalledAt().getMonth()), part.getCost());
        }
        return seasons.entrySet().stream()
                .map(entry -> new SeasonalExpenseResponse(entry.getKey(), entry.getValue()))
                .toList();
    }

    private HistoryAnalysisResponse historyAnalysis(List<BaseEvent> filteredEvents, int totalKm) {
        int refuels = 0;
        int trips = 0;
        int maintenances = 0;
        int partEvents = 0;
        for (BaseEvent event : filteredEvents) {
            if (event instanceof RefuelEvent) {
                refuels++;
            } else if (event instanceof TripEvent) {
                trips++;
            } else if (event instanceof MaintenanceEvent maintenance) {
                if (maintenance.getType() == TimelineEventType.PART_REPLACEMENT) {
                    partEvents++;
                } else {
                    maintenances++;
                }
            }
        }
        BigDecimal averageTripKm = trips == 0
                ? BigDecimal.ZERO
                : BigDecimal.valueOf(totalKm).divide(BigDecimal.valueOf(trips), 2, RoundingMode.HALF_UP);
        return new HistoryAnalysisResponse(
                filteredEvents.size(), refuels, trips, maintenances, partEvents, totalKm, averageTripKm);
    }

    private int totalTripKm(List<BaseEvent> filteredEvents) {
        return filteredEvents.stream()
                .filter(TripEvent.class::isInstance)
                .map(TripEvent.class::cast)
                .mapToInt(trip -> trip.getStartMileageKm() == null
                        ? 0
                        : Math.max(0, trip.getEndMileageKm() - trip.getStartMileageKm()))
                .sum();
    }

    private BigDecimal totalLiters(List<BaseEvent> filteredEvents) {
        return filteredEvents.stream()
                .filter(RefuelEvent.class::isInstance)
                .map(RefuelEvent.class::cast)
                .map(RefuelEvent::getLiters)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private void addEventCost(Map<String, BigDecimal> totals, BaseEvent event) {
        if (event instanceof RefuelEvent refuel) {
            add(totals, "FUEL", refuel.getCost());
        } else if (event instanceof MaintenanceEvent maintenance) {
            add(totals, maintenance.getType() == TimelineEventType.PART_REPLACEMENT ? "PARTS" : "MAINTENANCE",
                    maintenance.getCost());
        }
    }

    private BigDecimal eventCost(BaseEvent event) {
        if (event instanceof RefuelEvent refuel) {
            return refuel.getCost();
        }
        if (event instanceof MaintenanceEvent maintenance) {
            return maintenance.getCost();
        }
        return BigDecimal.ZERO;
    }

    private BigDecimal divideMoney(BigDecimal value, int divisor) {
        if (divisor == 0) {
            return BigDecimal.ZERO;
        }
        return value.divide(BigDecimal.valueOf(divisor), 2, RoundingMode.HALF_UP);
    }

    private BigDecimal consumptionPer100Km(BigDecimal liters, int totalKm) {
        if (totalKm == 0 || liters.compareTo(BigDecimal.ZERO) == 0) {
            return BigDecimal.ZERO;
        }
        return liters.multiply(BigDecimal.valueOf(100)).divide(BigDecimal.valueOf(totalKm), 2, RoundingMode.HALF_UP);
    }

    private Map<String, BigDecimal> emptyCategories() {
        Map<String, BigDecimal> totals = new LinkedHashMap<>();
        totals.put("FUEL", BigDecimal.ZERO);
        totals.put("MAINTENANCE", BigDecimal.ZERO);
        totals.put("PARTS", BigDecimal.ZERO);
        return totals;
    }

    private void add(Map<String, BigDecimal> totals, String category, BigDecimal amount) {
        if (amount != null) {
            totals.compute(category, (ignored, current) -> current == null ? amount : current.add(amount));
        }
    }

    private String season(Month month) {
        return switch (month) {
            case DECEMBER, JANUARY, FEBRUARY -> "WINTER";
            case MARCH, APRIL, MAY -> "SPRING";
            case JUNE, JULY, AUGUST -> "SUMMER";
            case SEPTEMBER, OCTOBER, NOVEMBER -> "AUTUMN";
        };
    }

    private PeriodRange range(AnalyticsPeriod period) {
        OffsetDateTime now = OffsetDateTime.now();
        return switch (period) {
            case MONTH ->
                    new PeriodRange(now.withDayOfMonth(1).toLocalDate().atStartOfDay().atOffset(now.getOffset()), null);
            case YEAR ->
                    new PeriodRange(now.withDayOfYear(1).toLocalDate().atStartOfDay().atOffset(now.getOffset()), null);
            case ALL_TIME -> new PeriodRange(null, null);
        };
    }

    private boolean inRange(OffsetDateTime dateTime, PeriodRange range) {
        return range.start() == null || !dateTime.isBefore(range.start());
    }

    private boolean inRange(LocalDate date, PeriodRange range) {
        return range.start() == null || !date.isBefore(range.start().toLocalDate());
    }

    private record PeriodRange(OffsetDateTime start, OffsetDateTime end) {
    }
}