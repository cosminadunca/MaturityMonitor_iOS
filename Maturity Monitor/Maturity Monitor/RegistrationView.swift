import SwiftUI
import Amplify
import Mixpanel

struct RegistrationView: View {
    // Access to Amplify functions
    let amplifyService = AmplifyService()

    @State private var name = ""
    @State private var surname = ""
    @State private var email = ""
    @State private var reEmail = ""
    @State private var password = ""

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showConfirmationView = false
    
    // Mixpanel variables
    @State private var viewStartTime: Date = Date()
    @State private var passwordToggleCount = 0 

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Spacer()
                    CustomTextTitle(title: "Registration")
                    Spacer()
                    VStack(spacing: 20) {
                        CustomTextField(
                            iconName: "person.fill",
                            placeholder: "Name",
                            text: $name,
                            viewName: "Registration",
                            keyboardType: .default
                        )
                        CustomTextField(
                            iconName: "person.fill",
                            placeholder: "Surname",
                            text: $surname,
                            viewName: "Registration",
                            keyboardType: .default
                        )
                        CustomTextField(
                            iconName: "envelope",
                            placeholder: "Email",
                            text: $email,
                            viewName: "Registration",
                            keyboardType: .emailAddress
                        )
                        CustomTextField(
                            iconName: "envelope",
                            placeholder: "Re-enter Email",
                            text: $reEmail,
                            viewName: "Registration",
                            keyboardType: .emailAddress
                        )
                        CustomPasswordField(
                            placeholder: "Password",
                            text: $password,
                            viewName: "Registration",
                            passwordToggleCount: $passwordToggleCount
                        )
                    }
                    Spacer()
                    Spacer()

                    if let errorMessage = errorMessage {
                        ErrorCustomText(title: errorMessage)
                    }

                    VStack(spacing: 20) {
                        Button(action: {
                            validateAndSignUp()
                        }) {
                            CustomButton(
                                title: "Sign Up",
                                backgroundColor: Color(.buttonPurpleLight),
                                textColor: .white
                            )
                        }.disabled(isLoading)

                        NavigationLink(destination: LoginView()) {
                            Text("Already have an account?")
                                .font(Font.custom("Inter", size: 15))
                                .foregroundColor(.black)
                        }
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                Mixpanel.mainInstance().track(event: "MIX Login Link Tapped", properties: [
                                    "email": email
                                ])
                            }
                        )
                        NavigationLink(
                            destination: VerificationCodeView(email: $email, password: $password),
                            isActive: $showConfirmationView
                        ) {
                            EmptyView()
                        }
                    }
                }
                .onAppear {
                    viewStartTime = Date()
                }
                .onDisappear {
                    // Track Mixpanel event for password toggle count when view disappears
                    Mixpanel.mainInstance().track(event: "MIX Password Visibility Toggle Count in Registration View", properties: [
                        "toggle_count": passwordToggleCount
                    ])
                    trackViewTime()
                }
                .onTapGesture {
                    hideKeyboard() // Hide keyboard when tapping outside
                }
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        HStack {
                            Spacer()
                            Button("Done") {
                                hideKeyboard()
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                if isLoading {
                    ProgressView("Signing Up...")
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .edgesIgnoringSafeArea(.top)
        }.navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
    
    // Mixpanel tracking
    private func trackViewTime() {
        let timeSpent = Date().timeIntervalSince(viewStartTime)
        Mixpanel.mainInstance().track(event: "MIX Registration View Time", properties: ["time_spent": timeSpent])
    }

    private func validateAndSignUp() {
        // Check if any of the fields are empty
        guard !name.isEmpty, !surname.isEmpty, !email.isEmpty, !reEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill all fields!"
            // Track failure event for empty fields
            Mixpanel.mainInstance().track(event: "MIX Sign Up Failed - Empty Fields", properties: [
                "name_empty": name.isEmpty,
                "surname_empty": surname.isEmpty,
                "email_empty": email.isEmpty,
                "reEmail_empty": reEmail.isEmpty,
                "password_empty": password.isEmpty
            ])
            return
        }

        // Check if the email addresses match
        guard email.trimmingCharacters(in: .whitespaces) == reEmail.trimmingCharacters(in: .whitespaces) else {
            errorMessage = "Email addresses do not match!"
            // Track failure event for email mismatch
            Mixpanel.mainInstance().track(event: "MIX Sign Up Failed - Email Mismatch", properties: [
                "email": email,
                "reEmail": reEmail
            ])
            return
        }

        // Validate email format
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address!"
            // Track failure event for invalid email
            Mixpanel.mainInstance().track(event: "MIX Sign Up Failed - Invalid Email", properties: [
                "email": email
            ])
            return
        }

        // Proceed with signing up if everything is valid
        errorMessage = "" // Clear any previous error message
        Task {
            // Call the signUp function and handle the result
            let signUpResult = await amplifyService.signUp(username: email, password: password, userAttributes: createUserAttributes())
            switch signUpResult {
            case .success:
                // Track success event when sign-up is successful
                Mixpanel.mainInstance().track(event: "MIX Sign Up Successful", properties: [
                    "email": email,
                    "name": name,
                    "surname": surname
                ])
                showConfirmationView = true
            case .failure(let error):
                errorMessage = amplifyService.handleAuthError(error as! AuthError)
                // Track failure event for sign-up failure
                Mixpanel.mainInstance().track(event: "MIX Sign Up Failed", properties: [
                    "error_message": errorMessage,
                    "email": email
                ])
            }
        }
    }

    private func createUserAttributes() -> [AuthUserAttribute] {
        return [
            AuthUserAttribute(.email, value: email.trimmingCharacters(in: .whitespaces)),
            AuthUserAttribute(.custom("firstName"), value: name.trimmingCharacters(in: .whitespaces)),
            AuthUserAttribute(.custom("lastName"), value: surname.trimmingCharacters(in: .whitespaces)),
            AuthUserAttribute(.custom("currentChild"), value: "-")
        ]
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

#Preview {
    RegistrationView()
}
