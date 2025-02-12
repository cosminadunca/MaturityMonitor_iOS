// Account View comments and messages done - needs testing

import SwiftUI
import Amplify

struct AccountView: View {
    private let amplifyService = AmplifyService()

    @Binding var currentPage: String
    @State private var showMenu = false
    @State private var expandedSections: Set<UUID> = []
    @State private var email: String = ""
    @State private var oldPassword: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    @State private var showMessage: Bool = false
    @State private var messageText: String = ""
    @State private var isSuccessMessage: Bool = false
    @State private var isLoggedOut: Bool = false
    @State private var name: String = ""
    @State private var surname: String = ""

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack {
                    HStack {
                        Text("Account")
                            .font(Font.custom("Inter-Regular", size: 20))
                            .foregroundColor(.black)
                        Spacer()
                        Button(action: { showMenu = true }) {
                            Image(systemName: "line.horizontal.3")
                                .font(Font.custom("Inter", size: 35))
                                .foregroundColor(.black)
                                .padding(.leading, 8)
                        }
                    }
                    .padding()
                    .padding(.top, 70)

                    // Display user's name and surname
                    Text("\(name) \(surname)")
                        .font(Font.custom("Inter-Regular", size: 25))
                        .foregroundColor(.black)
                        .padding(.vertical, 25)

                    // Expandable Menu
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(menuItems) { item in
                                DisclosureGroup(
                                    isExpanded: Binding(
                                        get: { expandedSections.contains(item.id) },
                                        set: { isExpanded in
                                            if isExpanded {
                                                expandedSections.insert(item.id)
                                            } else {
                                                expandedSections.remove(item.id)
                                            }
                                        }
                                    ),
                                    content: {
                                        VStack {
                                            if item.title == "Change Password" {
                                                changePasswordSection()
                                            } else if item.title == "Logout" {
                                                logoutSection()
                                            }
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 4)
                                    },
                                    label: {
                                        HStack {
                                            Text(item.title)
                                                .font(.headline)
                                                .foregroundColor(.black)
                                            Spacer()
                                            Image(systemName: expandedSections.contains(item.id) ? "chevron.up" : "chevron.down")
                                                    .foregroundColor(.black)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                    if showMessage {
                        if isSuccessMessage {
                            SuccessCustomText(title: messageText)
                                .padding(.top, 10)
                        } else {
                            ErrorCustomText(title: messageText)
                                .padding(.top, 10)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.top)
                .fullScreenCover(isPresented: $showMenu) {
                    FullScreenMenuView(currentPage: $currentPage)
                }
                .navigationDestination(isPresented: $isLoggedOut) {
                    LoginView()
                }
                .onAppear {
                    Task {
                        if let userDetails = await amplifyService.fetchUserAttributes() {
                            name = userDetails.firstName
                            surname = userDetails.lastName
                        }
                    }
                }
                .navigationBarBackButtonHidden(true)
            }
        } else {
            // Fallback on earlier versions
        }
    }

    @ViewBuilder
    private func changePasswordSection() -> some View {
        VStack(spacing: 20) {
            CustomPasswordField(placeholder: "Enter old password", text: $oldPassword)
            CustomPasswordField(placeholder: "Enter new password", text: $password)
            CustomPasswordField(placeholder: "Re-enter new password", text: $confirmPassword)
            Button(action: {
                Task { await handleButtonPress(for: "Change Password") }
            }) {
                Text("Save")
                    .font(Font.custom("Inter", size: 15))
                    .foregroundColor(.white)
                    .frame(width: 130, height: 35)
                    .background(Color(red: 0.48, green: 0.12, blue: 0.64))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.25), radius: 4, y: 4)
            }
        }
    }

    @ViewBuilder
    private func logoutSection() -> some View {
        Button(action: {
            Task { await handleButtonPress(for: "Logout") }
        }) {
            Text("Logout")
                .font(Font.custom("Inter", size: 15))
                .foregroundColor(.white)
                .frame(width: 130, height: 35)
                .background(Color(red: 0.48, green: 0.12, blue: 0.64))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.25), radius: 4, y: 4)
        }
    }

    func handleButtonPress(for title: String) async {
        switch title {
        case "Change Password":
            guard password == confirmPassword,
                  !password.isEmpty,
                  !confirmPassword.isEmpty,
                  !oldPassword.isEmpty else {
                showMessage = true
                isSuccessMessage = false
                messageText = "Passwords do not match or are empty"
                return
            }
            let success = await amplifyService.changePassword(oldPassword: oldPassword, newPassword: password)
            showMessage = true
            isSuccessMessage = success
            messageText = success ? "Password changed successfully" : "Failed to change password"

            if success {
                // Clear the password fields
                oldPassword = ""
                password = ""
                confirmPassword = ""
            }
        case "Logout":
            let success = await amplifyService.signOut()
            isLoggedOut = success
            showMessage = !success
            isSuccessMessage = false
            messageText = "Logout failed"
        default:
            break
        }
    }
}

// Sample data model for the menu items with customizable content
struct MenuItem: Identifiable {
    var id = UUID()
    var title: String
    var content: [SectionContent]
}

struct SectionContent {
    var textFieldTitle: String?
    var buttonTitle: String?
}

let menuItems = [
    MenuItem(title: "Change Password", content: [
        SectionContent(textFieldTitle: "Enter old password"),
        SectionContent(textFieldTitle: "Enter new password"),
        SectionContent(textFieldTitle: "Re-enter new password", buttonTitle: "Save")
    ]),
    MenuItem(title: "Logout", content: [
        SectionContent(buttonTitle: "Logout")
    ])
]

#Preview {
    AccountView(currentPage: .constant("account"))
}
