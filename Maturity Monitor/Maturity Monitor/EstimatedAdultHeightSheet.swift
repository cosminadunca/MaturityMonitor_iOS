//
//  EstimatedAdultHeightSheet.swift
//  Maturity Monitor
//
//  Created by Cosmina Dunca on 02/03/2025.
//

import SwiftUI
import Mixpanel

struct EstimatedAdultHeightSheet: View {
    @Binding var showEstimatedAdultHeightInfo: Bool
    @State private var chartStartTime: Date?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Estimated Adult Height")
                        .foregroundColor(.buttonPurpleLight)
                        .font(Font.custom("Inter-Regular", size: 21))
                        .padding()
                    Spacer()
                    Button(action: {
                        showEstimatedAdultHeightInfo = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title)
                    }
                    .padding()
                }
                .padding(.top, 20)

                HStack {
                    Text("Definition:")
                        .underline()
                        .padding(.horizontal, 25)
                        .padding(.top, 30)
                    Spacer()
                }

                Text("This is the estimated stature of the individual when they reach full stature.")
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                    .font(Font.custom("Inter-Italic", size: 17))
                    .foregroundColor(.red)

                // !! Add an ML generated script that finds similar children and give some information on their Chronological Age Growth
                // If possible ask about their nutrition and sleep, etc to find out and generate more details about children
                // Maybe try and include ML to see if it changes the app for better in any way

                Spacer()
            }
            .padding(.top, 10)
        }
        .onAppear {
            chartStartTime = Date()
        }
        .onDisappear {
            if let start = chartStartTime {
                let duration = Date().timeIntervalSince(start)
                Mixpanel.mainInstance().track(event: "MIX Estimated Adult Height Sheet View Time", properties: [
                    "duration_seconds": Int(duration)
                ])
            }
        }
    }
}

#Preview {
    EstimatedAdultHeightSheet(showEstimatedAdultHeightInfo: .constant(false))
}
