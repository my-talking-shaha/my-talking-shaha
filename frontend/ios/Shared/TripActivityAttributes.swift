import ActivityKit
import Foundation

@available(iOS 16.1, *)
struct TripActivityAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable {
    let isRunning: Bool
  }

  let vehicleId: String
  let vehicleName: String?
  let startMileageKm: Int
  let startedAt: Date
}
