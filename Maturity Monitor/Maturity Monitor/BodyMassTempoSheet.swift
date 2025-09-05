import SwiftUI
import Mixpanel

struct BodyMassTempoSheet: View {
    @Binding var showBodyMassTempoInfo: Bool // Binding to control dismissal
    @State private var chartStartTime: Date?

    var body: some View {
        VStack {
            HStack {
                Text("Body Mass Tempo Information")
                    .foregroundColor(.buttonPurpleLight)
                    .font(Font.custom("Inter-Regular", size: 21))
                    .padding()
                Spacer()
                Button(action: {
                    showBodyMassTempoInfo = false // Close the sheet
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title)
                }
                .padding()
            }
            .padding(.top, 20)

            HStack {
                Text("Definition: ")
                    .underline() // Underlines the text
                    .padding(.horizontal, 25) // Left and right padding only
                    .padding(.top, 30)
                Spacer()
            }

            Text("This is the current rate of change in body mass. This is typically presented to illustrate how much change would be observed if this rate continued for a year. A mass tempo of 4kg/year or more is considered high and likely coincides with Peak Weight Velocity (PWV) following the adolescent growth spurt.")
                .padding(.horizontal, 25) // Left and right padding only
                .padding(.top, 20) // Optional: Adjust top padding if needed
                .padding(.bottom, 0) // Ensures bottom padding is 0
                .font(Font.custom("Inter-Italic", size: 17))
                .foregroundColor(.red)

            Spacer()
        }
        .onAppear {
            // Track when the sheet is shown
            chartStartTime = Date()
        }
        .onDisappear {
            // Track when the sheet is dismissed and log the duration
            if let startTime = chartStartTime {
                let duration = Date().timeIntervalSince(startTime)
                Mixpanel.mainInstance().track(event: "MIX Body Mass Tempo Sheet Time", properties: [
                    "duration": duration
                ])
            }
        }
    }
}

#Preview {
    BodyMassTempoSheet(showBodyMassTempoInfo: .constant(false))
}
