//
//  GrowthGraphTab.swift
//  Maturity Monitor
//
//  Created by Cosmina Dunca on 02/03/2025.
//

import SwiftUI
import Charts
import DGCharts
import Amplify

struct GrowthData {
    var year: Int
    var height: Double
}

struct GrowthChartView: View {
    let growthData: [GrowthData] = [
        GrowthData(year: 0, height: 50),  // Newborn
        GrowthData(year: 1, height: 75),
        GrowthData(year: 2, height: 85),
        GrowthData(year: 3, height: 95),
        GrowthData(year: 4, height: 105),
        GrowthData(year: 5, height: 110),
        GrowthData(year: 10, height: 130),
        GrowthData(year: 15, height: 150),
        GrowthData(year: 20, height: 165),
        GrowthData(year: 25, height: 170)
    ]
    
    var body: some View {
        VStack {
            ChartView(data: chartData)
                .frame(height: 470)  // Make the chart bigger
        }
    }
    
    var chartData: [ChartDataEntry] {
        return growthData.map { ChartDataEntry(x: Double($0.year), y: $0.height) }
    }
}

struct ChartView: UIViewRepresentable {
    var data: [ChartDataEntry]
    
    func makeUIView(context: Context) -> LineChartView {
        let chart = LineChartView()
        chart.noDataText = "No Data Available"
        chart.xAxis.labelPosition = .bottom
        chart.leftAxis.axisMinimum = 0
        chart.rightAxis.enabled = false
        
        return chart
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        let dataSet = LineChartDataSet(entries: data, label: "Height Over Time")
        
        // Reduce prominence of dots (set circle size to smaller)
        dataSet.drawCirclesEnabled = true
        dataSet.circleRadius = 4  // Smaller dot size
        dataSet.circleHoleRadius = 2  // Circle hole in the center of dots
        
        dataSet.colors = [NSUIColor.blue]
        dataSet.valueColors = [NSUIColor.black]
        dataSet.valueFont = .systemFont(ofSize: 12)
        
        let data = LineChartData(dataSet: dataSet)
        uiView.data = data
    }
}

struct GrowthGraphTab: View {
    
    // Important values for the graph
    @Binding var childId: String
    @Binding var predictedAdultHeightTwoDigits: [Double]
    
//    @Binding var entries: [Entry]
    
    var body: some View {
        ScrollView {
            HStack {
                Text("Growth Chart for:")
                Text("Blah Blah")
                    .foregroundColor(.buttonPurpleLight)
                // Text("\(childName) \(childSurname)")
                    .foregroundColor(.buttonPurpleLight)
            }
            GrowthChartView()
        }
    }
    
    
}

#Preview {
    GrowthGraphTab(
        childId: .constant("SKSL"),
        predictedAdultHeightTwoDigits: .constant([185.0])
//        entries: .constant([
//            Entry(id: "2C5D4330-1C19-43CF-B98A-B483D6CF700E", idUser: "72651404-80b1-70f5-ea4e-793124576b49", userName: "Cosmina", userSurname: "Dunca", weight: "57 kg", height: "167 cm", sittingHeigh: "89 cm", dateOfEntry: "03/03/2025", child: Maturity_Monitor.Child(id: "B5CD576C-C04A-4D8F-BE12-FFFF54AB992B", idUser: "72651404-80b1-70f5-ea4e-793124576b49", userName: "Cosmina", userSurname: "Dunca", name: "Sarah", surname: "Holmes", dateOfBirth: "02/06/2016", gender: "Female", motherHeight: "167 cm", fatherHeight: "192 cm", parentsMeasurements: "Estimated", country: "", ethnicity: "", primarySport: "Athletics", approveData: true, uniqueId: 588617, status: Maturity_Monitor.ChildStatus.active, entries: "Optional(Amplify.List<Maturity_Monitor.Entry>)", linkChildToUser: "Optional(Amplify.List<Maturity_Monitor.LinkChildToUser>)", createdAt: nil, updatedAt: nil), createdAt: nil, updatedAt: nil)
//                ])
    )
}
