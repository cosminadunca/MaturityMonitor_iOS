// Login View comments and messages done - needs testing
// Eventually implemet the logic of not allowing date before the date of birth of the child to be added

import SwiftUI
import Combine

struct NewEntryView: View {
    
    private let amplifyService = AmplifyService()
    
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var sittingHeight: String = ""
    @State private var selectedUnit: String = "cm/kg"
    @State private var dateText: String = ""
    
    @State private var message: String = ""
    @State private var isSuccess: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    
    let units = ["cm/kg", "in/lbs"]

    var body: some View {
        ZStack {
            Color(.tabViewLightGrey)
                .edgesIgnoringSafeArea(.all)
                .gesture(
                    TapGesture()
                    .onEnded { _ in
                        dismissKeyboard()
                    }
                )
            VStack {
                Spacer()
                DropDownTextField(
                    label: "Weight",
                    placeholder: "0 \(selectedUnit)",
                    fieldWidth: 150,
                    units: units,
                    text: $weight,
                    selectedUnit: $selectedUnit
                )
                DropDownTextField(
                    label: "Height",
                    placeholder: "0 \(selectedUnit)",
                    fieldWidth: 150,
                    units: units,
                    text: $height,
                    selectedUnit: $selectedUnit
                )
                DropDownTextField(
                    label: "Sitting Height",
                    placeholder: "0 \(selectedUnit)",
                    fieldWidth: 150,
                    units: units,
                    text: $sittingHeight,
                    selectedUnit: $selectedUnit
                )
                Spacer()
                CustomDateTextField(placeholder: "DD/MM/YYYY", dateText: $dateText)
                Spacer()
                if !errorMessage.isEmpty {
                    ErrorCustomText(title: errorMessage)
                }
                if isSuccess {
                    SuccessCustomText(title: message)
                }
                Button(action: {
                    Task {
                        dismissKeyboard()
                        await addEntry()
                    }
                }) {
                    CustomButton(
                        title: "Add entry",
                        backgroundColor: Color(.buttonPurpleLight),
                        textColor: .white
                    )
                }
                .disabled(isLoading) // Disable button while loading
                .opacity(isLoading ? 0.5 : 1.0) // Change opacity when loading
                Spacer()
                Spacer()
            }
        }
    }
    
    private func validateFields() -> Bool {
        // Validate all fields are filled
        guard !weight.isEmpty, !height.isEmpty, !sittingHeight.isEmpty, !dateText.isEmpty else {
            errorMessage = "Please fill in all fields."
            isSuccess = false
            return false
        }

        // Validate date format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" // Expected input format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Fixed locale

        if let date = dateFormatter.date(from: dateText) {
            // Check if the date is not in the future
            if date > Date() {
                errorMessage = "Date cannot be in the future!"
                isSuccess = false
                return false
            }
        } else {
            errorMessage = "Please enter a valid date in DD/MM/YYYY format!"
            isSuccess = false
            return false
        }

        errorMessage = "" // Clear any previous errors
        return true
    }

    private func addEntry() {
        // Validate inputs first
        guard validateFields() else {
            return
        }

        // Show loading indicator
        isLoading = true
        errorMessage = ""

        Task {
            do {
                // Call the createEntry function
                try await amplifyService.createEntry(
                    weight: weight,
                    height: height,
                    sittingHeight: sittingHeight,
                    dateText: dateText,
                    selectedUnit: selectedUnit
                )
                        
                isSuccess = true
                message = "Entry added successfully!"
                clearFields()
            } catch {
                isSuccess = false
                errorMessage = "Failed to add entry: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }

    private func clearFields() {
        weight = ""
        height = ""
        sittingHeight = ""
        dateText = ""
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    NewEntryView()
}
