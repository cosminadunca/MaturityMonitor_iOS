import SwiftUI
import Mixpanel

struct GrowthPercentileSheet: View {
    @Binding var showGrowthPercentileInfo: Bool // Binding to control dismissal
    @State private var chartStartTime: Date?

    var body: some View {
        VStack {
            HStack {
                Text("Growth Percentile Information")
                    .foregroundColor(.buttonPurpleLight)
                    .font(Font.custom("Inter-Regular", size: 21))
                    .padding()
                Spacer()
                Button(action: {
                    showGrowthPercentileInfo = false // Close the sheet
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title)
                }
                .padding()
            }
            .padding(.top, 20)
        }
        .onAppear {
            // Track when the sheet is shown
            chartStartTime = Date()
        }
        .onDisappear {
            // Track when the sheet is dismissed and log the duration
            if let startTime = chartStartTime {
                let duration = Date().timeIntervalSince(startTime)
                Mixpanel.mainInstance().track(event: "MIX Growth Percentile Sheet View", properties: [
                    "duration": duration
                ])
            }
        }
    }
}

#Preview {
    GrowthPercentileSheet(showGrowthPercentileInfo: .constant(false))
}
