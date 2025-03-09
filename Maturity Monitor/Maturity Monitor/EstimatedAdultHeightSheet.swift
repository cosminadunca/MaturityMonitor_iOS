//
//  EstimatedAdultHeightSheet.swift
//  Maturity Monitor
//
//  Created by Cosmina Dunca on 02/03/2025.
//

import SwiftUI

struct EstimatedAdultHeightSheet: View {
    @Binding var showEstimatedAdultHeightInfo: Bool // Binding to control dismissal
    var body: some View {
        HStack {
            Text("Percentage Of Adult Height")
                .foregroundColor(.buttonPurpleLight)
                .font(Font.custom("Inter-Regular", size: 21))
                .padding()
            Spacer()
            Button(action: {
                showEstimatedAdultHeightInfo = false // Close the sheet
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

        Text("This is the estimated stature of the individual when they reach full stature.")
            .padding(.horizontal, 25) // Left and right padding only
            .padding(.top, 20) // Optional: Adjust top padding if needed
            .padding(.bottom, 0) // Ensures bottom padding is 0
            .font(Font.custom("Inter-Italic", size: 17))
            .foregroundColor(.red)
        
        // !! Add an ML generated script that finds similar children and give some information on their Chronological Age Growt
        // If possible ask about their nutrition and sleep, etc to find out and generate more details about children
        // Maybe try and include ML to see if it changes the app for better in any way
        Spacer()
    }
}

#Preview {
    EstimatedAdultHeightSheet(showEstimatedAdultHeightInfo: .constant(false))
}
