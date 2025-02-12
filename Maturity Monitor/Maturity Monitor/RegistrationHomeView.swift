// Registration Home View comments and messages done - needs testing

import SwiftUI

struct RegistrationHomeView: View {
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack {
                    Spacer()
                    // Navigate to AddChildStepOneView
                    NavigationLink(destination: AddChildStepOneView()) {
                        CustomRegistrationButton(title: "Add new child", iconName: "plus")
                    }
                    .padding(.bottom, 12) // Optional padding between buttons
                    // Navigate to RequestChildAccessView
                    NavigationLink(destination: RequestChildAccessView()) {
                        CustomRegistrationButton(title: "Link existing account", iconName: "person.fill.badge.plus")
                    }
                    .padding(.bottom, 12) // Optional padding between buttons
                    // Navigate to RequestGroupAccessView
                    NavigationLink(destination: RequestGroupAccessView()) {
                        CustomRegistrationButton(title: "Link existing group", iconName: "person.3.fill")
                    }
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    RegistrationHomeView()
}
