import SwiftUI
import Mixpanel
import Charts
import DGCharts

struct HeightAgeChartView: UIViewRepresentable {
    var entries: [Entry]
    var entryAges: [Double]
    var entryCmChange: [Double]
    var predictedAdultHeight: Double
    
    func makeUIView(context: Context) -> LineChartView {
        print("entries: \(entries)")
        print("entryAges: \(entryAges)")
        print("entryCmChange: \(entryCmChange)")
        print("predictedAdultHeight: \(predictedAdultHeight)")
        
        let sortedEntries = entries
        print("sortedEntries: \(sortedEntries)")
    
        let chart = LineChartView()
        chart.noDataText = "No growth data available"
        chart.delegate = context.coordinator
        
        // MARK: - Create growth data set
        var growthData: [ChartDataEntry] = []

        for (index, age) in entryAges.enumerated() {
            let heightChange = entryCmChange[index]
            growthData.append(ChartDataEntry(x: age, y: heightChange))
        }
        
        let growthSet = LineChartDataSet(entries: growthData, label: "Cm Growth from Previous Entry")
        growthSet.colors = [.buttonTurquoiseDark]
        growthSet.lineWidth = 2
        growthSet.circleColors = [.buttonTurquoiseDark]
        growthSet.circleRadius = 5
        growthSet.valueFont = .systemFont(ofSize: 10)
        growthSet.drawValuesEnabled = true
        
        let predictedEntry = ChartDataEntry(x: 17.0, y: 0.5)
        let predictedSet = LineChartDataSet(entries: [predictedEntry], label: "Predicted Adult Height: \(predictedAdultHeight)")
        predictedSet.colors = [.red]
        predictedSet.valueFont = .systemFont(ofSize: 10)
        predictedSet.valueTextColor = .red
        predictedSet.drawCirclesEnabled = true
        predictedSet.circleColors = [.red]
        predictedSet.circleRadius = 4
        predictedSet.drawValuesEnabled = false
        
        guard let lastHeightChange = entryCmChange.last, let lastAge = entryAges.last else { return chart }

        let dashedLineEntries: [ChartDataEntry] = [
            ChartDataEntry(x: lastAge, y: lastHeightChange),
            ChartDataEntry(x: 17.0, y: 0.5)
        ]

        let dashedLineSet = LineChartDataSet(entries: dashedLineEntries, label: "Path to Adulthood")
        dashedLineSet.colors = [UIColor.red.withAlphaComponent(0.4)]
        dashedLineSet.lineWidth = 2
        dashedLineSet.drawValuesEnabled = false
        dashedLineSet.drawCirclesEnabled = false
        dashedLineSet.mode = .horizontalBezier
        dashedLineSet.lineDashLengths = [10, 5]

        let data = LineChartData(dataSets: [growthSet, predictedSet, dashedLineSet])
        chart.data = data
        
        let marker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: 140, height: 80))
        marker.chartView = chart
        chart.marker = marker
        
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.granularity = 1
        if let minAge = entryAges.min(), let maxAge = entryAges.max() {
            chart.xAxis.axisMinimum = max(0, minAge - 0.5)
            chart.xAxis.axisMaximum = 18
        } else {
            chart.xAxis.axisMinimum = 0
            chart.xAxis.axisMaximum = 18
        }
        
        chart.xAxis.valueFormatter = DefaultAxisValueFormatter(block: { value, _ in
            String(format: "%.0f yrs", value)
        })
        
        chart.rightAxis.enabled = false
        chart.leftAxis.valueFormatter = DefaultAxisValueFormatter(block: { value, _ in
            String(format: "%.0f", value)
        })

        if let minHeight = growthData.min(by: { $0.y < $1.y })?.y,
           let maxHeight = growthData.max(by: { $0.y < $1.y })?.y {
            let minY = 0.0
            let maxY = max(maxHeight, entryCmChange.last ?? 0.0)
            chart.leftAxis.axisMinimum = minY
            chart.leftAxis.axisMaximum = maxY + 1
            chart.leftAxis.granularity = 1
            chart.leftAxis.granularityEnabled = true
            chart.leftAxis.labelCount = Int((maxY - minY).rounded()) + 2
        }
        
        chart.extraBottomOffset = 10 // Optional: Adjust bottom spacing if needed
        
        return chart
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        // Optional: Update chart data dynamically if needed.
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(chartView: self)
    }

    // MARK: - Coordinator for handling interactions
    class Coordinator: NSObject, ChartViewDelegate {
        var parent: HeightAgeChartView
        var lastTappedX: Double? = nil

        init(chartView: HeightAgeChartView) {
            self.parent = chartView
        }

        func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
            if lastTappedX == entry.x {
                chartView.highlightValue(nil) // remove highlight to hide marker
                lastTappedX = nil
            } else {
                lastTappedX = entry.x

                // Log Mixpanel event
                Mixpanel.mainInstance().track(event: "MIX Chart Dot Tapped", properties: [
                    "x": entry.x,
                    "y": entry.y,
                    "label": chartView.data?.dataSets[highlight.dataSetIndex].label ?? "Unknown"
                ])
            }
        }
    }
}

