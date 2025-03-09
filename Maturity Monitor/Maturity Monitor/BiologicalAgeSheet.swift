//
//  BiologicalAgeSheet.swift
//  Maturity Monitor
//
//  Created by Cosmina Dunca on 02/03/2025.
//

import SwiftUI

struct BiologicalAgeSheet: View {
    @Binding var showBiologicalAgeInfo: Bool // Binding to control dismissal
    var body: some View {
        VStack {
            HStack {
                Text("Biological Age Information")
                    .foregroundColor(.buttonPurpleLight)
                    .font(Font.custom("Inter-Regular", size: 21))
                    .padding()
                Spacer()
                Button(action: {
                    showBiologicalAgeInfo = false // Close the sheet
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

            Text("This is the biological age of the individual, which may vary from chronological age based on the developmental stage of the individual.")
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
}

#Preview {
    BiologicalAgeSheet(showBiologicalAgeInfo: .constant(false))
}
