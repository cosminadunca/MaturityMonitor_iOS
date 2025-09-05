import SwiftUI
import Amplify
import Mixpanel

struct VerificationCodeView: View {
    
    // Access to Amplify functions
    let amplifyService = AmplifyService()
    
    @Binding var email: String
    @Binding var password: String
    @State private var verificationCode: String = ""
    
    @State private var isVerificationSuccessful: Bool = false
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    
    // Mixpanel variables
    @State private var viewStartTime: Date = Date()
    @State private var resendCount: Int = 0
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                ZStack {
                    ZStack {
                        // Second Rectangle (Form content)
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 370, height: 480)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 0.62, green: 0.62, blue: 0.62).opacity(0.80), lineWidth: 2)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                VStack(spacing: 20) {
                                    Spacer()
                                    Spacer()
                                    Text("Please enter below the verification code sent to your email address:")
                                        .font(Font.custom("Inter", size: 15))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 30)
                                    
                                    CustomTextField(
                                        iconName: "checkmark.circle.badge.questionmark",
                                        placeholder: "Verification Code",
                                        text: $verificationCode,
                                        viewName: "Verification Code",
                                        keyboardType: .numberPad
                                    )
                                    .onSubmit {
                                        // Filter out non-digit characters
                                        let filtered = verificationCode.filter { $0.isNumber }
                                        
                                        // Limit the code to 6 digits
                                        if filtered.count <= 6 {
                                            verificationCode = filtered
                                        } else {
                                            verificationCode = String(filtered.prefix(6))
                                        }
                                    }

                                    Text("Re-enter your email address:")
                                        .font(Font.custom("Inter", size: 15))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 30)
                                    CustomTextField(iconName: "envelope", placeholder: "Email", text: $email, viewName: "Verification Code", keyboardType: .emailAddress)
                                    Spacer()
                                    
                                    if let errorMessage = errorMessage {
                                        ErrorCustomText(title: errorMessage)
                                    }
                                        
                                    if let successMessage = successMessage {
                                        SuccessCustomText(title: successMessage)
                                    }
                                    HStack(spacing: 15) {
                                        Button(action: {
                                            resendCount += 1
                                            Task {
                                                await resendConfirmationCode(for: email)
                                            }
                                        }) {
                                            CustomButton(
                                                title: "Resend",
                                                backgroundColor: Color(.buttonGreyLight),
                                                textColor: .black
                                            )
                                        }
                                        Button(action: {
                                            Task {
                                                await confirmSignUp(for: email, with: verificationCode)
                                            }
                                        }) {
                                            CustomButton(
                                                title: "Verify",
                                                backgroundColor: Color(.buttonPurpleLight),
                                                textColor: .white
                                            )
                                        }
                                    }.padding(.bottom, 10)
                                    Spacer()
                                })
                    }
                    
                    // First Rectangle (Header) on top
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 370, height: 45)
                        .background(Color(.tabviewPurpleDark))
                        .overlay(
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.white)
                                    .padding(.leading, 10)
                                
                                Text("Verify your email")
                                    .font(Font.custom("Inter", size: 15))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                                .padding(.leading, 10)
                        )
                        .offset(y: -220)
                }
                .onTapGesture {
                    hideKeyboard() // Hide keyboard when tapping outside
                }
                .onAppear {
                    // Set the start time when the view appears
                    viewStartTime = Date()
                }
                .onDisappear {
                    // Track the time spent on this view when it disappears
                    trackViewTime()
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
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 10)
                
                // NavigationLink to RegistrationHomeView
                NavigationLink(
                    destination: RegistrationHomeView(),
                    isActive: $isVerificationSuccessful
                ) {
                    EmptyView()
                }
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarBackButtonHidden(true)
        } else {
            // Fallback on earlier versions
        }
    }
    
    // Mixpanel tracking
    private func trackViewTime() {
        let timeSpent = Date().timeIntervalSince(viewStartTime)
        Mixpanel.mainInstance().track(event: "MIX Verification View Time", properties: ["time_spent": timeSpent])
    }
        
    func confirmSignUp(for email: String, with confirmationCode: String) async {
        do {
            let isSignUpComplete = try await amplifyService.confirmSignUp(email: email, confirmationCode: confirmationCode)
            if isSignUpComplete {
                await signIn(username: email, password: password)
                // Track successful sign-up confirmation with Mixpanel
                Mixpanel.mainInstance().track(event: "MIX SignUp Confirmation Success", properties: [
                    "email": email
                ])
            }
        } catch let error as AuthError {
            DispatchQueue.main.async {
                self.errorMessage = amplifyService.handleAuthError(error)
                self.successMessage = nil  // Clear success message if error occurs
            }
            // Track sign-up confirmation failure with Mixpanel
            Mixpanel.mainInstance().track(event: "MIX SignUp Confirmation Failed", properties: [
                "email": email,
                "error": error.localizedDescription
            ])
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "An unexpected error occurred."
                self.successMessage = nil  // Clear success message if error occurs
            }
            // Track unexpected error with Mixpanel
            Mixpanel.mainInstance().track(event: "MIX SignUp Confirmation Failed", properties: [
                "email": email,
                "error": "An unexpected error occurred."
            ])
        }
    }
        
    func signIn(username: String, password: String) async {
        do {
            let isSignedIn = try await amplifyService.signIn(username: username, password: password)
            if isSignedIn {
                DispatchQueue.main.async {
                    self.isVerificationSuccessful = true
                }
                // Track successful sign-in with Mixpanel
                Mixpanel.mainInstance().track(event: "MIX SignIn Success", properties: [
                    "username": username
                ])
            }
        } catch let error as AuthError {
            DispatchQueue.main.async {
                self.errorMessage = amplifyService.handleAuthError(error)
                self.successMessage = nil
            }
            // Track sign-in failure with Mixpanel
            Mixpanel.mainInstance().track(event: "MIX SignIn Failed", properties: [
                "username": username,
                "error": error.localizedDescription
            ])
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "An unexpected error occurred."
                self.successMessage = nil
            }
            // Track unexpected error with Mixpanel
            Mixpanel.mainInstance().track(event: "MIX SignIn Failed", properties: [
                "username": username,
                "error": "An unexpected error occurred."
            ])
        }
    }
        
    // Function to resend the confirmation code
    func resendConfirmationCode(for email: String) async {
        do {
            try await amplifyService.resendConfirmationCode(email: email)
            DispatchQueue.main.async {
                self.successMessage = "A new confirmation code has been sent to your email! Please be patient with receiving the code as somethimes it takes a bit longer. Thanks!"
                self.errorMessage = nil  // Clear error message if resend is successful
            }
            // Track resend success with Mixpanel
            Mixpanel.mainInstance().track(event: "MIX Confirmation Code Resent", properties: [
                "email": email
            ])
        } catch let error as AuthError {
            DispatchQueue.main.async {
                self.errorMessage = amplifyService.handleAuthError(error)
                self.successMessage = nil
            }
            // Track resend failure with Mixpanel
            Mixpanel.mainInstance().track(event: "MIX Resend Confirmation Failed", properties: [
                "email": email,
                "error": error.localizedDescription
            ])
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "An unexpected error occurred."
                self.successMessage = nil
            }
            // Track unexpected error with Mixpanel
            Mixpanel.mainInstance().track(event: "MIX Resend Confirmation Failed", properties: [
                "email": email,
                "error": "An unexpected error occurred."
            ])
        }
    }
}

// Preview Provider for the VerificationCodeView
struct VerificationCodeView_Previews: PreviewProvider {
    static var previews: some View {
        // Set up sample bindings for preview
        let email = Binding.constant("test@example.com")
        let password = Binding.constant("password123")
        
        VerificationCodeView(email: email, password: password)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
