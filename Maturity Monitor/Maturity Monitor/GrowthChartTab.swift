import SwiftUI
import Charts
import DGCharts

struct HeightAgeChartView: UIViewRepresentable {
    var entries: [Entry]
    var entryHeights: [Double]

    func makeUIView(context: Context) -> ScatterChartView {
        print("Here!")
        let chart = ScatterChartView()
        chart.noDataText = "No growth data available"
        
        var growthData: [ChartDataEntry] = []

        // Define a date formatter to convert the date string to a Date object
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "MM/dd/yyyy" // Try this format first
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "dd/MM/yyyy" // Try this format as a fallback
        
        // Pair entries with their corresponding heights (entries are already sorted in reverse chronological order)
        var sortedEntries: [(date: Date, height: Double)] = []
        
        // Convert entries and heights into a sorted list
        for (entry, height) in zip(entries, entryHeights) {
            print("Processing entry: \(entry.dateOfEntry), height: \(height)")
            
            // Try parsing the date with both formatters
            var date: Date? = dateFormatter1.date(from: entry.dateOfEntry)
            if date == nil {
                date = dateFormatter2.date(from: entry.dateOfEntry)
            }
            
            if let date = date {
                sortedEntries.append((date, height))
                print("Added entry to sortedEntries: \(date), \(height)")
            } else {
                print("Failed to convert date: \(entry.dateOfEntry)")
            }
        }

        // The sortedEntries are already in inverse chronological order.
        // We can directly start assigning x-values starting from 0 for the most recent entry.

        for (index, item) in sortedEntries.enumerated() {
            let daysSinceStart = Double(index) // Use the index as the x-value
            print("Index: \(index), Date: \(item.date), Height: \(item.height), X: \(daysSinceStart)")
            let dataEntry = ChartDataEntry(x: daysSinceStart, y: item.height)
            growthData.append(dataEntry)
        }
        
        print("Growth Data: \(growthData)")

        let growthSet = ScatterChartDataSet(entries: growthData, label: "Child Growth")
        growthSet.colors = [.systemBlue]
        growthSet.setScatterShape(.circle)
        growthSet.scatterShapeSize = 8

        let chartData = ScatterChartData(dataSet: growthSet)
        chart.data = chartData

        chart.xAxis.labelPosition = .bottom
        chart.xAxis.granularity = 1
        chart.xAxis.axisMinimum = 0
        chart.xAxis.labelTextColor = .darkGray
        chart.xAxis.labelFont = .systemFont(ofSize: 12)

        chart.rightAxis.enabled = false
        chart.legend.enabled = true
        chart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)

        return chart
    }

    func updateUIView(_ uiView: ScatterChartView, context: Context) {
        // Update chart if needed
    }
}

struct GrowthChartTab: View {
    @Binding var childId: String
    @Binding var childName: String
    @Binding var childSurname: String
    @Binding var predictedAdultHeightTwoDigits: [Double]
    @Binding var entries: [Entry]
    
    @State private var entryHeights: [Double] = []
    @State private var maxHeight: Double = 160

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Growth Chart for:")
                    Text("\(childName) \(childSurname)")
                        .foregroundColor(.buttonPurpleLight)
                }
                
                Text("This graphs uses all the existing entries.")
                
                Group {
                    if !entryHeights.isEmpty {
                        HeightAgeChartView(entries: entries, entryHeights: entryHeights)
                            .frame(height: 470)
                            .clipped()
                    } else {
                        Text("No data available")
                    }
                }
                .onAppear {
                    Task {
                        await storeEntryHeights()
                        print("Stored Entry Heights: \(entryHeights)")
                    }
                }
            }
        }
    }

    func storeEntryHeights() async {
        print("Starting height conversion...")

        entryHeights = await entries.compactMap { entry in
            var cleanedHeight = entry.height.trimmingCharacters(in: .whitespacesAndNewlines)
            print("Original height: \(cleanedHeight)")

            var isInches = false

            if cleanedHeight.hasSuffix("in") {
                isInches = true
                cleanedHeight.removeLast(2)
            } else if cleanedHeight.hasSuffix("cm") {
                cleanedHeight.removeLast(2)
            }

            cleanedHeight = cleanedHeight.trimmingCharacters(in: .whitespacesAndNewlines)
            print("After unit removal & extra trimming:", cleanedHeight)

            cleanedHeight = cleanedHeight.filter("0123456789.".contains)
            print("After filtering non-numeric: \(cleanedHeight)")

            if let heightValue = Double(cleanedHeight) {
                let finalHeight = isInches ? heightValue * 2.54 : heightValue
                print("Converted height: \(finalHeight) cm")
                return finalHeight
            } else {
                print("Conversion failed for: \(cleanedHeight)")
                return nil
            }
        }

        print("Final Converted Heights List: \(entryHeights)")
    }
}

#Preview {
    GrowthChartTab(
        childId: .constant(""),
        childName: .constant("Sarah"),
        childSurname: .constant("Holmes"),
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
        ])
    )
}
