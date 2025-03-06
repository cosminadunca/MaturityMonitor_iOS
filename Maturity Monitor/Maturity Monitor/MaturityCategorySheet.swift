//
//  MaturityCategorySheet.swift
//  Maturity Monitor
//
//  Created by Cosmina Dunca on 02/03/2025.
//

import SwiftUI

struct MaturityCategorySheet: View {
    var body: some View {
        VStack {
            HStack{
                Text("Chronological Age Information")
                    .foregroundColor(.buttonPurpleLight)
                    .font(Font.custom("Inter", size: 21))
                    .padding(.top, 30)
                Spacer()
            }
            .font(.headline)
            .padding()
            Text("Definition: Chronological age is the actual age of the child based on their birth date.")
                .padding()
                .font(Font.custom("Inter", size: 15))
            
            // !! Add an ML generated script that finds similar children and give some information on their Chronological Age Growt
            // If possible ask about their nutrition and sleep, etc to find out and generate more details about children
            // Maybe try and include ML to see if it changes the app for better in any way
        }
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, spacing: 5) {
                Text("• If it is PRE-PHV")
                    .font(.subheadline) +
                Text(" it is ")
                    .font(.subheadline) +
                Text("GREEN")
                    .foregroundColor(.green)
                    .font(.subheadline)
                
                Text("• If it is MID-PHV")
                    .font(.subheadline) +
                Text(" it is ")
                    .font(.subheadline) +
                Text("RED")
                    .foregroundColor(.red)
                    .font(.subheadline)
                
                Text("• If it is POST-PHV")
                    .font(.subheadline) +
                Text(" it is ")
                    .font(.subheadline) +
                Text("AMBER")
                    .foregroundColor(.orange)
                    .font(.subheadline)
            }
            .font(.subheadline)
            .padding(.leading, 20) // Indentation for bullet points
        }
        .padding(.top, 10)
        Spacer()
        // !! Add an ML generated script that finds similar children and give some information on their Chronological Age Growt
        // If possible ask about their nutrition and sleep, etc to find out and generate more details about children
        // Maybe try and include ML to see if it changes the app for better in any way
        // Make the information look even more attractive and understand it better using other info point or colours and mL to transform it even  more
    }
}

#Preview {
    MaturityCategorySheet()
}
