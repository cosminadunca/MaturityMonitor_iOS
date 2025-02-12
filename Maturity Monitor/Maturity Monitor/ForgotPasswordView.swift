// Forgot Password View comments and messages done - needs testing

import SwiftUI
import Amplify // For AuthError

struct ForgotPasswordView: View {
    
    // Access to Amplify functions
    let amplifyService = AmplifyService()
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var verificationCode: String = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @Binding var isPresented: Bool // Controls dismissal of the fullScreenCover
    
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
                            CustomTextField(iconName: "envelope", placeholder: "Enter your email", text: $email, keyboardType: .emailAddress)
                            
                            // Verification code button
                            Button(action: {
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
                                    placeholder: "Enter verification code",
                                    text: $verificationCode,
                                    keyboardType: .numberPad
                                )
                                .onSubmit {
                                    hideKeyboard() // Hides the keyboard when "Done" is pressed
                                }
                                .onChange(of: verificationCode) { newValue in
                                    // Filter out non-digit characters
                                    let filtered = newValue.filter { $0.isNumber }
                                    
                                    // Limit the code to 6 digits
                                    if filtered.count <= 6 {
                                        verificationCode = filtered
                                    } else {
                                        verificationCode = String(filtered.prefix(6))
                                    }
                                }
                                
                                CustomPasswordField(placeholder: "Reset password", text: $password)
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
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 10)
        }
    }
    
    func resetPasswordAction() {
        Task {
            do {
                let resetStep = try await amplifyService.resetPassword(username: email)
                switch resetStep {
                case .confirmResetPasswordWithCode(_, _):
                    successMessage = "Verification code sent!"
                case .done:
                    successMessage = "Password reset completed!"
                }
            } catch let error as AuthError {
                errorMessage = amplifyService.handleAuthError(error)
            } catch {
                errorMessage = "Unexpected error: \(error.localizedDescription)"
            }
        }
    }

    func confirmResetPasswordAction() {
        Task {
            do {
                try await amplifyService.confirmResetPassword(username: email, newPassword: password, confirmationCode: verificationCode)
                successMessage = "Password reset confirmed!"
                
                DispatchQueue.main.async {
                    isPresented = false
                }
            } catch let error as AuthError {
                errorMessage = amplifyService.handleAuthError(error)
            } catch {
                errorMessage = "Unexpected error: \(error.localizedDescription)"
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
