// Improvements:
// 1. Allow uploading pictures to account so that other people know how added entries or modified things, etc
// Registration View comments and messages done - needs testing

import SwiftUI
import Amplify

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

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Spacer()
                    CustomTextTitle(title: "Registration")
                    Spacer()
                    VStack(spacing: 20) {
                        CustomTextField(iconName: "person.fill", placeholder: "Name", text: $name)
                            .onChange(of: name) { _ in
                                        trackFieldInteraction(fieldName: "Name")
                                    }
                        CustomTextField(iconName: "person.fill", placeholder: "Surname", text: $surname)
                            .onChange(of: surname) { _ in
                                        trackFieldInteraction(fieldName: "Surname")
                                    }
                        CustomTextField(iconName: "envelope", placeholder: "Email", text: $email, keyboardType: .emailAddress)
                            .onChange(of: email) { _ in
                                        trackFieldInteraction(fieldName: "Email")
                                    }
                        CustomTextField(iconName: "envelope", placeholder: "Re-enter Email", text: $reEmail, keyboardType: .emailAddress)
                            .onChange(of: reEmail) { _ in
                                        trackFieldInteraction(fieldName: "Re-enter Email")
                                    }
                        CustomPasswordField(placeholder: "Password", text: $password)
                            .onChange(of: password) { _ in
                                        trackFieldInteraction(fieldName: "Password")
                                    }
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
                        
                        NavigationLink(
                            destination: VerificationCodeView(email: $email, password: $password),
                            isActive: $showConfirmationView
                        ) {
                            EmptyView()
                        }
                    }
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
    
    // Helper function for tracking field interactions
    private func trackFieldInteraction(fieldName: String) {
        let event = BasicAnalyticsEvent(name: "SignUpFieldInteraction",
                                        properties: ["Field": fieldName])
        Amplify.Analytics.record(event: event)
        print("Tracked: User interacted with \(fieldName) field")
    }
    
    private func validateAndSignUp() {
        // Check if any of the fields are empty
        guard !name.isEmpty, !surname.isEmpty, !email.isEmpty, !reEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill all fields!"

            // Track Failed Sign-up: Missing Fields
            let failedSignUpEvent = BasicAnalyticsEvent(name: "SignUp",
                                                        properties: ["Status": "Failed",
                                                                     "Reason": "Missing Fields"])
            Amplify.Analytics.record(event: failedSignUpEvent)
            print("Tracked: Failed Sign-up (Missing Fields)")

            return
        }

        // Check if the email addresses match
        guard email.trimmingCharacters(in: .whitespaces) == reEmail.trimmingCharacters(in: .whitespaces) else {
            errorMessage = "Email addresses do not match!"

            // Track Failed Sign-up: Email Mismatch
            let failedSignUpEvent = BasicAnalyticsEvent(name: "SignUp",
                                                        properties: ["Status": "Failed",
                                                                     "Reason": "Email Mismatch"])
            Amplify.Analytics.record(event: failedSignUpEvent)
            print("Tracked: Failed Sign-up (Email Mismatch)")

            return
        }

        // Validate email format
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address!"

            // Track Failed Sign-up: Invalid Email
            let failedSignUpEvent = BasicAnalyticsEvent(name: "SignUp",
                                                        properties: ["Status": "Failed",
                                                                     "Reason": "Invalid Email Format"])
            Amplify.Analytics.record(event: failedSignUpEvent)
            print("Tracked: Failed Sign-up (Invalid Email Format)")

            return
        }

        // Proceed with signing up if everything is valid
        errorMessage = "" // Clear any previous error message
        Task {
            // Call the signUp function and handle the result
            let signUpResult = await amplifyService.signUp(username: email, password: password, userAttributes: createUserAttributes())
            switch signUpResult {
            case .success:
                // Track Successful Sign-up
                let successEvent = BasicAnalyticsEvent(name: "SignUp",
                                                       properties: ["Status": "Success",
                                                                    "Email": email])
                Amplify.Analytics.record(event: successEvent)
                print("Tracked: Successful Sign-up")

                showConfirmationView = true // Show the confirmation view after successful signup

            case .failure(let error):
                errorMessage = amplifyService.handleAuthError(error as! AuthError)

                // Track Failed Sign-up with Error Details
                let failedSignUpEvent = BasicAnalyticsEvent(name: "SignUp",
                                                            properties: ["Status": "Failed",
                                                                         "ErrorMessage": error.localizedDescription,
                                                                         "Email": email])
                Amplify.Analytics.record(event: failedSignUpEvent)
                print("Tracked: Failed Sign-up (Error)")
            }
        }
    }

    // Create user attributes for sign up
    private func createUserAttributes() -> [AuthUserAttribute] {
        return [
            AuthUserAttribute(.email, value: email.trimmingCharacters(in: .whitespaces)),
            AuthUserAttribute(.custom("firstName"), value: name.trimmingCharacters(in: .whitespaces)),
            AuthUserAttribute(.custom("lastName"), value: surname.trimmingCharacters(in: .whitespaces)),
            AuthUserAttribute(.custom("currentChild"), value: "-")
        ]
    }

    // Email validation function using a regular expression
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

#Preview {
    RegistrationView()
}
