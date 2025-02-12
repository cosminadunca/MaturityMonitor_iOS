// Login View comments and messages done - needs testing

import SwiftUI
import Amplify // Needed for AuthError

struct LoginView: View {
    
    // Access to Amplify functions
    private let amplifyService = AmplifyService()
    
    @State private var password = ""
    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showForgotPasswordSheet = false
    
    // States for different content view redirection
    @State private var isSignedInForDefaultUser = false
    @State private var isSignedInForAdmin = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Spacer()
                    CustomTextTitle(title: "Login")
                    Spacer()
                    VStack(spacing: 20) {
                        CustomTextField(iconName: "envelope", placeholder: "Email", text: $email, keyboardType: .emailAddress)
                        
                        CustomPasswordField(placeholder: "Password", text: $password)
                    }
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            showForgotPasswordSheet.toggle()
                        }) {
                            Text("Forgot password?")
                                .font(Font.custom("Inter", size: 12))
                                .foregroundColor(.black)
                                .padding()
                                .padding(.trailing, 25)
                        }
                    }
                    .fullScreenCover(isPresented: $showForgotPasswordSheet) {
                        ForgotPasswordView(isPresented: $showForgotPasswordSheet)
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
                    }
                    .padding(.bottom, 40)
                }
                .background(.white)
                
                if isLoading {
                    ProgressView("Signing In...")
                        .progressViewStyle(CircularProgressViewStyle())
                }
                
                // If user already has a currentChild attached to account go to HomeView
                NavigationLink(destination: HomeView(currentPage: .constant("home")), isActive: $isSignedInForDefaultUser) {
                    EmptyView()
                }

                // If user doesn't have a currentChild attached to account go to RegistrationHomeView
                NavigationLink(destination: RegistrationHomeView(), isActive: $isSignedInForAdmin) {
                    EmptyView()
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    // Sign in function
    private func signIn() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Attempt to sign in
            let isSignedIn = try await amplifyService.signIn(username: email, password: password)
            if isSignedIn {
                // Fetch currentChild after successful sign-in
                if let currentChild = try await amplifyService.getCurrentChild(), currentChild == "-" {
                    isSignedInForAdmin = true
                } else {
                    isSignedInForDefaultUser = true
                }
            } else {
                errorMessage = "Sign in failed. Please check your credentials."
            }
        } catch let error as AuthError {
            errorMessage = "Sign in failed: \(error.errorDescription)"
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

#Preview {
    LoginView()
}
