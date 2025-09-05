import SwiftUI
import Combine
import Mixpanel

struct AddChildStepThreeView: View {
    
    @Environment(\.presentationMode) var presentationMode // Back button
    @ObservedObject var childDetails: ChildDetailsModel
    
    @State private var birthMotherHeight: String = ""
    @State private var birthFatherHeight: String = ""
    @State private var selectedUnit: String = "cm"
    @State private var showErrorMessage: Bool = false
    @State private var navigateToNextView: Bool = false
    
    let units = ["cm", "in"]
    
    // Mixpanel variables
    @State private var viewStartTime: Date = Date()
    @Binding var numberOfStepsBack: Double
    
    var body: some View {
        VStack {
            Spacer()
            Spacer()
            SimpleCustomTextTitle(title: "Child's details")
            Spacer()
            Text("The same measurement unit applies to both values! Choose between cm & in.")
                .font(Font.custom("Inter", size: 15))
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding()
            VStack(alignment: .leading) {
                DropDownTextField(
                    label: "Birth Mother Height",
                    placeholder: "0 \(selectedUnit)",
                    fieldWidth: 130,
                    units: units,
                    text: $birthMotherHeight,
                    selectedUnit: $selectedUnit,
                    viewName: "Add Child Step Three"
                )
                DropDownTextField(
                    label: "Birth Father Height",
                    placeholder: "0 \(selectedUnit)",
                    fieldWidth: 130,
                    units: units,
                    text: $birthFatherHeight,
                    selectedUnit: $selectedUnit,
                    viewName: "Add Child Step Three"
                )
            }
            .padding()
            Spacer()
            VStack {
                Text("Are these details measured or estimated?")
                    .font(Font.custom("Inter", size: 15))
                    .foregroundColor(.black)
                    .padding(.bottom, 20)

                CustomCheckbox(
                    options: [MeasurementType.measured, MeasurementType.estimated],
                    selectedOption: $childDetails.measurementType,
                    font: Font.custom("Inter", size: 18),
                    trackingEvent: "MIX MeasurementType Selected in Add Child Step Three View"
                )
            }
            .padding()
            
            Spacer()
            Spacer()
            Spacer()

            HStack(spacing: 10) {
                Button(action: {
                    numberOfStepsBack += 1
                    presentationMode.wrappedValue.dismiss()
                }) {
                    CustomButton(
                        title: "Previous step",
                        backgroundColor: Color(.buttonGreyLight),
                        textColor: .black
                    )
                }
                                
                Button(action: {
                    validateFields()
                }) {
                    CustomButton(
                        title: "Next step",
                        backgroundColor: Color(.buttonGreyLight),
                        textColor: .black
                    )
                }

                // NavigationLink to next view (AddChildStepFourView)
                NavigationLink(
                    destination: AddChildStepFourView(childDetails: childDetails, numberOfStepsBack: $numberOfStepsBack),
                    isActive: $navigateToNextView
                ) {
                    EmptyView()
                }
            }
            .padding(.bottom, 60)

            if showErrorMessage {
                ErrorCustomText(title: "Please enter parents' heights and select a measurement type!")
            }
            ProgressBar(progressMultiplier: 3)
        }
        .onAppear {
            viewStartTime = Date()
        }
        .onDisappear {
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
        .edgesIgnoringSafeArea(.top)
        .navigationBarBackButtonHidden(true)
    }
    
    // Mixpanel
    private func trackViewTime() {
        let timeSpent = Date().timeIntervalSince(viewStartTime)
        Mixpanel.mainInstance().track(event: "MIX Add Child Step Three View Time", properties: ["time_spent": timeSpent])
    }
    
    private func validateFields() {
        // Track Mixpanel attempt
        let measurementValue = childDetails.measurementType?.rawValue ?? "None"
        
        Mixpanel.mainInstance().track(
            event: "MIX Next Step Button Attempted in Add Child Step Three View",
            properties: ["measurementType": measurementValue]
        )

        // Check if required fields are filled
        if birthMotherHeight.isEmpty || birthFatherHeight.isEmpty || childDetails.measurementType == nil {
            showErrorMessage = true
            
            Mixpanel.mainInstance().track(
                event: "MIX Validation Failed - Missing Fields in Add Child Step Three View"
            )
            return
        }

        // Save data
        childDetails.momHeight = "\(birthMotherHeight) \(selectedUnit)"
        childDetails.dadHeight = "\(birthFatherHeight) \(selectedUnit)"
        showErrorMessage = false
        navigateToNextView = true

        // Track success
        Mixpanel.mainInstance().track(
            event: "MIX Validation Succeeded in Add Child Step Three View",
            properties: ["measurementType": measurementValue]
        )
    }
}

#Preview {
    AddChildStepThreeView(childDetails: ChildDetailsModel(), numberOfStepsBack: .constant(0))
}
