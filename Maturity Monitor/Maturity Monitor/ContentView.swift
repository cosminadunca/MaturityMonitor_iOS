import SwiftUI
import Amplify
import Mixpanel
import AWSCognitoAuthPlugin

struct ContentView: View {
    private let amplifyService = AmplifyService()
    
    @State private var navigateToLoginView = false
    @State private var navigateToHomeView = false
    @State private var navigateToRegistrationHomeView = false
    
    // Mixpanel variables
    @State private var startTime = Date()  // Track when the view appears
    @State private var viewStartTime = Date()  // Track start time for this specific view

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {  // Use NavigationStack here instead of NavigationView
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
                    startTime = Date()
                    viewStartTime = Date()
                    Task {
                        //await amplifyService.signOut()
                        await checkUserStatus()
                    }
                }
                .onDisappear {
                    trackViewTime()  // Track the time when the view disappears
                }
                .background(
                    Group {
                        NavigationLink(destination: LoginView(), isActive: $navigateToLoginView) {
                            EmptyView()
                        }
                        NavigationLink(
                            destination: HomeView(
                                currentPage: .constant("home")
                            ),
                            isActive: $navigateToHomeView
                        ) {
                            EmptyView()
                        }
                        NavigationLink(destination: RegistrationHomeView(), isActive: $navigateToRegistrationHomeView) {
                            EmptyView()
                        }
                    }
                )
            }
            .navigationBarHidden(true)
        } else {
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
                    startTime = Date()
                    viewStartTime = Date()
                    Task {
                        //await amplifyService.signOut()
                        await checkUserStatus()
                    }
                                
                }
                .onDisappear {
                    trackViewTime()  // Track the time when the view disappears
                }
                .background(
                    Group {
                        NavigationLink(destination: LoginView(), isActive: $navigateToLoginView) {
                            EmptyView()
                        }
                        NavigationLink(
                            destination: HomeView(
                                currentPage: .constant("home")
                            ),
                            isActive: $navigateToHomeView
                        ) {
                            EmptyView()
                        }
                        NavigationLink(destination: RegistrationHomeView(), isActive: $navigateToRegistrationHomeView) {
                            EmptyView()
                        }
                    }
                )
            }
        }
    }
    
    // Track the time spent on the current view
    private func trackViewTime() {
        let timeSpent = Date().timeIntervalSince(viewStartTime)
        Mixpanel.mainInstance().track(event: "MIX Content View Time", properties: ["time_spent": timeSpent])
    }
    
    // Check user status to figure out where to redirect the opening page
    func checkUserStatus() async {
        let duration = Date().timeIntervalSince(startTime)  // Initialize duration
        do {
            if await amplifyService.isUserSignedIn() {
                if let currentChild = try await amplifyService.getCurrentChild() {
                    if currentChild != "-" {
                        // If user is signed in and has a currentChild (a child account linked to it), navigate to HomeView
                        Mixpanel.mainInstance().track(event: "MIX Returning User", properties: [
                            "Launch Duration": duration
                        ])
                        try await Task.sleep(nanoseconds: 3_000_000_000)
                        navigateToHomeView = true
                    } else {
                        // If user is signed in but does not have a currentChild (a child account linked to it), navigate to RegistrationHomeView
                        Mixpanel.mainInstance().track(event: "MIX Signed-in User With No Child Assigned", properties: [
                            "Launch Duration": duration
                        ])
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
                Mixpanel.mainInstance().track(event: "MIX New User or Signed Out User", properties: [
                    "Launch Duration": duration
                ])
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

