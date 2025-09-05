//
//  MaturityCategorySheet.swift
//  Maturity Monitor
//
//  Created by Cosmina Dunca on 02/03/2025.
//

import SwiftUI
import Mixpanel

struct MaturityCategorySheet: View {
    
    @Binding var showMaturityCategoryInfo: Bool
    @State private var chartStartTime: Date?
    
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
                        showMaturityCategoryInfo = false
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

                Text("This represents the current phase of the maturation process relative to the period of most intense growth, peak height velocity (PHV).")
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                    .font(Font.custom("Inter-Italic", size: 17))
                    .foregroundColor(.red)
            }

            VStack(spacing: 25) {
                // PRE-PHV
                VStack(spacing: 10) {
                    HStack {
                        Text("Pre-PHV")
                            .foregroundColor(.buttonPurpleLight)
                            .underline()
                            .padding(.horizontal, 25)
                        Spacer()
                    }

                    Text("If pre-PHV: The individual has not yet started the adolescent growth spurt. They will be growing at a steady rate and there should be minimal concerns around training loading or coordination. If symptom free, continue as planned.")
                        .font(Font.custom("Inter-Regular", size: 16))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    
                    HStack(spacing: 0) {
                        Text("If it is PRE-PHV").font(.subheadline)
                        Text(" it is ").font(.subheadline)
                        Text("GREEN")
                            .foregroundColor(.green)
                            .font(.subheadline)
                    }
                }

                // MID-PHV
                VStack(spacing: 10) {
                    HStack {
                        Text("Mid-PHV")
                            .foregroundColor(.buttonPurpleLight)
                            .underline()
                            .padding(.horizontal, 25)
                        Spacer()
                    }

                    Text("If mid-PHV: This individual is experiencing the adolescent growth spurt and may report symptoms of discomfort or uncoordinated movement. Please be mindful about frequent exposure to high-intensity activity and encourage a diverse movement pattern to assist with coordination related issues.")
                        .font(Font.custom("Inter-Regular", size: 16))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    
                    HStack(spacing: 0) {
                        Text("If it is MID-PHV").font(.subheadline)
                        Text(" it is ").font(.subheadline)
                        Text("RED")
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }
                }

                // POST-PHV
                VStack(spacing: 10) {
                    HStack {
                        Text("Post-PHV")
                            .foregroundColor(.buttonPurpleLight)
                            .underline()
                            .padding(.horizontal, 25)
                        Spacer()
                    }

                    Text("If post-PHV: This individual has progressed through the most rapid period of growth but may still experience some discomfort. The individual may see an increase in body mass over the coming months and should continue to be mindful of training exposure.")
                        .font(Font.custom("Inter-Regular", size: 16))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    
                    HStack(spacing: 0) {
                        Text("If it is POST-PHV").font(.subheadline)
                        Text(" it is ").font(.subheadline)
                        Text("AMBER")
                            .foregroundColor(.orange)
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            
            Spacer()
        }
        .onAppear {
            chartStartTime = Date()
        }
        .onDisappear {
            if let start = chartStartTime {
                let duration = Date().timeIntervalSince(start)
                Mixpanel.mainInstance().track(event: "MIX Maturity Category Sheet View Time", properties: [
                    "duration_seconds": Int(duration)
                ])
            }
        }
    }
}

#Preview {
    MaturityCategorySheet(showMaturityCategoryInfo: .constant(false))
}
