// AddChildStepFive View comments and messages done - needs testing

import SwiftUI

struct AddChildStepFiveView: View {
    
    // Access to Amplify functions
    let amplifyService = AmplifyService()
    
    @Environment(\.presentationMode) private var presentationMode // Back button
    @ObservedObject var childDetails: ChildDetailsModel
    
    @State private var personalDataSheet = false
    @State private var isChecked: Bool = false
    @State private var isLoading = false
    @State private var showErrorMessage: Bool = false
    @State private var errorMessage: String?
    @State private var navigateToHomeView: Bool = false

    
    var body: some View {
//        if #available(iOS 16.0, *) {
//            NavigationStack {
                VStack {
                    Spacer()
                    Spacer()
                    SimpleCustomTextTitle(title: "Child's details")
                    VStack(alignment: .leading) {
                        Toggle(isOn: $isChecked) {
                            Text("Agree to this data being used for research purposes. Read more...")
                                .font(Font.custom("Inter", size: 15))
                                .foregroundColor(.black)
                        }
                        .toggleStyle(CheckboxToggleStyle())
                        .padding()
                        .onChange(of: isChecked) { newValue in
                            if newValue {
                                personalDataSheet = true
                            }
                        }
                    }
                    .padding()
                    Text("We would like to use the data in a research project to help improve the results we get for growth predictions with the help of Machine Learning. Once the research is completed, the data will not be used in other scopes. Do you agree?").padding()
                        .foregroundColor(.buttonPurpleLight)
                        .font(Font.custom("Inter", size: 15))
                    CustomCheckbox(options: [ApproveAIResearch.yes, ApproveAIResearch.no], selectedOption: $childDetails.approveAIResearch, font: Font.custom("Inter", size: 18))
                    Spacer()
                    Spacer()
                    Spacer()
                    HStack(spacing: 10) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            CustomButton(
                                title: "Previous step",
                                backgroundColor: Color(.buttonGreyLight),
                                textColor: .black
                            )
                        }
                        Button(action: {
                            // Check if an option is selected for the Yes-No checkboxes
                            if childDetails.approveAIResearch == nil {
                                showErrorMessage = true
                            } else {
                                showErrorMessage = false
                                Task {
                                    await createChild()
                                }
                            }
                        }) {
                            CustomButton(
                                title: "Add child",
                                backgroundColor: Color(.buttonPurpleLight),
                                textColor: .white
                            )
                        }
                        .disabled(isLoading)
                    }
                    .padding(.bottom, 60)
                    
                    if showErrorMessage {
                        ErrorCustomText(title: "Please select an option!")
                    }
                    ProgressBar(progressMultiplier: 5)
                    
                    NavigationLink(destination: HomeView(currentPage: .constant("home")), isActive: $navigateToHomeView) {
                        EmptyView()
                    }
                }
//                .navigationBarBackButtonHidden(true)
                .edgesIgnoringSafeArea(.top)
                .fullScreenCover(isPresented: $personalDataSheet) {
                    PersonalDataView(isAccepted: $isChecked)
                }
//            }
//        }
    }
    
    // Function to generate a random 6-digit number - for the child's unique id
    func generateUniqueId() -> Int {
        return Int.random(in: 100000...999999)
    }
    
    // Function to call the createChild method
    func createChild() async {
        // Show loading state
        isLoading = true
        
        let uniqueId = generateUniqueId()
        let result = await amplifyService.createChild(
            childDetails: childDetails,
            isChecked: isChecked,
            uniqueId: uniqueId
        )
        
        // Handle result
        switch result {
            case .success:
                navigateToHomeView = true
            case .failure(let error):
                errorMessage = error.localizedDescription
                isLoading = false
        }
    }
}

// Custom Checkbox for Research Approval - for the checkbox that opens the sheet
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 10) {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(configuration.isOn ? .buttonPurpleLight : .gray)
                .onTapGesture {
                    configuration.isOn.toggle()
                }

            configuration.label
        }
    }
}

#Preview {
    AddChildStepFiveView(childDetails: ChildDetailsModel())
}
