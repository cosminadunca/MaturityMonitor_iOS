// Login View comments and messages done - needs testing
// Eventually implemet the logic of not allowing date before the date of birth of the child to be added

import SwiftUI
import Combine
import Mixpanel

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

    // Mixpanel variables
    @State private var calendarTapCount = 0
    @State private var viewStartTime: Date = Date()
    
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
                CustomDateTextField(
                    placeholder: "DD/MM/YYYY",
                    dateText: $dateText,
                    viewName: "New Entry",
                    calendarTapCount: $calendarTapCount
                )
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
                
                // Navigation link that activates when `isSuccess` becomes true
                NavigationLink(
                    destination: ResourcesView(currentPage: .constant("resources")),
                    isActive: $isSuccess
                ) {
                    EmptyView()
                }
                .hidden()
                Spacer()
                Spacer()
            }
            .onAppear {
                viewStartTime = Date()
            }
            .onDisappear {
                trackViewTime()
                Mixpanel.mainInstance().track(
                        event: "MIX Calendar Icon Taps in New Entry View",
                        properties: ["calendarTapCount": calendarTapCount]
                    )
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
        }
    }
    
    // Mixpanel
    private func trackViewTime() {
        let timeSpent = Date().timeIntervalSince(viewStartTime)
        Mixpanel.mainInstance().track(event: "MIX New Entry View Time", properties: ["time_spent": timeSpent])
    }
    
    private func validateFields() -> Bool {
        print("🔍 Starting field validation...")

        // Validate all fields are filled
        guard !weight.isEmpty, !height.isEmpty, !sittingHeight.isEmpty, !dateText.isEmpty else {
            errorMessage = "Please fill in all fields."
            isSuccess = false
            print("❌ Validation failed: Missing fields.")
            
            Mixpanel.mainInstance().track(
                event: "MIX Entry Validation Failed - Missing Fields in New Entry View",
                properties: ["reason": "Missing fields"]
            )
            return false
        }

        // Validate date format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        if let date = dateFormatter.date(from: dateText) {
            print("✅ Parsed date: \(date)")
            if date > Date() {
                errorMessage = "Date cannot be in the future!"
                isSuccess = false
                print("❌ Validation failed: Date is in the future.")

                Mixpanel.mainInstance().track(
                    event: "MIX Entry Validation Failed - Date in Future in New Entry View",
                    properties: ["reason": "Future date"]
                )
                return false
            }
        } else {
            errorMessage = "Please enter a valid date in DD/MM/YYYY format!"
            isSuccess = false
            print("❌ Validation failed: Invalid date format.")

            Mixpanel.mainInstance().track(
                event: "MIX Entry Validation Failed - Date not Valid in New Entry View",
                properties: ["reason": "Invalid date format"]
            )
            return false
        }

        errorMessage = ""
        print("✅ Field validation passed.")
        
        Mixpanel.mainInstance().track(event: "MIX Entry Validation Passed in New Entry View")
        return true
    }

    private func addEntry() {
        Mixpanel.mainInstance().track(event: "MIX Entry Add Attempt Started")

        guard validateFields() else {
            print("❌ Entry submission aborted due to validation failure.")
            return
        }

        isLoading = true
        errorMessage = ""

        Task {
            do {
                // Step 1: Get current child ID
                print("🔄 Fetching current child ID...")
                guard let currentChildId = try await amplifyService.getCurrentChild() else {
                    print("❌ Failed to fetch current child ID.")
                    throw NSError(domain: "AmplifyService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch Current Child ID"])
                }
                print("✅ Current child ID: \(currentChildId)")

                // Step 2: Fetch entries
                print("🔄 Fetching existing entries for the child...")
                if let existingEntries = await amplifyService.fetchEntriesForChild(childId: currentChildId) {
                    print("📦 Fetched \(existingEntries.count) existing entries.")
                    for entry in existingEntries {
                        print("➡️ Existing entry date: \(entry.dateOfEntry)")
                    }

                    // Step 3: Check for duplicate date
                    if existingEntries.contains(where: { $0.dateOfEntry == dateText }) {
                        errorMessage = "An entry with this date already exists! Please remove that one first if you would like to add a new entry for this date."
                        isSuccess = false
                        isLoading = false
                        print("❌ Duplicate entry found for date: \(dateText)")

                        Mixpanel.mainInstance().track(
                            event: "MIX Entry Validation Failed - Duplicate Date",
                            properties: ["date": dateText]
                        )
                        return
                    } else {
                        print("✅ No duplicate date found. Proceeding to create entry.")
                    }
                } else {
                    print("⚠️ No existing entries found for the child.")
                }

                // Step 4: Create entry
                print("🛠️ Creating new entry...")
                try await amplifyService.createEntry(
                    weight: weight,
                    height: height,
                    sittingHeight: sittingHeight,
                    dateText: dateText,
                    selectedUnit: selectedUnit
                )

                isSuccess = true
                message = "Entry added successfully!"
                print("✅ Entry successfully created.")
                clearFields()

                Mixpanel.mainInstance().track(
                    event: "MIX Entry Submission Success",
                    properties: [
                        "weight": weight,
                        "height": height,
                        "sittingHeight": sittingHeight,
                        "date": dateText,
                        "unit": selectedUnit
                    ]
                )

            } catch {
                isSuccess = false
                errorMessage = "Failed to add entry: \(error.localizedDescription)"
                print("❌ Error while creating entry: \(error.localizedDescription)")

                Mixpanel.mainInstance().track(
                    event: "MIX Entry Submission Failed",
                    properties: ["error": error.localizedDescription]
                )
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
