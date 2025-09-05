// Registration Home View comments and messages done - needs testing

import SwiftUI
import Mixpanel

struct RegistrationHomeView: View {
    
    @State private var viewStartTime: Date = Date()
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack {
                    Spacer()
                    // Navigate to AddChildStepOneView
                    NavigationLink(destination: AddChildStepOneView()) {
                        CustomRegistrationButton(title: "Add new child", iconName: "plus")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        Mixpanel.mainInstance().track(event: "MIX Add new child button pressed", properties: [
                            "timestamp": Date().description
                        ])
                    })
                    .padding(.bottom, 12) // Optional padding between buttons
                    // Navigate to RequestChildAccessView
                    NavigationLink(destination: RequestChildAccessView()) {
                        CustomRegistrationButton(title: "Link existing account", iconName: "person.fill.badge.plus")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        Mixpanel.mainInstance().track(event: "MIX Link existing account button pressed", properties: [
                            "timestamp": Date().description
                        ])
                    })
                    .padding(.bottom, 12) // Optional padding between buttons
                    NavigationLink(destination: RequestGroupAccessView()) {
                        CustomRegistrationButton(title: "Link existing group", iconName: "person.3.fill")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        Mixpanel.mainInstance().track(event: "MIX Link existing group button pressed", properties: [
                            "timestamp": Date().description
                        ])
                    })

                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .onAppear {
                // Set the start time when the view appears
                viewStartTime = Date()
            }
            .onDisappear {
                // Track the time spent on this view when it disappears
                trackViewTime()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    // Mixpanel tracking
    private func trackViewTime() {
        let timeSpent = Date().timeIntervalSince(viewStartTime)
        Mixpanel.mainInstance().track(event: "MIX Registration Home View Time", properties: ["time_spent": timeSpent])
    }
}

#Preview {
    RegistrationHomeView()
}
