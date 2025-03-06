// AddChildStepThree View comments and messages done - needs testing

import SwiftUI
import Combine

struct AddChildStepThreeView: View {
    
    @Environment(\.presentationMode) var presentationMode // Back button
    @ObservedObject var childDetails: ChildDetailsModel
    
    @State private var birthMotherHeight: String = ""
    @State private var birthFatherHeight: String = ""
    @State private var selectedUnit: String = "cm"
    @State private var showErrorMessage: Bool = false
    @State private var navigateToNextView: Bool = false
    
    let units = ["cm", "in"]
    
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
                    selectedUnit: $selectedUnit
                )
                DropDownTextField(
                    label: "Birth Father Height",
                    placeholder: "0 \(selectedUnit)",
                    fieldWidth: 130,
                    units: units,
                    text: $birthFatherHeight,
                    selectedUnit: $selectedUnit
                )
            }
            .padding()
            Spacer()
            VStack {
                Text("Are these details measured or estimated?")
                    .font(Font.custom("Inter", size: 15))
                    .foregroundColor(.black)
                    .padding(.bottom, 20)

                CustomCheckbox(options: [MeasurementType.measured, MeasurementType.estimated], selectedOption: $childDetails.measurementType, font: Font.custom("Inter", size: 18))
            }
            .padding()
            
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
                
                // NavigationLink for the next view
                NavigationLink(destination: AddChildStepFourView(childDetails: childDetails), isActive: $navigateToNextView) {
                    EmptyView()
                }

                Button(action: {
                    if birthMotherHeight.isEmpty || birthFatherHeight.isEmpty || childDetails.measurementType == nil {
                            showErrorMessage = true
                    } else {
                        showErrorMessage = false
                        
                        childDetails.momHeight = "\(birthMotherHeight) \(selectedUnit)"
                        childDetails.dadHeight = "\(birthFatherHeight) \(selectedUnit)"
                            
                        navigateToNextView = true
                    }
                }) {
                    CustomButton(
                        title: "Next step",
                        backgroundColor: Color(.buttonGreyLight),
                        textColor: .black
                    )
                }
            }
            .padding(.bottom, 60)

            if showErrorMessage {
                ErrorCustomText(title: "Please enter parents' heights and select a measurement type!")
            }
            ProgressBar(progressMultiplier: 3)
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
}

#Preview {
    AddChildStepThreeView(childDetails: ChildDetailsModel())
}
