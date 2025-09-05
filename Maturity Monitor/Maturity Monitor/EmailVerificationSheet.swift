import SwiftUI
import Amplify
import Mixpanel

struct EmailVerificationSheet: View {
    @Binding var isPresented: Bool
    let email: String
    
    @State private var code = ""
    @State private var errorMessage: String?
    @State private var isVerifying = false
    
    @State private var viewStartTime = Date()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                CustomTextTitle(title: "Verify Email")
                Spacer()
                Text("Enter the verification code sent to \(email)")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                CustomTextField(
                    iconName: "checkmark.circle.badge.questionmark",
                    placeholder: "Verification Code",
                    text: $code,
                    viewName: "Email Verification",
                    keyboardType: .numberPad
                )
                Spacer()
                Spacer()
                Spacer()
                if let error = errorMessage {
                    ErrorCustomText(title: error)
                }
                HStack(spacing: 15) {
                    Button(action: {
                        Task {
                            await resendCode()
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
                            await confirmEmail()
                        }
                    }) {
                        CustomButton(
                            title: "Confirm Email",
                            backgroundColor: Color(.buttonPurpleLight),
                            textColor: .white
                        )
                    }
                    .disabled(code.isEmpty || isVerifying)
                }
                .padding(.bottom, 15)

            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark") // Use "X" as an icon
                            .font(.title3)
                            .foregroundColor(.black)
                    }
                }
            }
            .onAppear {
                // Set the start time when the view appears
                viewStartTime = Date()
                Mixpanel.mainInstance().track(event: "MIX Email Verification Sheet Opened", properties: [
                    "email": email
                ])
                Task {
                    await resendCode()
                }
            }
            .onDisappear {
                // Track the time spent on this view when it disappears
                trackViewTime()
            }
        }
    }
    
    // Mixpanel functions
    private func trackViewTime() {
        let timeSpent = Date().timeIntervalSince(viewStartTime)
        Mixpanel.mainInstance().track(event: "MIX Email Verification Sheet Time", properties: [
            "time_spent": timeSpent
        ])
    }

    private func confirmEmail() async {
        isVerifying = true
        errorMessage = nil

        do {
            let result = try await Amplify.Auth.confirmSignUp(for: email, confirmationCode: code)
            
            // If the result is successful, treat it as verified
            Mixpanel.mainInstance().track(event: "MIX Email Verification Confirmed in Email Verification View", properties: [
                "email": email
            ])
            isPresented = false
            
        } catch {
            errorMessage = error.localizedDescription
            Mixpanel.mainInstance().track(event: "MIX Email Verification Failed in Email Verification View", properties: [
                "email": email,
                "error": error.localizedDescription
            ])
        }

        isVerifying = false
    }

    private func resendCode() async {
        do {
            _ = try await Amplify.Auth.resendSignUpCode(for: email)
            Mixpanel.mainInstance().track(event: "MIX Verification Code Resent in Email Verification View", properties: [
                "email": email
            ])
        } catch {
            errorMessage = "Failed to resend code: \(error.localizedDescription)"
            Mixpanel.mainInstance().track(event: "MIX Resend Verification Code Failed in Email Verification View", properties: [
                "email": email,
                "error": error.localizedDescription
            ])
        }
    }
}

struct EmailVerificationSheetView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerificationSheet(isPresented: .constant(true), email: "user@example.com")
    }
}
