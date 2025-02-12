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
                        CustomTextField(iconName: "person.fill", placeholder: "Surname", text: $surname)
                        CustomTextField(iconName: "envelope", placeholder: "Email", text: $email, keyboardType: .emailAddress)
                        CustomTextField(iconName: "envelope", placeholder: "Re-enter Email", text: $reEmail, keyboardType: .emailAddress)
                        CustomPasswordField(placeholder: "Password", text: $password)
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
                if isLoading {
                    ProgressView("Signing Up...")
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .edgesIgnoringSafeArea(.top)
        }.navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
    
    private func validateAndSignUp() {
        // Check if any of the fields are empty
        guard !name.isEmpty, !surname.isEmpty, !email.isEmpty, !reEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill all fields!"
            return
        }

        // Check if the email addresses match
        guard email.trimmingCharacters(in: .whitespaces) == reEmail.trimmingCharacters(in: .whitespaces) else {
            errorMessage = "Email addresses do not match!"
            return
        }

        // Validate email format
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address!"
            return
        }
        
        // Proceed with signing up if everything is valid
        errorMessage = "" // Clear any previous error message
        Task {
            // Call the signUp function and handle the result
            let signUpResult = await amplifyService.signUp(username: email, password: password, userAttributes: createUserAttributes())
            switch signUpResult {
            case .success:
                showConfirmationView = true // Show the confirmation view after successful signup
            case .failure(let error):
                errorMessage = amplifyService.handleAuthError(error as! AuthError)
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
