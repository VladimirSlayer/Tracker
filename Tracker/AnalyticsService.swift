import Foundation
import YandexMobileMetrica

enum AnalyticsEvent: String {
    case open
    case close
    case click
}

final class AnalyticsService {
    static let shared = AnalyticsService()

    private init() {}

    func report(event: AnalyticsEvent, screen: String, item: String? = nil) {
        var parameters: [AnyHashable: Any] = [
            "event": event.rawValue,
            "screen": screen
        ]
        if let item = item {
            parameters["item"] = item
        }

        
        print("🔹Analytics Reported: \(parameters)")

        YMMYandexMetrica.reportEvent("ui_event", parameters: parameters) { error in
            print("❌ Metrica error: \(error.localizedDescription)")
        }
    }
}