class CustomMarkerView: MarkerView {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white.withAlphaComponent(0.9)
        layer.cornerRadius = 6
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        label.textAlignment = .center
        addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        if let chartView = self.chartView as? LineChartView,
           let coordinator = chartView.delegate as? HeightAgeChartView.Coordinator,
           let tappedIndex = coordinator.parent.entryAges.firstIndex(where: { $0 == entry.x }) {

            let entryAtIndex = coordinator.parent.entries[tappedIndex]
            let text = """
            Date: \(entryAtIndex.dateOfEntry)
            Height: \(entryAtIndex.height)
            Weight: \(entryAtIndex.weight)
            Sitting height: \(entryAtIndex.sittingHeigh)
            """
            label.text = text
            label.sizeToFit()

            // Resize marker based on content
            let padding: CGFloat = 10
            let newSize = CGSize(width: label.frame.width + padding, height: label.frame.height + padding)
            self.frame.size = newSize
        }

        layoutIfNeeded()
    }

    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        let size = self.bounds.size
        let chartHeight = self.chartView?.bounds.height ?? 0
        let topPadding: CGFloat = 10

        var offsetY = -size.height - topPadding
        let absoluteY = point.y + offsetY

        // If the marker would go above the top of the chart, push it down
        if absoluteY < 0 {
            offsetY = 10 // draw marker below the point
        }

        return CGPoint(x: -size.width / 2, y: offsetY)
    }

    override func draw(context: CGContext, point: CGPoint) {
        let size = self.bounds.size
        let chartWidth = chartView?.bounds.width ?? 0

        var drawPoint = CGPoint(
            x: point.x + offset.x,
            y: point.y + offset.y
        )

        // Clamp horizontally to stay in bounds
        if drawPoint.x < 0 {
            drawPoint.x = 0
        } else if drawPoint.x + size.width > chartWidth {
            drawPoint.x = chartWidth - size.width
        }

        self.frame.origin = drawPoint
        super.draw(context: context, point: point)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds.insetBy(dx: 5, dy: 5)
    }
}

struct GrowthChartTab: View {
    @Binding var childId: String
    @Binding var childName: String
    @Binding var childSurname: String
    @Binding var childDateOfBirth: String
    @Binding var predictedAdultHeightTwoDigits: [Double]
    @Binding var entries: [Entry]
    @Binding var selectedEntry: String
    
    @State private var entryAges: [Double] = []
    @State private var entryCmChange: [Double] = []
    @State private var maxHeight: Double = 160
    
    @State private var showGrowthTempoInfo = false
    @State private var showBiologicalAgeInfo = false
    @State private var showPercentageOfAdultHeightInfo = false
    @State private var showEstimatedAdultHeightInfo = false
    @State private var showMaturityCategoryInfo = false
    
    // Mixpanel variables
    @State private var viewStartTime: Date = Date()
    
    // INFO VARIABLES
    @State var heightChange: Double = 0.0
    @State var weightChange: Double = 0.0
    @State var heightTempo: Double = 0.0
    @State var weightTempo: Double = 0.0
    
    // Question section visibility flag
    @State private var showQuestionSection: Bool = true
        
