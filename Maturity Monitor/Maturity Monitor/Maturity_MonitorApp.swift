import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSDataStorePlugin
import AWSPinpointAnalyticsPlugin

// Imports for app tracking purposes
//import Mixpanel

@main
struct Maturity_MonitorApp: App {
    @State private var sessionStartTime: Date?
    init() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())      // Auth first
            try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: AmplifyModels())) // 🔹 API second
            try Amplify.add(plugin: AWSDataStorePlugin(modelRegistration: AmplifyModels())) // 🔹 DataStore third
            try Amplify.add(plugin: AWSPinpointAnalyticsPlugin()) // Analytics last

            try Amplify.configure()
            print("✅ Amplify configured with Auth, API, DataStore, and Analytics plugins")
            
            // ✅ Start DataStore sync engine after configuration
            Task {
                try await Amplify.DataStore.start()
            }
        } catch {
            print("❌ Failed to initialize Amplify with error: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            // Track Time Spent in the App
                .onAppear {
                    sessionStartTime = Date()  // Start session tracking
                    trackDeviceDetails()
                }
                .onDisappear {
                    if let startTime = sessionStartTime {
                        let sessionDuration = Date().timeIntervalSince(startTime)
                        trackSessionDuration(duration: sessionDuration)
                    }
                }
        }
    }
    
    // Session Duration Tracking
    func trackSessionDuration(duration: TimeInterval) {
        let event = BasicAnalyticsEvent(name: "SessionDuration",
                                            properties: ["Duration": String(format: "%.2f", duration)])
        Amplify.Analytics.record(event: event)
        print("Tracked: Session duration - \(duration) seconds")
    }
    func trackDeviceDetails() {
        let device = UIDevice.current
        let deviceInfo = [
            "DeviceType": device.model,
            "OSVersion": device.systemVersion,
            "AppVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        ]

        let event = BasicAnalyticsEvent(name: "DeviceDetails", properties: deviceInfo)
        Amplify.Analytics.record(event: event)
        print("Tracked: Device details - \(deviceInfo)")
    }
}
