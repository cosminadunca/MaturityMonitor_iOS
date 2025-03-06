// Improvements:
// 1. Add name, surname and image picture of user who created the account to the child model to use it below the name of the child so that we see who created that instance
// AddChildStepFive View comments and messages done - needs testing

import SwiftUI
import Amplify
import AWSPluginsCore

struct RequestChildAccessView: View {
    
    // Access to Amplify functions
    let amplifyService = AmplifyService()

    @Environment(\.presentationMode) private var presentationMode

    @State private var childSurname: String = ""
    @State private var dateOfBirth: String = ""
    @State private var code: String = ""
    @State private var errorMessage: String? = nil
    
    // Control result visibility - display a box if no error was made
    @State private var showSearchResult: Bool = false
    @State private var isChild: Bool = false
    @State private var foundChild: Child? = nil
    @State private var childAlreadyLinked: Bool = false
    @State private var isLinkingSuccessful = false
    
    // State variable to control navigation to HomeView
    @State private var navigationToHome: Bool = false

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack {
                    Spacer()
                    Spacer()
                    SimpleCustomTextTitle(title: "Request account access")
                    Spacer()
                    Text("Request access to a child's details by entering the following:")
                        .font(Font.custom("Inter", size: 15))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding()
                    SimpleCustomTextField(placeholder: "Enter child's surname", text: $childSurname)
                    Spacer()
                    Text("Please enter their date of birth below")
                        .font(Font.custom("Inter", size: 15))
                        .foregroundColor(.black)
                    CustomDateTextField(dateText: $dateOfBirth)
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Text("Enter unique code")
                            .font(Font.custom("Inter", size: 15))
                            .foregroundColor(.black)
                        TextField("", text: $code)
                            .keyboardType(.numberPad)
                            .frame(width: 100, height: 30)
                            .padding(.horizontal, 10)
                            .background(Color.white)
                            .accentColor(Color.buttonGreyLightStroke)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.gray.opacity(0.8), lineWidth: 0.5)
                            )
                            .shadow(color: Color.black.opacity(0.25), radius: 4, y: 4)
                            .cornerRadius(4)
                            .onChange(of: code) { newValue in
                                // Filter out non-digit characters
                                let filtered = newValue.filter { $0.isNumber }
                                
                                // Limit the code to 6 digits
                                if filtered.count <= 6 {
                                    code = filtered
                                } else {
                                    code = String(filtered.prefix(6))
                                }
                            }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    
                    if let errorMessage = errorMessage, !errorMessage.isEmpty {
                        ErrorCustomText(title: errorMessage)
                    }
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        validateFields()
                        if errorMessage == nil {
                            Task {
                                let trimmedSurname = childSurname.trimmingCharacters(in: .whitespacesAndNewlines)
                                let result = await amplifyService.queryChildByAttributesDataStore(surname: childSurname, dateOfBirth: dateOfBirth, uniqueId: code)
                                print(result.0)
                                print(result.1)
                                foundChild = result.0
                                if (foundChild != nil) {
                                    isChild = true
                                    childAlreadyLinked = result.1
                                }
                            }
                        }
                    }) {
                        CustomButton(
                            title: "Search",
                            backgroundColor: Color(.buttonPurpleLight),
                            textColor: .white
                        )
                    }
                    Spacer()
                    
                    if showSearchResult {
                        VStack {
                            if isChild == true {
                                HStack {
                                    // Check if the imageURL is not null (nil or empty)
//                                    if let imageURL = foundChild?.imageURL, !imageURL.isEmpty {
//                                        // Use AsyncImage to load the image from the URL
//                                        AsyncImage(url: URL(string: imageURL)) { image in
//                                                image
//                                            .resizable()
//                                            .scaledToFit()
//                                            .frame(width: 40, height: 40)
//                                        } placeholder: {
//                                            // Fallback placeholder while the image is loading
//                                            ProgressView()
//                                            .frame(width: 40, height: 40) // Same size as the image
//                                        }
//                                    } else {
                                        // Use default icon if imageURL is nil or empty
                                        Image(systemName: foundChild?.gender == "Male" ? "figure.stand" : "figure.stand.dress")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.buttonTurquoiseDark)
//                                    }
                                    
                                    VStack {
                                        if let foundChild = foundChild {
                                            Text((foundChild.name.isEmpty && foundChild.surname.isEmpty) ? "" : "\(foundChild.name) \(foundChild.surname)")
                                                .font(Font.custom("Inter", size: 18))
                                                .foregroundColor(.black)
                                        }
                                    }
                                    Spacer()
                                }.padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                                HStack {
                                    Spacer()
                                    if childAlreadyLinked {
                                        Text("This child is already linked to your account!")
                                            .font(Font.custom("Inter", size: 14))
                                            .foregroundColor(.red)
                                            .padding(.top, 5)
                                    } else {
                                        if isLinkingSuccessful {
                                            SuccessCustomText(title: "Child successfully linked!")
                                        } else {
                                            Button(action: {
                                                Task {
                                                    if let foundChild = foundChild {
                                                        print("Creating link between child & user.")
                                                        await amplifyService.createLinkChildToUser(childId: foundChild.id, child: foundChild)
                                                        print("Link created!")
                                                        
                                                        let updateMessage = await amplifyService.updateCurrentChildAttribute(with: foundChild.id)
                                                        print(updateMessage)
                                                        
                                                        // Update the state to show success message
                                                        isLinkingSuccessful = true
                                                        navigationToHome = true
                                                    }
                                                }
                                            }) {
                                                CustomButton(
                                                    title: "Add child",
                                                    backgroundColor: Color(.buttonGreyLight),
                                                    textColor: .black,
                                                    width: 120,
                                                    height: 30,
                                                    cornerRadius: 10
                                                )
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                            }
                        }
                        .foregroundColor(.clear)
                        .frame(width: 350, height: 150)
                        .background(.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .inset(by: 1.50)
                                .stroke(Color(red: 0, green: 0.59, blue: 0.65), lineWidth: 0.8)
                        )
                        .padding(.bottom, 5)
                        .transition(.opacity)
                    }
                    
                    Spacer()
                    Spacer()
                    
                    NavigationLink(destination: HomeView(currentPage: .constant("home")), isActive: $navigationToHome) {
                        EmptyView()
                    }
                    
                }
                .onTapGesture {
                    hideKeyboard() // Hide keyboard when tapping outside
                }
//                .toolbar {
//                    ToolbarItem(placement: .keyboard) {
//                        HStack {
//                            Spacer()
//                            Button("Done") {
//                                hideKeyboard()
//                            }
//                            .foregroundColor(.blue)
//                        }
//                    }
//                }
                .edgesIgnoringSafeArea(.top)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        // Custom back button
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                    .foregroundColor(.black)
                                    .font(.font18)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .gesture(
                    TapGesture()
                        .onEnded { _ in
                            // Dismiss the keyboard when tapped outside of it
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                )
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func validateFields() {
        if childSurname.isEmpty || dateOfBirth.isEmpty || code.isEmpty {
            errorMessage = "All fields must be completed!"
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        if let date = dateFormatter.date(from: dateOfBirth) {
            if date <= Date() {
                errorMessage = nil
                showSearchResult = true
            } else {
                errorMessage = "Date of birth cannot be in the future!"
            }
        } else {
            errorMessage = "Please enter a valid date of birth!"
        }
    }
}

#Preview {
    RequestChildAccessView()
}
