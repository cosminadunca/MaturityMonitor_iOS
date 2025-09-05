import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSDataStorePlugin
import AWSPinpointAnalyticsPlugin
import Mixpanel

@main
struct Maturity_MonitorApp: App {
    @State private var sessionStartTime: Date?

    init() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: AmplifyModels()))
            try Amplify.add(plugin: AWSDataStorePlugin(modelRegistration: AmplifyModels()))
            try Amplify.add(plugin: AWSPinpointAnalyticsPlugin())
            try Amplify.configure()
            print("✅ Amplify configured")

            Task {
                try await Amplify.DataStore.start()
            }

            // Mixpanel Init
            Mixpanel.initialize(token: "ba2b7aa06eb4384fec82afb09b3f8dc7", trackAutomaticEvents: false)
            print("✅ Mixpanel initialized")

            // Ensure Mixpanel identifies with the sessionId
            let sessionId = SessionManager.shared.sessionID
            Mixpanel.mainInstance().identify(distinctId: sessionId)
            print("📡 Session ID used as distinctId for Mixpanel: \(sessionId)")

            // Register global sessionID as super property
            Mixpanel.mainInstance().registerSuperProperties([
                "sessionId": sessionId
            ])
        } catch {
            print("❌ Amplify init error: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    sessionStartTime = Date()
                    // Track session start event with sessionId
                    Mixpanel.mainInstance().track(event: "MIX Session Start", properties: [
                        "startTime": sessionStartTime ?? Date()
                    ])
                    print("🔔 Session Start event tracked for sessionId: \(SessionManager.shared.sessionID)")
                }
                .onDisappear {
                    if let startTime = sessionStartTime {
                        let duration = Date().timeIntervalSince(startTime)
                        trackSessionDuration(duration: duration)
                    }
                }
        }
    }

    func trackSessionDuration(duration: TimeInterval) {
        // Track session end event with sessionId and session duration
        Mixpanel.mainInstance().track(event: "MIX Session End", properties: [
            "sessionDuration": duration
        ])
        print("🕓 Session End event tracked for sessionId: \(SessionManager.shared.sessionID) with duration: \(duration) seconds")
    }
}
