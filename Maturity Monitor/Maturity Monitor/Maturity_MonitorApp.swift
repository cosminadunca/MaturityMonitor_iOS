//
//  Maturity_MonitorApp.swift
//  Maturity Monitor
//
//  Created by Cosmina Dunca on 12/08/2024.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSDataStorePlugin

@main
struct Maturity_MonitorApp: App {
    init() {
        do {
            // Add the Auth, API, and DataStore plugins
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: AmplifyModels()))
            try Amplify.add(plugin: AWSDataStorePlugin(modelRegistration: AmplifyModels())) // Ensure to include your model registration
            try Amplify.configure()
            print("Amplify configured with Auth, API, and DataStore plugins")
        } catch {
            print("Failed to initialize Amplify with error: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
