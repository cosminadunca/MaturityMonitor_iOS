//
//  PercentageOfAdultHeightSheet.swift
//  Maturity Monitor
//
//  Created by Cosmina Dunca on 02/03/2025.
//

import SwiftUI

struct PercentageOfAdultHeightSheet: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack{
                Text("Percentage Of Adult Height")
                    .foregroundColor(.buttonPurpleLight)
                    .font(Font.custom("Inter", size: 21))
                    .padding(.top, 30)
                Spacer()
            }
            .font(.headline)
            .padding()
            Text("Definition: Percentage Of Adult Height is the actual age of the child based on their birth date.")
                .padding()
                .font(Font.custom("Inter", size: 15))
            
            VStack{
                Text("If percentage is less than 88% it is PRE-PHV")
                Text("If percentage is between 88-95% it is MID-PHV")
                Text("If percentage is more than 95% it is POST-PHV")
            }.padding()
            .foregroundColor(.red)
            
            Spacer()
            // !! Add an ML generated script that finds similar children and give some information on their Chronological Age Growt
            // If possible ask about their nutrition and sleep, etc to find out and generate more details about children
            // Maybe try and include ML to see if it changes the app for better in any way
            // Make the information look even more attractive and understand it better using other info point or colours and mL to transform it even  more
        }
        .padding(.top, 10)
    }
}

#Preview {
    PercentageOfAdultHeightSheet()
}
