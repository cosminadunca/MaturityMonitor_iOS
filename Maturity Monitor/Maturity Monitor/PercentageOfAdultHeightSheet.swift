//
//  PercentageOfAdultHeightSheet.swift
//  Maturity Monitor
//
//  Created by Cosmina Dunca on 02/03/2025.
//

import SwiftUI

struct PercentageOfAdultHeightSheet: View {
    
    @Binding var showPercentageOfAdultHeightInfo: Bool
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Percentage Of Adult Height")
                        .foregroundColor(.buttonPurpleLight)
                        .font(Font.custom("Inter-Regular", size: 21))
                        .padding()
                    Spacer()
                    Button(action: {
                        showPercentageOfAdultHeightInfo = false // Close the sheet
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
                
                Text("This is the current progress towards the individual’s predicted adult height.")
                    .padding(.horizontal, 25) // Left and right padding only
                    .padding(.top, 20) // Optional: Adjust top padding if needed
                    .padding(.bottom, 0) // Ensures bottom padding is 0
                    .font(Font.custom("Inter-Italic", size: 17))
                    .foregroundColor(.red)
                
                HStack {
                    Text("Maturity Timing (Early On-Time, Late) – This is calculated by the offset between your chronological age and biological age and represents whether the individual is ahead of typical or delayed in their maturity timing.")
                        .font(Font.custom("Inter-Regular", size: 16))
                        .opacity(0.6) // Adjust opacity to create a lighter/darker shade
                        .multilineTextAlignment(.center) // Aligns text centrally within its space
                        .frame(maxWidth: .infinity) // Ensures text spans the width
                }
                .padding(10)
                
                VStack{
                    HStack {
                        Text("Early")
                            .foregroundColor(.buttonPurpleLight)
                            .underline() // Underlines the text
                            .padding(.horizontal, 25) // Left and right padding only
                        Spacer()
                    }
                    .padding(.bottom, 15)
                    
                    Text ("If early: This individual is developing ahead of the typical curve and therefore may experience growth-related changes ahead of their peers. This individual may find some physical related activities easier than their peers, and therefore should be encouraged to continue to work on technical and tactical aspects of their sport.")
                        .font(Font.custom("Inter-Regular", size: 16))
                        .opacity(0.6) // Adjust opacity to create a lighter/darker shade
                        .multilineTextAlignment(.center) // Aligns text centrally within its space
                        .frame(maxWidth: .infinity) // Ensures text spans the width
                        .padding(.bottom, 15)
                    
                    Text("If percentage is less than 88% it is PRE-PHV")
                        .foregroundColor(.red)
                        .padding(.bottom, 20)
                    
                    HStack {
                        Text("On-Time")
                            .foregroundColor(.buttonPurpleLight)
                            .underline() // Underlines the text
                            .padding(.horizontal, 25) // Left and right padding only
                        Spacer()
                    }
                    .padding(.bottom, 25)
                    
                    Text ("If On-Time: This individual is developing at a typical rate and should therefore find guidelines around exposure and loading appropriate. This does not mean they will not experience discomfort and coordination related issues associated with growing, but these will likely align with others in their peer-group.")
                        .font(Font.custom("Inter-Regular", size: 16))
                        .opacity(0.6) // Adjust opacity to create a lighter/darker shade
                        .multilineTextAlignment(.center) // Aligns text centrally within its space
                        .frame(maxWidth: .infinity) // Ensures text spans the width
                        .padding(.bottom, 15)
                    
                    Text("If percentage is between 88-95% it is MID-PHV")
                        .foregroundColor(.red)
                        .padding(.bottom, 20)
                    
                    HStack {
                        Text("Late")
                            .foregroundColor(.buttonPurpleLight)
                            .underline() // Underlines the text
                            .padding(.horizontal, 25) // Left and right padding only
                        Spacer()
                    }
                    .padding(.bottom, 25)
                    
                    Text ("If late: This individual is developing slower than the typical curve and therefore may experience growth-related changes later than their peers. This individual may find some physical related activities harder than their peers, and therefore should be encouraged to rest and recover between activities and continue to work on the technical and tactical aspects of their sport.")
                        .font(Font.custom("Inter-Regular", size: 16))
                        .opacity(0.6) // Adjust opacity to create a lighter/darker shade
                        .multilineTextAlignment(.center) // Aligns text centrally within its space
                        .frame(maxWidth: .infinity) // Ensures text spans the width
                        .padding(.bottom, 15)
                    
                    Text("If percentage is more than 95% it is POST-PHV")
                        .foregroundColor(.red)
                }.padding()
                
                Spacer()
                // !! Add an ML generated script that finds similar children and give some information on their Chronological Age Growth
                // If possible ask about their nutrition and sleep, etc to find out and generate more details about children
                // Maybe try and include ML to see if it changes the app for better in any way
                // Make the information look even more attractive and understand it better using other info point or colours and mL to transform it even  more
            }
            .padding(.top, 10)
        }
    }
}

#Preview {
    PercentageOfAdultHeightSheet(showPercentageOfAdultHeightInfo: .constant(false))
}
