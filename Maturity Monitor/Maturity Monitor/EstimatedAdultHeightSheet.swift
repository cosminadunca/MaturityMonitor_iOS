//
//  EstimatedAdultHeightSheet.swift
//  Maturity Monitor
//
//  Created by Cosmina Dunca on 02/03/2025.
//

import SwiftUI

struct EstimatedAdultHeightSheet: View {
    var body: some View {
        HStack{
            Text("Estimated Adult Height")
                .foregroundColor(.buttonPurpleLight)
                .font(Font.custom("Inter", size: 21))
                .padding(.top, 30)
            Spacer()
        }
        .font(.headline)
        .padding()
        Text("Definition: Estimated Adult Height is the actual age of the child based on their birth date.")
            .padding()
            .font(Font.custom("Inter", size: 15))
        
        // !! Add an ML generated script that finds similar children and give some information on their Chronological Age Growt
        // If possible ask about their nutrition and sleep, etc to find out and generate more details about children
        // Maybe try and include ML to see if it changes the app for better in any way
        Spacer()
    }
}

#Preview {
    EstimatedAdultHeightSheet()
}