    // UserDefaults key for tracking whether the question was answered
    private let questionAnsweredKey = "questionAnswered"

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Growth Chart for:")
                    Text("\(childName) \(childSurname)")
                        .foregroundColor(.buttonPurpleLight)
                }
                .padding(.top, 7)
                .padding(.bottom, 4)
                
                Group {
                    HStack {
                        Text("Change in Height (Cm)")
                            .padding(.leading, 25)
                        Spacer()
                    }

                    if !entryAges.isEmpty && !entryCmChange.isEmpty {
                        if entries.count >= 2 {
                            HeightAgeChartView(
                                entries: entries,
                                entryAges: entryAges,
                                entryCmChange: entryCmChange,
                                predictedAdultHeight: predictedAdultHeightTwoDigits.first ?? 0.0
                            )
                            .frame(height: 430)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .padding(.horizontal, 30)
                            .simultaneousGesture(DragGesture())
                        } else if entries.count == 1 {
                            Text("For this graph there should be 2 entries for this child. Please go back to the Home View and add another entry (older or recent one).")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding()
                                .onAppear {
                                    print("⚠️ Only one entry found. Informing user to add more data.")
                                }
                        } else {
                            Text("An entry needs to be added for this graph to display.")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding()
                                .onAppear {
                                    print("❌ No entries available. Prompting user to add the first one.")
                                }
                        }
                    } else {
                        ProgressView("Loading growth chart...")
                            .frame(height: 430)
                    }
                }


                VStack(spacing: 15) {
                    HStack {
                        HStack {
                            Text("Growth Tempo (cm/year)")
                            Spacer()
                            Button(action: { showGrowthTempoInfo.toggle() }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                            .padding(.trailing, 10)
                            .sheet(isPresented: $showGrowthTempoInfo) {
                                GrowthTempoSheet(showGrowthTempoInfo: $showGrowthTempoInfo) // Pass binding
                            }
                        }
                        .frame(minWidth: 250, alignment: .leading)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.black, lineWidth: 0.5)
                        )

                        Text("\(String(format: "%.1f", heightTempo)) cm")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.buttonPurpleLight, lineWidth: 1.5)
                            )
                    }.onTapGesture {
                        Mixpanel.mainInstance().track(event: "MIX Growth Tempo (cm/year) Section Tapped")
                    }
                    
                    HStack {
                        HStack {
                            Text("Body Mass Tempo (kg/year)")
                            Spacer()
                            Button(action: { showGrowthTempoInfo.toggle() }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                            .padding(.trailing, 10)
                            .sheet(isPresented: $showGrowthTempoInfo) {
                                GrowthTempoSheet(showGrowthTempoInfo: $showGrowthTempoInfo) // Pass binding
                            }
                        }
                        .frame(minWidth: 250, alignment: .leading)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.black, lineWidth: 0.5)
                        )

                        Text("\(String(format: "%.1f", weightTempo)) kg")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.buttonPurpleLight, lineWidth: 1.5)
                            )
                    }.onTapGesture {
                        Mixpanel.mainInstance().track(event: "MIX Body Mass Tempo (kg/year) Section Tapped")
                    }
                    
                    HStack {
                        HStack {
                            Text("Height Change (from last)")
                            Spacer()
                            Button(action: { showGrowthTempoInfo.toggle() }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                            .padding(.trailing, 10)
                            .sheet(isPresented: $showGrowthTempoInfo) {
                                GrowthTempoSheet(showGrowthTempoInfo: $showGrowthTempoInfo) // Pass binding
                            }
                        }
                        .frame(minWidth: 250, alignment: .leading)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.black, lineWidth: 0.5)
                        )

                        Text("\(String(format: "%.1f", heightChange)) cm")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.buttonPurpleLight, lineWidth: 1.5)
                            )
                    }.onTapGesture {
                        Mixpanel.mainInstance().track(event: "MIX Height Change (from last) Section Tapped")
                    }
                    
                    HStack {
                        HStack {
                            Text("Mass Change (from last)")
                            Spacer()
                            Button(action: { showGrowthTempoInfo.toggle() }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                            .padding(.trailing, 10)
                            .sheet(isPresented: $showGrowthTempoInfo) {
                                GrowthTempoSheet(showGrowthTempoInfo: $showGrowthTempoInfo) // Pass binding
                            }
                        }
                        .frame(minWidth: 250, alignment: .leading)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.black, lineWidth: 0.5)
                        )

                        Text("\(String(format: "%.1f", weightChange)) kg")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.buttonPurpleLight, lineWidth: 1.5)
                            )
                    }.onTapGesture {
                        Mixpanel.mainInstance().track(event: "MIX Mass Change (from last) Section Tapped")
                    }
                    .padding(.bottom, 20)
                    
                        if showQuestionSection {
                            VStack {
                                Text("Would you like to see a growth representation (Path to Adulthood) generated by AI (Artificial Intelligence) based on path recognition from the latest entry until the predicted adult height?")
                                    .font(.headline)
                                    .padding(.bottom, 10)
                                    .multilineTextAlignment(.center)
                                                
                                HStack(spacing: 20) {
                                    Button("Yes") {
                                        // Track "Yes" event in Mixpanel
                                        Mixpanel.mainInstance().track(event: "MIX ML Implementation Accepted")
                                                        
                                        // Save the decision and hide the section
                                        UserDefaults.standard.set(true, forKey: questionAnsweredKey)
                                            showQuestionSection = false
                                    }
                                    .buttonStyle(DefaultButtonStyle())
                                    .padding()
                                    .frame(width: 100)
                                    .background(Color.buttonPurpleLight)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                                    
                                    Button("No") {
                                        // Track "No" event in Mixpanel
                                        Mixpanel.mainInstance().track(event: "MIX ML Implementation Declined")
                                                        
                                        // Save the decision and hide the section
                                        UserDefaults.standard.set(true, forKey: questionAnsweredKey)
                                            showQuestionSection = false
                                    }
                                    .buttonStyle(DefaultButtonStyle())
                                    .padding()
                                    .frame(width: 100)
                                    .background(Color.buttonPurpleLight)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.top, 20)
                            .padding(.bottom, 30)
                        }
                    
                }.padding()
            }
        }.onAppear {
            viewStartTime = Date()
            Task {
                await storeEntryHeights()
            }
            // Check if the question was already answered
            if UserDefaults.standard.bool(forKey: questionAnsweredKey) {
                showQuestionSection = false
            }
        }
        .onDisappear {
            trackViewTime()
        }
    }
    
    // Mixpanel
    private func trackViewTime() {
        let timeSpent = Date().timeIntervalSince(viewStartTime)
        Mixpanel.mainInstance().track(event: "MIX Growth Chart Tab View Time", properties: ["time_spent": timeSpent])
    }

    func storeEntryHeights() async {
        var convertedAges: [Double] = []

        // Setup formatters for date parsing
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd/MM/yyyy"
        inputFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMM yyyy"
        outputFormatter.timeZone = TimeZone(abbreviation: "UTC")

        print("📅 Selected Entry: \(selectedEntry)")

        // Sort entries in ascending (chronological) order
        let sortedEntries = entries.sorted {
            guard let date1 = inputFormatter.date(from: $0.dateOfEntry),
                  let date2 = inputFormatter.date(from: $1.dateOfEntry) else {
                return false
            }
            return date1 < date2
        }

        print("Sorted entries: \(sortedEntries)")
        // Helper functions
        func convertHeight(_ height: String) -> Double? {
            var cleanedHeight = height.trimmingCharacters(in: .whitespacesAndNewlines)
            var isInches = false

            if cleanedHeight.hasSuffix("in") {
                isInches = true
                cleanedHeight.removeLast(2)
            } else if cleanedHeight.hasSuffix("cm") {
                cleanedHeight.removeLast(2)
            }

            cleanedHeight = cleanedHeight.trimmingCharacters(in: .whitespacesAndNewlines)
            cleanedHeight = cleanedHeight.filter("0123456789.".contains)

            guard let heightValue = Double(cleanedHeight) else { return nil }
            return isInches ? heightValue * 2.54 : heightValue
        }

        func calculateAge(from dateOfBirth: String, referenceDate: String) -> Double? {
            let ageString = calculateAgeInYearsAndMonths(dateOfBirthString: dateOfBirth, referenceDateString: referenceDate)
            return Double(ageString)
        }

        func calculateDaysBetween(startDate: String, endDate: String) -> Int? {
            if let start = inputFormatter.date(from: startDate),
               let end = inputFormatter.date(from: endDate) {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.day], from: start, to: end)
                return components.day
            }
            return nil
        }

        var previousEntry: Entry? = nil

        // Iterate through sorted entries
        for (index, entry) in sortedEntries.enumerated() {
            print("--------------------------------------------------")
            print("📥 Entry date string: \(entry.dateOfEntry)")
            print("📏 Raw height string: \(entry.height)")

            guard let finalHeight = convertHeight(entry.height) else {
                print("❌ Failed to convert height for entry: \(entry.height)")
                continue
            }

            guard let ageDouble = calculateAge(from: childDateOfBirth, referenceDate: entry.dateOfEntry) else {
                print("❌ Failed to calculate age for DOB: \(childDateOfBirth) or entry: \(entry.dateOfEntry)")
                continue
            }

            convertedAges.append(ageDouble)
            print("✅ Final converted age: \(ageDouble) years")

            if let entryDate = inputFormatter.date(from: entry.dateOfEntry) {
                let formatted = outputFormatter.string(from: entryDate)

                if formatted == selectedEntry {
                    if let previous = previousEntry {
                        if let previousHeightValue = convertHeight(previous.height),
                           let previousWeightValue = Double(previous.weight.filter("0123456789.".contains)) {

                            let heightDifference = finalHeight - previousHeightValue
                            let currentWeight = Double(entry.weight.filter("0123456789.".contains)) ?? 0
                            let weightDifference = currentWeight - previousWeightValue

                            heightChange = round(heightDifference * 10) / 10
                            weightChange = round(weightDifference * 10) / 10

                            print("HEIGHT CAHNGE: \(heightChange)")
                            print("WEIGHT CHANGE: \(weightChange)")

                            if let daysBetween = calculateDaysBetween(startDate: previous.dateOfEntry, endDate: entry.dateOfEntry) {
                                print("📅 Days between entries: \(daysBetween) days")

                                heightTempo = round((heightChange / Double(daysBetween)) * 3650) / 10
                                weightTempo = round((weightChange / Double(daysBetween)) * 3650) / 10

                                print("HEIGHT TEMPO: \(heightTempo)")
                                print("WEIGHT TEMPO: \(weightTempo)")
                            } else {
                                print("❌ Could not calculate days between entries.")
                            }

                            print("✅ Matched selected entry!")
                            print("📏 Height change: \(heightChange) cm")
                            print("⚖️ Weight change: \(weightChange) kg")
                        } else {
                            print("❌ Could not convert previous height or weight.")
                        }
                    } else {
                        print("❌ No previous entry found to compare.")
                    }
                }
            }

            previousEntry = entry
        }

        // --- Calculate height changes for graph ---
        for index in 0..<sortedEntries.count {
            if index == 0 {
                entryCmChange.append(0.5)
                print("🔹 Index \(index): Starting height change = 0.5")
            } else {
                let currentRaw = sortedEntries[index].height
                let previousRaw = sortedEntries[index - 1].height
                print("🔍 Index \(index): current = \(currentRaw), previous = \(previousRaw)")

                if let currentHeight = convertHeight(currentRaw),
                   let previousHeight = convertHeight(previousRaw) {
                    let change = abs(currentHeight - previousHeight)
                    entryCmChange.append(change)
                    print("✅ Height change at index \(index): \(change) cm")
                } else {
                    entryCmChange.append(0.0)
                    print("❌ Failed to convert height at index \(index), appending 0.0")
                }
            }
        }

        print("✅ Final converted ages: \(convertedAges)")
        print("📊 Height changes: \(entryCmChange)")

        // Store final data
        entryAges = convertedAges
        entries = sortedEntries // Update original entries to sorted order for graph use
        print("Entries: \(entries)")
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
    GrowthChartTab(
        childId: .constant(""),
        childName: .constant("Sarah"),
        childSurname: .constant("Holmes"),
        childDateOfBirth: .constant("13/08/2016"),
        predictedAdultHeightTwoDigits: .constant([185.0]),
        entries: .constant([
            Entry(
                id: "2C5D4330-1C19-43CF-B98A-B483D6CF700E",
                idUser: "72651404-80b1-70f5-ea4e-793124576b49",
                userName: "Cosmina",
                userSurname: "Dunca",
                weight: "57 kg",
                height: "167 cm",
                sittingHeigh: "89 cm",
                dateOfEntry: "03/03/2025",
                child: Maturity_Monitor.Child(
                    id: "B5CD576C-C04A-4D8F-BE12-FFFF54AB992B",
                    idUser: "72651404-80b1-70f5-ea4e-793124576b49",
                    userName: "Cosmina",
                    userSurname: "Dunca",
                    name: "Sarah",
                    surname: "Holmes",
                    dateOfBirth: "02/06/2016",
                    gender: "Female",
                    motherHeight: "167 cm",
                    fatherHeight: "192 cm",
                    parentsMeasurements: "Estimated",
                    country: "",
                    ethnicity: "",
                    primarySport: "Athletics",
                    approveData: true,
                    uniqueId: 588617,
                    status: Maturity_Monitor.ChildStatus.active,
                    entries: nil,
                    linkChildToUser: nil,
                    createdAt: nil,
                    updatedAt: nil
                ),
                createdAt: nil,
                updatedAt: nil
            )
        ]),
        selectedEntry: .constant("01/03/2022")
    )
}
