// Improvements:
// 1. I would add an image as a background picture for this opening page
// 2. Remove icon image

// Content View comments and messages done - needs testing

import SwiftUI

struct ContentView: View {
    
    // Access to Amplify functions
    private let amplifyService = AmplifyService()
    
    @State private var navigateToLoginView = false
    @State private var navigateToHomeView = false
    @State private var navigateToRegistrationHomeView = false

    var body: some View {
        NavigationView {
            VStack(spacing: 1.5) {
                // Title
                CustomTextTitle(title: "Maturity Monitor")
                
                // Opening Image
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 80, height: 80)
                    .background(
                        Image("ysjResearchLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    )
            }
            .onAppear {
                Task {
                    await amplifyService.signOut()
                    await checkUserStatus()
                }
            }
            .background(
                Group {
                    NavigationLink(destination: LoginView(), isActive: $navigateToLoginView) {
                        EmptyView()
                    }
                    NavigationLink(destination: HomeView(currentPage: .constant("home")), isActive: $navigateToHomeView) {
                        EmptyView()
                    }
                    NavigationLink(destination: RegistrationHomeView(), isActive: $navigateToRegistrationHomeView) {
                        EmptyView()
                    }
                }
            )
        }.navigationBarHidden(true)
    }
    
    // Check user status to figure out where to redirect the opening page
    func checkUserStatus() async {
        do {
            if await amplifyService.isUserSignedIn() {
                if let currentChild = try await amplifyService.getCurrentChild() {
                    if currentChild != "-" {
                        // If user is signed in and has a currentChild (a child account linked to it), navigate to HomeView
                        try await Task.sleep(nanoseconds: 3_000_000_000)
                        navigateToHomeView = true
                    } else {
                        // If user is signed in but does not have a currentChild (a child account linked to it), navigate to RegistrationHomeView
                        try await Task.sleep(nanoseconds: 3_000_000_000)
                        navigateToRegistrationHomeView = true
                    }
                } else {
                    // If a currentChild attribute (a child account) not found, navigate to RegistrationHomeView
                    try await Task.sleep(nanoseconds: 3_000_000_000)
                    navigateToRegistrationHomeView = true
                }
            } else {
                // If user is not signed in, navigate to LoginView
                try await Task.sleep(nanoseconds: 3_000_000_000) // 3-second delay
                navigateToLoginView = true
            }
        } catch {
            // Handle error (like network issue for instance)
            print("Failed to check user status: \(error)")
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            navigateToLoginView = true
        }
    }
}

#Preview {
    ContentView()
}

