import SwiftUI

struct Graphs: View {
    
    private let amplifyService = AmplifyService()
    
    // Variables related to the entries drop-down
    @State private var entries: [Entry] = []  // Array of Entry objects
    @State private var dateToEntryMap: [String: Entry] = [:] // Dictionary to map dateOfEntry to Entry
    @State private var selectedUnit: String = ""
    
    @State private var predictedAdultHeightTwoDigits: [Double] = [105.0]
    @State private var percentageAH: [String] = ["20%"]
    @State private var predictedAdultHeightString: String = ""
    @State private var agePAH: Double = 14.56 // (biological age)
    @State private var agePAHString: String = ""
    @State private var maturityCategory: String = ""
    
    @State private var isLoading: Bool = true
    @State var BetaValues:[BetaValues]
    
    // Child's details needed in the graph and other values for generating it
    @State private var childId: String = ""
    @State private var childName: String = ""
    @State private var childSurname: String = ""
    @State private var childDateOfBirth: String = ""
    @State private var childGender: String = ""
    @State private var childMotherHeight: String = ""
    @State private var childFatherHeight: String = ""
    @State private var childMotherHeightDouble: Double = 0.0
    @State private var childFatherHeightDouble: Double = 0.0
    @State private var childHeight: Double = 0.0
    @State private var midParentStature: Double = 0.0
    @State private var chronologicalAgeString: String = ""
    @State private var dataLoaded: Bool = false
    
    // Entry's variables:
    @State private var entryHeight: String = ""
    @State private var entryWeight: String = ""

    @State private var childParentsMeasurements: String = ""
    
