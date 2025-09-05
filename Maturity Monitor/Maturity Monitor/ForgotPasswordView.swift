import SwiftUI
import Amplify // For AuthError
import Mixpanel

struct ForgotPasswordView: View {
    
    // Access to Amplify functions
    let amplifyService = AmplifyService()
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var verificationCode: String = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @Binding var isPresented: Bool // Controls dismissal of the fullScreenCover
    
    // Mixpanel variables
    @State private var viewStartTime = Date()
    @State private var sendCodeButtonPressCount = 0
    @State private var passwordToggleCount = 0
    
    var body: some View {
        ZStack {
            Color.clear
                .onTapGesture {
                hideKeyboard()
            }
            ZStack {
                // Second Rectangle (Reset password form content)
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 375, height: 550)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 0.62, green: 0.62, blue: 0.62).opacity(0.80), lineWidth: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        VStack(spacing: 15) {
                            
                            Spacer()
                            Text("Enter your email address to get the verification code:")
                                .font(Font.custom("Inter", size: 15))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                            
                            CustomTextField(
                                iconName: "envelope",
                                placeholder: "Email",
                                text: $email,
                                viewName: "Forgot Password",
                                keyboardType: .emailAddress
                            )
                            
                            // Verification code button
                            Button(action: {
                                Mixpanel.mainInstance().track(event: "MIX Send Code Pressed in Forgot Password View", properties: [
                                    "timestamp": Date().description, // Optionally track the time of the press
                                    "action": "send_verification_code" // Descriptive property to identify the action
                                ])
                                resetPasswordAction()
                            }) {
                                CustomButton(
                                    title: "Send code",
                                    backgroundColor: Color(.buttonPurpleLight),
                                    textColor: .white
                                )
                            }
                            .padding()
                            Spacer()
                            
                            VStack(spacing: 20) {
                                // Verification code field
                                CustomTextField(
                                    iconName: "checkmark.circle.badge.questionmark",
                                    placeholder: "Verification Code",
                                    text: $verificationCode,
                                    viewName: "Forgot Password",
                                    keyboardType: .numberPad
                                )
                                .onSubmit {
                                    // Filter out non-digit characters and limit the code to 6 digits
                                    let filtered = verificationCode.filter { $0.isNumber }
                                    if filtered.count <= 6 {
                                        verificationCode = filtered
                                    } else {
                                        verificationCode = String(filtered.prefix(6))
                                    }
                                }
                                CustomPasswordField(
                                    placeholder: "Reset password",
                                    text: $password,
                                    viewName: "Forgot Password",
                                    passwordToggleCount: $passwordToggleCount
                                )
                            }
                            .padding()
                            Spacer()
                            
                            // Display either the error or success message
                            if !errorMessage.isEmpty {
                                ErrorCustomText(title: errorMessage)
                            } else if !successMessage.isEmpty {
                                SuccessCustomText(title: successMessage)
                            }
                            
                            // Cancel and Reset buttons
                            HStack(spacing: 15) {
                                Button(action: {
                                    // Track the event when the Cancel button is pressed
                                    Mixpanel.mainInstance().track(event: "MIX Cancel Button Pressed in Forgot Password View")
                                    isPresented = false
                                }) {
                                    CustomButton(
                                        title: "Cancel",
                                        backgroundColor: Color(.buttonGreyLight),
                                        textColor: .black
                                    )
                                }

                                Button(action: {
                                    confirmResetPasswordAction()
                                }) {
                                    CustomButton(
                                        title: "Reset",
                                        backgroundColor: Color(.buttonPurpleLight),
                                        textColor: .white
                                    )
                                }
                            }
                        }
                        .padding(.vertical, 40)
                        .padding(.bottom, 20)
                        .padding(.top, 50)
                    )
                
                // First Rectangle (Header) on top
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 375, height: 45)
                    .background(Color(.tabviewPurpleDark))
                    .overlay(
                        HStack {
                            Image(systemName: "arrow.uturn.forward")
                                .foregroundColor(.white)
                                .padding(.leading, 10)
                            
                            Text("Reset Password")
                                .font(Font.custom("Inter", size: 15))
                                .foregroundColor(.white)
                            
                            Spacer() // Push the content to the left
                        }
                        .padding(.leading, 10)
                        .padding(.top, 5)
                    )
                    .offset(y: -255)
            }
            .onAppear{
                viewStartTime = Date()
            }
            .onDisappear {
                Mixpanel.mainInstance().track(event: "MIX Password Visibility Toggle Count in Forgot Password View", properties: [
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
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 10)
        }
    }
    
    // Mixpanel Functions
    private func trackViewTime() {
        let timeSpent = Date().timeIntervalSince(viewStartTime)
        Mixpanel.mainInstance().track(event: "MIX Forgot Password Sheet Time", properties: ["time_spent": timeSpent])
    }
    
    func resetPasswordAction() {
        Task {
            do {
                let resetStep = try await amplifyService.resetPassword(username: email)

                switch resetStep {
                case .confirmResetPasswordWithCode(_, _):
                    successMessage = "Verification code sent!"
                    
                    Mixpanel.mainInstance().track(event: "MIX Reset Password Code Sent in Forgot Password View", properties: [
                        "email": email,
                        "view": "Login View"
                    ])

                case .done:
                    successMessage = "Password reset completed!"
                }

            } catch let error as AuthError {
                let reason = amplifyService.handleAuthError(error) ?? "Unknown AuthError"
                errorMessage = reason

                Mixpanel.mainInstance().track(event: "MIX Reset Password Code Failure in Forgot Password View", properties: [
                    "email": email,
                    "view": "Login View",
                    "reason": reason
                ])

            } catch {
                errorMessage = "Unexpected error: \(error.localizedDescription)"

                Mixpanel.mainInstance().track(event: "MIX Reset Password Code Failure in Forgot Password View", properties: [
                    "email": email,
                    "view": "Login View",
                    "reason": error.localizedDescription
                ])
            }
        }
    }

    func confirmResetPasswordAction() {
        Task {
            do {
                try await amplifyService.confirmResetPassword(username: email, newPassword: password, confirmationCode: verificationCode)
                successMessage = "Password reset confirmed!"
                
                // Track success event for reset confirmation
                Mixpanel.mainInstance().track(event: "MIX Password Reset Confirmed Successfully")

                // Close the view after success
                DispatchQueue.main.async {
                    isPresented = false
                }

            } catch let error as AuthError {
                errorMessage = amplifyService.handleAuthError(error)
                
                // Track failure event for reset confirmation failure
                Mixpanel.mainInstance().track(event: "MIX Password Reset Confirmation Failed", properties: [
                    "error": error.errorDescription
                ])
            } catch {
                errorMessage = "Unexpected error: \(error.localizedDescription)"
                
                // Track failure event for general reset confirmation error
                Mixpanel.mainInstance().track(event: "MIX Password Reset Confirmation Failed", properties: [
                    "error": error.localizedDescription
                ])
            }
        }
    }
}

extension View {
    /// Dismisses the keyboard.
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    // For preview, use a constant value
    ForgotPasswordView(isPresented: .constant(true))
}
