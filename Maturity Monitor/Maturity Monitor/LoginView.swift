import SwiftUI
import Amplify
import Mixpanel

struct LoginView: View {
    
    // Access to Amplify functions
    private let amplifyService = AmplifyService()
    
    @State private var password = ""
    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showForgotPasswordSheet = false
    
    @State private var isSignedInForDefaultUser = false
    @State private var isSignedInForAdmin = false
    
    // State for email verification sheet
    @State private var showVerificationSheet = false
    
    // Mixpanel variables
    @State private var viewStartTime = Date()
    @State private var passwordToggleCount = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Spacer()
                    CustomTextTitle(title: "Login")
                    Spacer()
                    VStack(spacing: 20) {
                        CustomTextField(
                            iconName: "envelope",
                            placeholder: "Email",
                            text: $email,
                            viewName: "Login",
                            keyboardType: .emailAddress
                        )
                        
                        CustomPasswordField(
                            placeholder: "Password",
                            text: $password,
                            viewName: "Login",
                            passwordToggleCount: $passwordToggleCount
                        )
                    }
                    HStack {
                        Spacer()
                        Button(action: {
                            showForgotPasswordSheet.toggle()
                            trackForgotPasswordSheetOpened()
                        }) {
                            Text("Forgot password?")
                                .font(Font.custom("Inter", size: 12))
                                .foregroundColor(.black)
                                .padding()
                                .padding(.trailing, 25)
                        }
                    }
                    .fullScreenCover(isPresented: $showForgotPasswordSheet) {
                        let isPresented = $showForgotPasswordSheet
                        ForgotPasswordView(isPresented: isPresented)
                    }
                    .fullScreenCover(isPresented: $showVerificationSheet) {
                        let isPresented = $showVerificationSheet
                        EmailVerificationSheet(isPresented: isPresented, email: email)
                    }
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    if let errorMessage = errorMessage {
                        ErrorCustomText(title: errorMessage)
                    }
                    VStack(spacing: 20) {
                        Button(action: {
                            Task {
                                await signIn()
                            }
                        }) {
                            CustomButton(
                                title: "Sign In",
                                backgroundColor: Color(.buttonPurpleLight),
                                textColor: .white
                            )
                        }
                        .disabled(isLoading)
                        
                        NavigationLink(destination: RegistrationView()) {
                            Text("Don’t have an account yet?")
                                .font(Font.custom("Inter", size: 15))
                                .foregroundColor(.black)
                        }
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                // Track event for Registration link tap with sessionId and distinctId (email)
                                Mixpanel.mainInstance().track(event: "MIX Registration Link Tapped", properties: [
                                    "email": email
                                ])
                            }
                        )
                    }
                    .padding(.bottom, 40)
                    
                    // If user already has a currentChild attached to account go to HomeView
                    NavigationLink(
                        destination: HomeView(
                            currentPage: .constant("home")
                        ),
                        isActive: $isSignedInForDefaultUser
                    ) {
                        EmptyView()
                    }
                    
                    // If user doesn't have a currentChild attached to account go to RegistrationHomeView
                    NavigationLink(destination: RegistrationHomeView(), isActive: $isSignedInForAdmin) {
                        EmptyView()
                    }
                }
                .background(.white)
                .onTapGesture {
                    hideKeyboard() // Hide keyboard when tapping outside
                }
                .onAppear {
                    // Set the start time when the view appears
                    viewStartTime = Date()
                }
                .onDisappear {
                    // Track Mixpanel event for password toggle count when view disappears
                    Mixpanel.mainInstance().track(event: "MIX Password Visibility Toggle Count in Login View", properties: [
                        "toggle_count": passwordToggleCount
                    ])
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
                if isLoading {
                    ProgressView("Signing In...")
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    // Mixpanel functions
    private func trackViewTime() {
        let timeSpent = Date().timeIntervalSince(viewStartTime)
        Mixpanel.mainInstance().track(event: "MIX Login View Time", properties: [
            "time_spent": timeSpent
        ])
    }
    
    private func trackForgotPasswordSheetOpened() {
        // Track the event when the forgot password sheet is opened
        Mixpanel.mainInstance().track(event: "MIX Forgot Password Sheet Opened")
    }
    
    private func signIn() async {
        isLoading = true
        errorMessage = nil

        do {
            let userResult = try await Amplify.Auth.signIn(username: email, password: password)

            if userResult.isSignedIn {
                // Check if email is verified
                let userAttributes = try await Amplify.Auth.fetchUserAttributes()
                if let emailVerified = userAttributes.first(where: { $0.key == .emailVerified })?.value,
                   emailVerified == "true" {
                    
                    Mixpanel.mainInstance().track(event: "MIX Sign In Success", properties: [
                        "email": email,
                        "view": "Login View"
                    ])
                    
                    // Navigate based on child status
                    if let currentChild = try await amplifyService.getCurrentChild(), currentChild == "-" {
                        isSignedInForAdmin = true
                    } else {
                        isSignedInForDefaultUser = true
                    }
                    
                } else {
                    // Email not verified, open sheet
                    showVerificationSheet = true
                    Mixpanel.mainInstance().track(event: "MIX Email Not Verified", properties: [
                        "email": email
                    ])
                }

            } else {
                switch userResult.nextStep {
                case .confirmSignUp:
                    showVerificationSheet = true
                    Mixpanel.mainInstance().track(event: "MIX Email Not Verified", properties: [
                        "email": email
                    ])
                default:
                    errorMessage = "Sign in failed. Please verify your password is correct, or change it if you forgot it."
                }
            }

        } catch let error as AuthError {
            if error.errorDescription.contains("not confirmed") {
                showVerificationSheet = true
                Mixpanel.mainInstance().track(event: "MIX Email Not Verified", properties: [
                    "email": email
                ])
            } else if error.errorDescription.contains("User does not exist") {
                errorMessage = "Account does not exist. Please register first."
            } else {
                Mixpanel.mainInstance().track(event: "MIX Sign In Failure", properties: [
                    "email": email,
                    "reason": error.errorDescription
                ])
                errorMessage = "Sign in failed: \(error.errorDescription)"
            }
        } catch {
            Mixpanel.mainInstance().track(event: "MIX Sign In Failure", properties: [
                "email": email,
                "reason": error.localizedDescription
            ])
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }

        isLoading = false
    }
}

#Preview {
    LoginView()
}