    var body: some View {
        ScrollView{
            VStack {
                // Loading indicator
                //                if isLoading {
                //                    ProgressView("Loading...")
                //                        .progressViewStyle(CircularProgressViewStyle())
                //                        .padding()
                //                }
                //                        
                //                // Show message if there are no entries
                //                if entries.isEmpty {
                //                    Text("Please add an entry first!")
                //                        .foregroundColor(.red)
                //                        .padding()
                //                } else {
                
                Spacer()
                Spacer()
                Spacer()
                Text("Choose another entry below:")
                    .foregroundColor(.black)
                    .font(Font.custom("Inter", size: 14))
                DropDownEntries(
                    label: "",
                    placeholder: "",
                    fieldWidth: 250,
                    entries: $entries,
                    text: $selectedUnit,
                    selectedUnit: $selectedUnit,
                    isTextFieldDisabled: true
                )
                .zIndex(1)
                .frame(height: 60)
                .onChange(of: selectedUnit) { newValue in
                    dataLoaded = false
                    Task {
                        await handleSelectedUnitChange(newValue)
                        dataLoaded = true  // Trigger view update
                    }
                }
                .onAppear {
                    // Simply call the function with the selectedUnit value
                    handleSelectedUnitChange(selectedUnit)
                }
                
                if(dataLoaded) {
                    TabView {
                        PredictedAdultHeight(
                            motherHeightDouble: $childMotherHeightDouble,
                            fatherHeightDouble: $childFatherHeightDouble,
                            predictedAdultHeightTwoDigits: $predictedAdultHeightTwoDigits,
                            childGender: $childGender,
                            childName: $childName,
                            childSurname: $childSurname,
                            childHeight: $childHeight,
                            chronologicalAgeString: $chronologicalAgeString,
                            predictedAdultHeightString: $predictedAdultHeightString,
                            percentageAH: $percentageAH,
                            agePAH: $agePAH,
                            agePAHString: $agePAHString,
                            maturityCategory: $maturityCategory
                        )
                        .tag(0)
                        
                        GrowthChartTab(
                            childId: $childId,
                            childName: $childName,
                            childSurname: $childSurname,
                            predictedAdultHeightTwoDigits: $predictedAdultHeightTwoDigits,
                            entries: $entries
                        )
                            .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 525)
                    .padding(.top, 10)
                    .overlay(
                        VStack {
                            Rectangle()
                                .frame(height: 1) // Thin border
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.horizontal, 16) // Optional for some spacing from edges
                            Spacer()
                        }
                    )
                    .onAppear {
                        // Customize the dots
                        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.darkGray // Softer active dot color
                        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray.withAlphaComponent(0.5) // Lighter inactive dots
                    }
                }

                //} Uncomment for loading
            }
            .onAppear {
                isLoading = true
                Task {
                    await loadChildIdAndFetchEntries()
                }
                dataLoaded = true
            }
        }
    }
    
    func loadChildIdAndFetchEntries() async {
        do {
            if let fetchedChildId = try await amplifyService.getCurrentChild() {
                print("Fetched childId: \(fetchedChildId)")
                childId = fetchedChildId
                if let child = await amplifyService.queryChildByIdDataStore(childId: fetchedChildId) {
                    childName = child.name
                    childSurname = child.surname
                    childDateOfBirth = child.dateOfBirth
                    childGender = child.gender
                    childMotherHeight = child.motherHeight
                    childFatherHeight = child.fatherHeight
                    childParentsMeasurements = child.parentsMeasurements
                    
                    // Parents' heights logic
                    let lastTwoLetters = childMotherHeight.suffix(2)
                    print("Last two letters of mother's height: \(lastTwoLetters)")
                    
                    // Proceed with further checks and conversions
                    var cleanedMotherHeight = childMotherHeight
                    var cleanedFatherHeight = childFatherHeight
                    
                    cleanedMotherHeight = String(cleanedMotherHeight.dropLast(2))
                    cleanedFatherHeight = String(cleanedFatherHeight.dropLast(2))
                    
                    print("Cleaned mother height: \(cleanedMotherHeight)")
                    print("Cleaned father height: \(cleanedFatherHeight)")
                    
                    // Trim any extra whitespace again after removing the suffix
                    cleanedMotherHeight = cleanedMotherHeight.trimmingCharacters(in: .whitespacesAndNewlines)
                    cleanedFatherHeight = cleanedFatherHeight.trimmingCharacters(in: .whitespacesAndNewlines)

                    print("Trimmed cleaned mother height: \(cleanedMotherHeight)")
                    print("Trimmed cleaned father height: \(cleanedFatherHeight)")
                    
                    // Now attempt to convert the cleaned strings to Double (in cm)
                    if var motherHeightDouble = Double(cleanedMotherHeight),
                       var fatherHeightDouble = Double(cleanedFatherHeight) {
                        
                        // Store the original cm values (as mutable variables)
                        var childMotherH = motherHeightDouble
                        var childFatherH = fatherHeightDouble
                        
                        print("Mother's Height Double: \(childMotherH)")
                        print("Father's Height Double: \(childFatherH)")
                        
                        // Apply conversion if heights were originally in centimeters
                        if lastTwoLetters == "cm" {
                            if let convertedMotherHeight = findClosestInchesForCm(cmValue: childMotherH),
                               let convertedFatherHeight = findClosestInchesForCm(cmValue: childFatherH) {
                                
                                childMotherH = convertedMotherHeight
                                childFatherH = convertedFatherHeight
                                
                                print("Mother's Height in Inches: \(childMotherH)")
                                print("Father's Height in Inches: \(childFatherH)")
                            } else {
                                if findClosestInchesForCm(cmValue: childMotherH) == nil {
                                    print("No matching inch value found for Mother's Height: \(childMotherH) cm")
                                }
                                if findClosestInchesForCm(cmValue: childFatherH) == nil {
                                    print("No matching inch value found for Father's Height: \(childFatherH) cm")
                                }
                            }
                        }
                        
                        // Check for "Estimated" parents' heights and adjust
                        if childParentsMeasurements == "Estimated" {
                            print("Parents' heights are estimated")
                            childMotherH = (childMotherH * 0.953) + 2.803
                            childFatherH = (childFatherH * 0.955) + 2.316
                            print("Adjusted Mother's Height (estimated): \(childMotherH)")
                            print("Adjusted Father's Height (estimated): \(childFatherH)")
                        }
                        
                        // Change back to cm from inches using 2.54 this time
                        childMotherH *= 2.54
                        childFatherH *= 2.54
                        
                        print("Mother's Height in Cm: \(childMotherH)")
                        print("Father's Height in Cm: \(childFatherH)")
                        
                        // Calculate the mid-parent stature
                        midParentStature = (childMotherH + childFatherH) / 2
                        print("Mid Parent Stature: \(midParentStature)")
                        
                        var motherHeightString = String(format: "%.1f", childMotherH)
                        var fatherHeightString = String(format: "%.1f", childFatherH)
                        var midParentStatureString = String(format: "%.1f", midParentStature)
                        
                        // Convert back to Double
                        var motherHeightDouble = Double(motherHeightString) ?? 0.0
                        var fatherHeightDouble = Double(fatherHeightString) ?? 0.0
                        childMotherHeightDouble = motherHeightDouble
                        childFatherHeightDouble = fatherHeightDouble
                        midParentStature = Double(midParentStatureString) ?? 0.0

                        print("Mother's Height Double: \(motherHeightDouble)")
                        print("Father's Height Double: \(fatherHeightDouble)")
                        print("Mid Parent Stature Double: \(midParentStature)")
                    }
                }
                
                await fetchEntries()
            } else {
                print("No currentChild attribute found.")
            }
        } catch {
            print("Error fetching currentChild: \(error)")
        }
    }
    
    // For this and the following 2 function, the values are stored, ordered and in the end they are similar to this: 02/03/2025, 03/07/2021, etc... (they are also parsed in some cases)
    func fetchEntries() async {
        guard !childId.isEmpty else { return }
        isLoading = true
        do {
            if let fetchedEntries = await amplifyService.fetchEntriesForChild(childId: childId) {
                print("Fetched Entries Count: \(fetchedEntries.count)")

                // Sort entries by dateOfEntry in descending order (latest first)
                let sortedEntries = fetchedEntries.sorted { entry1, entry2 in
                    guard let date1 = parseDate(from: entry1.dateOfEntry),
                          let date2 = parseDate(from: entry2.dateOfEntry) else {
                        print("Failed to parse dates for sorting")
                        return false
                    }
                    return date1 > date2 // Most recent first
                }
                
                // Display sorted entries for debugging
                print("Sorted Entries (Latest First):")
                for entry in sortedEntries {
                    print("\(entry.dateOfEntry)")
                }

                // Assign the sorted entries to the state variables
                entries = sortedEntries
                dateToEntryMap = Dictionary(uniqueKeysWithValues: sortedEntries.map { ($0.dateOfEntry, $0) })

                // Ensure the latest entry is selected in the dropdown
                if let mostRecentEntry = sortedEntries.first {
                    let formattedDate = formatDateString(mostRecentEntry.dateOfEntry)
                    selectedUnit = formattedDate
                    print("Selected Unit (Most Recent Entry): \(formattedDate)")
                }
            } else {
                print("No entries found for child.")
            }
        } catch {
            print("Error fetching entries: \(error)")
        }
        isLoading = false
    }
    func parseDate(from string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" // Corrected format for European-style dates
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // Ensure UTC time zone

        if let date = dateFormatter.date(from: string) {
            print("Successfully parsed date: \(string) -> \(date)")
            return date
        } else {
            print("Failed to parse date: \(string)")
            return nil
        }
    }
    func formatDateString(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd/MM/yyyy" // Corrected input format
        inputFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMM yyyy" // Output format (e.g., 3 Feb 2025)
        outputFormatter.timeZone = TimeZone(abbreviation: "UTC")

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            print("Failed to format date: \(dateString)")
            return dateString // Return original if formatting fails
        }
    }
    
    func reverseFormatDateString(_ formattedDate: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "d MMM yyyy" // Matches the formatted input
        inputFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM/yyyy" // Converts back to the original format
        outputFormatter.timeZone = TimeZone(abbreviation: "UTC")

        if let date = inputFormatter.date(from: formattedDate) {
            return outputFormatter.string(from: date)
        } else {
            print("Failed to reverse format date: \(formattedDate)")
            return formattedDate // Return original if conversion fails
        }
    }

    func handleSelectedUnitChange(_ selectedUnit: String) {
        print("Handle selected unit change for: \(selectedUnit)")
        
        var fileForPAH = ""
        if childGender == "Female" {
            print ("Here as a girl.")
            fileForPAH = "agePAHfemale"
        } else {
            print ("Here as a boy.")
            fileForPAH = "agePAHmale"
        }

        if let selectedEntry = dateToEntryMap[reverseFormatDateString(selectedUnit)] {
            print("Selected entry changed to: \(selectedEntry)")

            entryHeight = selectedEntry.height
            entryWeight = selectedEntry.weight
            print("Entry height: \(entryHeight), Entry weight: \(entryWeight)")

            guard let age = calculateAgeOnDate(dateOfBirthString: childDateOfBirth, referenceDateString: selectedEntry.dateOfEntry) else {
                print("Failed to calculate age.")
                return
            }
            print("Calculated age: \(age)")

            // Calculate chronological age (in years and months)
            let chronologicalAge = calculateAgeInYearsAndMonths(dateOfBirthString: childDateOfBirth, referenceDateString: selectedEntry.dateOfEntry)
            print("Chronological Age: \(chronologicalAge) years")
            chronologicalAgeString = "\(chronologicalAge) yrs"

            // Directly working with heightString and weightString
            var heightString = entryHeight.trimmingCharacters(in: .whitespacesAndNewlines)
            var weightString = entryWeight.trimmingCharacters(in: .whitespacesAndNewlines)

            print("Trimmed height: '\(heightString)'")
            print("Trimmed weight: '\(weightString)'")

            // Remove any units from the height and weight strings (e.g., "cm", "kg", "in")
            var heightWithoutUnits = heightString.replacingOccurrences(of: "cm", with: "")
                .replacingOccurrences(of: "in", with: "")
                .replacingOccurrences(of: " ", with: "")
            var weightWithoutUnits = weightString.replacingOccurrences(of: "kg", with: "")
                .replacingOccurrences(of: "lbs", with: "")
                .replacingOccurrences(of: " ", with: "")

            print("Height without units: \(heightWithoutUnits)")
            print("Weight without units: \(weightWithoutUnits)")

            // Convert to Double
            var heightDouble: Double = 0.0
            var weightDouble: Double = 0.0
            
            if let height = Double(heightWithoutUnits), let weight = Double(weightWithoutUnits) {
                heightDouble = height
                weightDouble = weight
                childHeight = heightDouble
                print("CHILD HEIGHT: \(childHeight)")
                
                print("Height as Double: \(heightDouble)")
                print("Weight as Double: \(weightDouble)")

                // If the height is in inches, convert it to cm
                if entryHeight.lowercased().contains("in") {
                    heightDouble *= 2.54
                    weightDouble *= 0.453592
                    print("Converted Height: \(heightDouble) cm")
                    print("Converted Weight: \(weightDouble) kg")
                }
                
                // Get beta values based on gender
                var fileName: String = ""
                if childGender == "Female" {
                    print("Child is female")
                    fileName = "femaleTableCM"
                } else {
                    print("Child is male")
                    fileName = "maleTableCM"
                }

                // Get beta values for the specific age
                if let betaValues = getBetaValues(fileName: fileName, key: age), betaValues.count >= 4 {
                    let beta0 = betaValues[0]
                    let beta1 = betaValues[1]
                    let beta2 = betaValues[2]
                    let beta3 = betaValues[3]

                    print("Beta0: \(beta0), Beta1: \(beta1), Beta2: \(beta2), Beta3: \(beta3)")

                    // Calculate the contributions
                    let heightContribution = heightDouble * beta1
                    let weightContribution = weightDouble * beta2
                    let parentStatureContribution = midParentStature * beta3

                    print("HeightContribution: \(heightContribution)")
                    print("WeightContribution: \(weightContribution)")
                    print("ParentStatureContribution: \(parentStatureContribution)")

                    // Calculate the predicted adult height
                    let predictedAdultHeight = beta0 + heightContribution + weightContribution + parentStatureContribution
                    print("Predicted Adult Height: \(predictedAdultHeight)")

                    predictedAdultHeightString = String(format: "%.1f", predictedAdultHeight)
                    
                    // Round to 1 decimal place for predicted adult height
                    predictedAdultHeightTwoDigits[0] = Double(predictedAdultHeightString) ?? 0.0
                    print("Predicted Adult Height (1 decimal): \(predictedAdultHeightTwoDigits[0])")

                    // Calculate the percentage of predicted adult height
                    var percentageAHDouble = (heightDouble / predictedAdultHeight) * 100
                    
                    print("PercentageAHDouble: \(percentageAHDouble)")

                    percentageAH[0] = String(format: "%.1f", percentageAHDouble)
                    percentageAH[0] = percentageAH[0] + "%"
                    print("Percentage AH: \(percentageAH[0])")
                    
                    // Round to 2 decimal places for percentageAHDouble
                    percentageAHDouble = Double(String(format: "%.2f", percentageAHDouble)) ?? 0.0
                    
                    // Pass the 2-decimal rounded value of percentageAHDouble to the function
                    print(childGender)
                    agePAH = findClosestAgeValue(ageValue: percentageAHDouble, fileName: fileForPAH) ?? 0.0
                    agePAHString = String(format: "%.3f", agePAH)
                    print("Percentage AH Double (2 decimal places): \(percentageAHDouble)")
                    
                    // Determine maturity category based on the percentage
                    if percentageAHDouble < 88 {
                        maturityCategory = "pre-PHV"
                    } else if percentageAHDouble >= 88 && percentageAHDouble <= 95 {
                        maturityCategory = "mid-PHV"
                    } else {
                        maturityCategory = "post-PHV"
                    }
                    print("Maturity Category: \(maturityCategory)")
                } else {
                    print("Error: Failed to get valid beta values for age \(age).")
                }

                
            } else {
                print("Invalid height or weight format.")
            }
            
        } else {
            print("No entry found for the selected date.")
        }
    }
    
    func findClosestAgeValue(ageValue: Double, fileName: String) -> Double? {
        // Load the CSV data if not already loaded
        let ageValues = loadCSVDataPAH(fileName: fileName)
        
        if ageValues.isEmpty {
            print("Error: No age value data available in file \(fileName).")
            return nil
        }
        
        // Find the closest match for the given age value
        let closestMatch = ageValues.min(by: { abs($0.id - ageValue) < abs($1.id - ageValue) })
        
        print("Cloasest match: \(closestMatch)")
        
        if let closestMatch = closestMatch {
            print("Closest age for \(ageValue) from file \(fileName) is \(closestMatch.id), corresponding to \(closestMatch.value)")
            return closestMatch.value
        } else {
            print("Error: Could not find closest match for \(ageValue) in file \(fileName).")
            return nil
        }
    }

    func findClosestInchesForCm(cmValue: Double) -> Double? {
        // Load the CSV data if not already loaded
        let cmConversions = loadCSVDataCmIn(fileName: "cmToIn 2") // Change to the actual file name
        
        if cmConversions.isEmpty {
            print("Error: No conversion data available.")
            return nil
        }
        
        // Find the closest match in the cm column
        let closestMatch = cmConversions.min(by: { abs($0.id - cmValue) < abs($1.id - cmValue) })
        
        if let closestMatch = closestMatch {
            print("Closest cm for \(cmValue) cm is \(closestMatch.id) cm, corresponding to \(closestMatch.inches) inches")
            return closestMatch.inches
        } else {
            print("Error: Could not find closest match for \(cmValue) cm")
            return nil
        }
    }
    
    func findClosestCmForInches(inchesValue: Double) -> Double? {
        // Load the CSV data if not already loaded
        let cmConversions = loadCSVDataCmIn(fileName: "cmToIn 2") // Change to the actual file name
        
        if cmConversions.isEmpty {
            print("Error: No conversion data available.")
            return nil
        }
        
        // Find the closest match in the inches column
        let closestMatch = cmConversions.min(by: { abs($0.inches - inchesValue) < abs($1.inches - inchesValue) })
        
        if let closestMatch = closestMatch {
            print("Closest inches for \(inchesValue) inches is \(closestMatch.inches) inches, corresponding to \(closestMatch.id) cm")
            return closestMatch.id
        } else {
            print("Error: Could not find closest match for \(inchesValue) inches")
            return nil
        }
    }
    
    func getBetaValues(fileName: String, key: Double) -> [Double]? {
        // Load the CSV file into an array of BetaValues
        let betaValuesList = loadCSVData(fileName: fileName)
        
        if betaValuesList.isEmpty {
            print("Error: No beta values data available.")
            return nil
        }
        
        // Find the row where the first element (age) matches the key
        if let matchingRow = betaValuesList.first(where: { $0.id == key }) {
            print("Found matching row for age \(key): \(matchingRow)")
            
            // Return the values from the matching row, skipping the age (first element)
            return [matchingRow.beta0, matchingRow.beta1, matchingRow.beta2, matchingRow.beta3]
        } else {
            print("Error: Could not find match for age: \(key) in file: \(fileName)")
            return nil
        }
    }

    func calculateAgeOnDate(dateOfBirthString: String, referenceDateString: String) -> Double? {
        // DateFormatter to parse the date strings
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"  // Updated format to match the input format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // Set to UTC time zone
        
        // Parse the dateOfBirth and referenceDate strings into Date objects
        print("Attempting to parse dates...")
        
        guard let dateOfBirth = dateFormatter.date(from: dateOfBirthString),
              let referenceDate = dateFormatter.date(from: referenceDateString) else {
            print("Error: Invalid date format")
            return nil // Return nil if date parsing fails
        }
        
        print("Date of Birth: \(dateOfBirth)")
        print("Reference Date: \(referenceDate)")
        
        // Get the calendar for date calculations
        let calendar = Calendar.current
        
        // Calculate the difference in years
        print("Calculating the difference in years...")
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: referenceDate)
        
        // Get the age in years as a double
        let ageInYears = Double(ageComponents.year ?? 0)
        
        print("Calculated age in years: \(ageInYears)")
        
        // Round to the nearest half year
        let roundedAge = round(ageInYears * 2) / 2.0
        
        print("Rounded age to nearest half year: \(roundedAge)")
        
        return roundedAge
    }
    
    func calculateAgeInYearsAndMonths(dateOfBirthString: String, referenceDateString: String) -> String {
        // DateFormatter to parse the date strings
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"  // Updated format to match the input format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // Set to UTC time zone
        
        // Parse the dateOfBirth and referenceDate strings into Date objects
        print("Attempting to parse dates...")
        
        guard let dateOfBirth = dateFormatter.date(from: dateOfBirthString),
              let referenceDate = dateFormatter.date(from: referenceDateString) else {
            print("Error: Invalid date format")
            return "Error" // Return error message in case of parsing failure
        }
        
        print("Date of Birth: \(dateOfBirth)")
        print("Reference Date: \(referenceDate)")
        
        // Get the calendar for date calculations
        let calendar = Calendar.current
        
        // Calculate the difference in years and months
        let ageComponents = calendar.dateComponents([.year, .month], from: dateOfBirth, to: referenceDate)
        
        // Get the age in years and months
        var yearsDifference = ageComponents.year ?? 0
        var monthsDifference = ageComponents.month ?? 0
        
        print("Calculated age in years: \(yearsDifference), months: \(monthsDifference)")
        
        // Adjust the months if necessary (if months are negative)
        if monthsDifference < 0 {
            monthsDifference += 12
            yearsDifference -= 1
        }
        
        // Print after adjusting months
        print("After adjusting months: \(yearsDifference) years, \(monthsDifference) months")
        
        // Return the age in "y.m" format
        let result = "\(yearsDifference).\(monthsDifference)"
        print("Final age: \(result)")
        
        return result
    }
}

#Preview {
    Graphs(BetaValues: loadCSVData(fileName: "exampleFileName"))
}
