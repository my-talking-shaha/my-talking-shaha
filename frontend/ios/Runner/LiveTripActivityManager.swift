import ActivityKit
import Flutter
import Foundation

final class LiveTripActivityBridge {
  private let channel: FlutterMethodChannel

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "my_talking_shaha/live_trip_activity",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler(handle)
  }

  private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard #available(iOS 16.1, *) else {
      result(nil)
      return
    }

    switch call.method {
    case "ensureStarted":
      guard
        let arguments = call.arguments as? [String: Any],
        let vehicleId = arguments["vehicleId"] as? String,
        let vehicleName = arguments["vehicleName"] as? String,
        let startMileageNumber = arguments["startMileageKm"] as? NSNumber,
        let startedAtNumber = arguments["startedAtMilliseconds"] as? NSNumber
      else {
        result(
          FlutterError(
            code: "INVALID_LIVE_TRIP",
            message: "Live trip arguments are invalid.",
            details: nil
          )
        )
        return
      }

      Task { @MainActor in
        do {
          try await LiveTripActivityManager.ensureStarted(
            vehicleId: vehicleId,
            vehicleName: vehicleName,
            startMileageKm: startMileageNumber.intValue,
            startedAt: Date(
              timeIntervalSince1970: startedAtNumber.doubleValue / 1000
            )
          )
          result(nil)
        } catch {
          result(
            FlutterError(
              code: "LIVE_ACTIVITY_UNAVAILABLE",
              message: "Live Activity could not be started.",
              details: nil
            )
          )
        }
      }
    case "end":
      Task { @MainActor in
        await LiveTripActivityManager.endAll()
        result(nil)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

@available(iOS 16.1, *)
@MainActor
private enum LiveTripActivityManager {
  static func ensureStarted(
    vehicleId: String,
    vehicleName: String,
    startMileageKm: Int,
    startedAt: Date
  ) async throws {
    if Activity<TripActivityAttributes>.activities.contains(where: {
      $0.attributes.vehicleId == vehicleId &&
        $0.attributes.startedAt == startedAt
    }) {
      return
    }

    await endAll()
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

    let attributes = TripActivityAttributes(
      vehicleId: vehicleId,
      vehicleName: vehicleName,
      startMileageKm: startMileageKm,
      startedAt: startedAt
    )
    _ = try Activity.request(
      attributes: attributes,
      contentState: .init(isRunning: true),
      pushType: nil
    )
  }

  static func endAll() async {
    for activity in Activity<TripActivityAttributes>.activities {
      await activity.end(dismissalPolicy: .immediate)
    }
  }
}
