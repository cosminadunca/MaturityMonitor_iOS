//
//  MaturityCategorySheet.swift
//  Maturity Monitor
//
//  Created by Cosmina Dunca on 02/03/2025.
//

import SwiftUI

struct MaturityCategorySheet: View {
    
    @Binding var showMaturityCategoryInfo: Bool
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Maturity Category")
                        .foregroundColor(.buttonPurpleLight)
                        .font(Font.custom("Inter-Regular", size: 21))
                        .padding()
                    Spacer()
                    Button(action: {
                        showMaturityCategoryInfo = false // Close the sheet
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
                
                Text("This represents the current phase of the maturation process relative to the period of most intense growth, peak height velocity (PHV).")
                    .padding(.horizontal, 25) // Left and right padding only
                    .padding(.top, 20) // Optional: Adjust top padding if needed
                    .padding(.bottom, 0) // Ensures bottom padding is 0
                    .font(Font.custom("Inter-Italic", size: 17))
                    .foregroundColor(.red)
            }
            
            VStack{
                HStack {
                    Text("Pre-PHV")
                        .foregroundColor(.buttonPurpleLight)
                        .underline() // Underlines the text
                        .padding(.horizontal, 25) // Left and right padding only
                    Spacer()
                }
                .padding(.bottom, 15)
                
                Text ("If pre-PHV: The individual has not yet started the adolescent growth spurt. They will be growing at a steady rate and there should be minimal concerns around training loading or coordination. If symptom free, continue as planned.")
                    .font(Font.custom("Inter-Regular", size: 16))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 15)
                
                Text("If it is PRE-PHV")
                    .font(.subheadline) +
                Text(" it is ")
                    .font(.subheadline) +
                Text("GREEN")
                    .foregroundColor(.green)
                    .font(.subheadline)

                HStack {
                    Text("Mid-PHV")
                        .foregroundColor(.buttonPurpleLight)
                        .underline() // Underlines the text
                        .padding(.horizontal, 25) // Left and right padding only
                    Spacer()
                }
                .padding(.bottom, 25)
                .padding(.top, 10)
                
                Text ("If mid-PHV: This individual is experiencing the adolescent growth spurt and may report symptoms of discomfort or uncoordinated movement. Please be mindful about frequent exposure to high-intensity activity and encourage a diverse movement pattern to assist with coordination related issues.")
                    .font(Font.custom("Inter-Regular", size: 16))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 15)
                
                Text("If it is MID-PHV")
                    .font(.subheadline) +
                Text(" it is ")
                    .font(.subheadline) +
                Text("RED")
                    .foregroundColor(.red)
                    .font(.subheadline)
                
                HStack {
                    Text("Post-PHV")
                        .foregroundColor(.buttonPurpleLight)
                        .underline() // Underlines the text
                        .padding(.horizontal, 25) // Left and right padding only
                    Spacer()
                }
                .padding(.bottom, 25)
                .padding(.top, 10)
                
                Text ("If post-PHV: This individual has progressed through the most rapid period of growth but may still experience some discomfort. The individual may see an increase in body mass over the coming months and should continue to be mindful of training exposure.")
                    .font(Font.custom("Inter-Regular", size: 16))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity) 
                    .padding(.bottom, 15)
                
                Text("If it is POST-PHV")
                    .font(.subheadline) +
                Text(" it is ")
                    .font(.subheadline) +
                Text("AMBER")
                    .foregroundColor(.orange)
                    .font(.subheadline)
            }.padding()
            Spacer()
            // !! Add an ML generated script that finds similar children and give some information on their Chronological Age Growt
            // If possible ask about their nutrition and sleep, etc to find out and generate more details about children
            // Maybe try and include ML to see if it changes the app for better in any way
            // Make the information look even more attractive and understand it better using other info point or colours and mL to transform it even  more
        }
    }
}

#Preview {
    MaturityCategorySheet(showMaturityCategoryInfo: .constant(false))
}
