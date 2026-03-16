import Foundation
import AppMetricaCore

struct AnalyticsService {
    
    static func reportEvent(screen: String, event: String) {
        let params: [String: Any] = [
            "event": event,
            "screen": screen
        ]
        AppMetrica.reportEvent(name: "EVENT", parameters: params)
        print("[Analytics] screen: \(screen), event: \(event)")
    }
    
    static func reportClick(screen: String, item: String) {
        let params: [String: Any] = [
            "event": "click",
            "screen": screen,
            "item": item
        ]
        AppMetrica.reportEvent(name: "EVENT", parameters: params)
        print("[Analytics] screen: \(screen), event: click, item: \(item)")
    }
}
