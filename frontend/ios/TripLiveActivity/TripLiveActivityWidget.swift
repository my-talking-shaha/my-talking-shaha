import ActivityKit
import SwiftUI
import WidgetKit

@main
struct TripLiveActivityWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: TripActivityAttributes.self) { context in
      lockScreenView(context)
        .activityBackgroundTint(
          Color(red: 0.06, green: 0.07, blue: 0.10)
        )
        .activitySystemActionForegroundColor(.white)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          HStack(spacing: 8) {
            ZStack {
              Circle()
                .fill(accentColor.opacity(0.18))

              Circle()
                .stroke(
                  accentColor.opacity(0.34),
                  lineWidth: 1
                )

              Image(systemName: "car.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(accentColor)
            }
            .frame(width: 38, height: 38)

            Text(activityTitle(context.attributes.vehicleName))
              .font(.headline)
              .fontWeight(.bold)
              .lineLimit(1)
              .minimumScaleFactor(0.7)
          }
        }

        DynamicIslandExpandedRegion(.trailing) {
          mileageView(context.attributes.startMileageKm)
            .padding(.trailing, 6)
            .padding(.bottom, 6)
        }

        DynamicIslandExpandedRegion(.bottom) {
          HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
              Text(localized("ВРЕМЯ", "TIME"))
                .font(.system(size: 9, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(accentColor.opacity(0.9))

              timerView(
                startedAt: context.attributes.startedAt,
                font: .system(
                  size: 27,
                  weight: .medium,
                  design: .rounded
                )
              )
            }

            Spacer(minLength: 12)

            HStack(spacing: 5) {
              Circle()
                .fill(accentColor)
                .frame(width: 6, height: 6)

              Text("LIVE")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(accentColor)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(
              accentColor.opacity(0.14),
              in: Capsule()
            )
            .overlay {
              Capsule()
                .stroke(
                  accentColor.opacity(0.28),
                  lineWidth: 1
                )
            }
          }
          .padding(.top, 4)
          .padding(.trailing, 12)
        }
      } compactLeading: {
        Image(systemName: "car.fill")
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(accentColor)
      } compactTrailing: {
        compactTimerView(
          startedAt: context.attributes.startedAt,
          font: .system(
            size: 15,
            weight: .bold,
            design: .rounded
          )
        )
        .lineLimit(1)
        .minimumScaleFactor(0.75)
        .frame(width: 52, alignment: .trailing)
        .offset(x: 4)
      } minimal: {
        Image(systemName: "car.fill")
          .fontWeight(.semibold)
          .foregroundStyle(accentColor)
      }
      .contentMargins(
        .leading,
        8,
        for: .compactLeading
      )
      .contentMargins(
        .trailing,
        0,
        for: .compactTrailing
      )
      .keylineTint(accentColor)
    }
  }

  private func lockScreenView(
    _ context: ActivityViewContext<TripActivityAttributes>
  ) -> some View {
    HStack(spacing: 12) {
      ZStack {
        Circle()
          .fill(accentColor.opacity(0.16))

        Circle()
          .stroke(accentColor.opacity(0.25), lineWidth: 1)

        Image(systemName: "car.fill")
          .font(.system(size: 21, weight: .semibold))
          .foregroundStyle(accentColor)
      }
      .frame(width: 46, height: 46)

      VStack(alignment: .leading, spacing: 3) {
        Text(activityTitle(context.attributes.vehicleName))
          .font(.system(size: 17, weight: .bold))
          .foregroundStyle(.white)
          .lineLimit(1)
          .minimumScaleFactor(0.7)

        Text(
          "\(localized("Старт", "Start")): "
            + "\(context.attributes.startMileageKm) km"
        )
        .font(.system(size: 13))
        .foregroundStyle(.secondary)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .layoutPriority(1)

      lockScreenTimer(startedAt: context.attributes.startedAt)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
  }

  private func lockScreenTimer(startedAt: Date) -> some View {
    VStack(alignment: .trailing, spacing: 2) {
      Text(localized("ВРЕМЯ", "TIME"))
        .font(.system(size: 9, weight: .semibold))
        .tracking(0.7)
        .foregroundStyle(accentColor.opacity(0.9))
        .lineLimit(1)

      Text(
        timerInterval: startedAt...Date.distantFuture,
        pauseTime: nil,
        countsDown: false,
        showsHours: false
      )
      .font(.system(size: 20, weight: .bold, design: .rounded))
      .monospacedDigit()
      .foregroundStyle(.white)
      .lineLimit(1)
      .minimumScaleFactor(0.75)
      .multilineTextAlignment(.trailing)
      .frame(width: 76, alignment: .trailing)
    }
    .frame(width: 76, alignment: .trailing)
  }

  private func mileageView(_ mileage: Int) -> some View {
    VStack(alignment: .trailing, spacing: 1) {
      Text(localized("СТАРТ", "START"))
        .font(.system(size: 9, weight: .semibold))
        .foregroundStyle(.secondary)
        .lineLimit(1)

      Text("\(mileage) km")
        .font(
          .system(
            size: 14,
            weight: .bold,
            design: .rounded
          )
        )
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
    .padding(.trailing, 4)
  }

  private func timerView(
    startedAt: Date,
    font: Font
  ) -> some View {
    Text(startedAt, style: .timer)
      .font(font)
      .monospacedDigit()
  }

  private func compactTimerView(
    startedAt: Date,
    font: Font
  ) -> some View {
    Text(startedAt, style: .timer)
      .font(font)
      .monospacedDigit()
  }

  private var accentColor: Color {
    Color(
      red: 0.18,
      green: 0.36,
      blue: 1.0
    )
  }

  private func activityTitle(
    _ vehicleName: String?
  ) -> String {
    let trimmedName = vehicleName?
      .trimmingCharacters(
        in: .whitespacesAndNewlines
      ) ?? ""

    return trimmedName.isEmpty
      ? localized("Поездка", "Trip")
      : trimmedName
  }

  private func localized(
    _ russian: String,
    _ english: String
  ) -> String {
    Locale.current.language.languageCode == "ru"
      ? russian
      : english
  }
}
