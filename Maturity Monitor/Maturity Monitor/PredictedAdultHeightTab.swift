import SwiftUI

struct PredictedAdultHeight: View {
    
    @Binding var motherHeightDouble: Double
    @Binding var fatherHeightDouble: Double
    @Binding var predictedAdultHeightTwoDigits: [Double]
    @Binding var childGender: String
    @Binding var childName: String
    @Binding var childSurname: String
    @Binding var childHeight: Double
    
    @State private var redLine: Double = 130.0
    
    @Binding var chronologicalAgeString: String
    @Binding var predictedAdultHeightString: String
    @Binding var percentageAH: [String]
    @Binding var agePAH: Double
    @Binding var agePAHString: String
    @Binding var maturityCategory: String
    
    @State private var showChronologicalAgeInfo = false
    @State private var showBiologicalAgeInfo = false
    @State private var showPercentageOfAdultHeightInfo = false
    @State private var showEstimatedAdultHeightInfo = false
    @State private var showMaturityCategoryInfo = false
    
    private func iconWeight(for height: Double) -> CGFloat {
        switch height {
        case ..<60:
            return 35
        case 60..<100:
            return 45
        case 100..<140:
            return 55
        case 140..<180:
            return 70
        case 180..<220:
            return 80
        default:
            return 80
        }
    }
    
    // Function to calculate and return red line difference
    private func calculateRedLine() -> CGFloat {
        let difference = predictedAdultHeightTwoDigits[0] - childHeight
        return CGFloat(difference) // Ensure the value is a CGFloat
    }
    
    var body: some View {
        ScrollView {
            VStack {
                // Title of the graph
                HStack {
                    Text("Predicted Adult Height for:")
                    Text("\(childName) \(childSurname)")
                        .foregroundColor(.buttonPurpleLight)
                }
                            
                ZStack(alignment: .bottom) {
                    // Icons and labels (appear above the red line)
                    HStack(spacing: 40) {
                        VStack {
                            Spacer()
                            Image(systemName: "figure.stand.dress")
                                .resizable()
                                .frame(width: iconWeight(for: motherHeightDouble), height: motherHeightDouble * 1.8)
                                .foregroundColor(.buttonPurpleLight)
                            Text("\(Int(motherHeightDouble)) cm")
                                .font(Font.custom("Inter", size: 14))
                            Text("Mother")
                                .font(Font.custom("Inter", size: 14))
                                .foregroundColor(Color.buttonPurpleLight)
                        }
                                    
                        VStack {
                            Spacer()
                            ZStack {
                                VStack {
                                    Spacer()
                                    if predictedAdultHeightTwoDigits[0] > childHeight {
                                        Image(systemName: "arrow.up")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: CGFloat((predictedAdultHeightTwoDigits[0] - childHeight) * 1.8))
                                            .foregroundColor(.red)
                                            .padding(.bottom, -10)
                                    }
                                                    
                                    Image(systemName: childGender == "Female" ? "figure.stand.dress" : "figure.stand")
                                        .resizable()
                                        .frame(width: iconWeight(for: childHeight), height: childHeight * 1.8)
                                        .foregroundColor(childGender == "Female" ? .groupPink : .buttonTurquoiseLight)
                                    Text("\(Int(childHeight)) cm")
                                        .font(Font.custom("Inter", size: 14))
                                    Text("Child")
                                        .font(Font.custom("Inter", size: 14))
                                        .foregroundColor(childGender == "Female" ? .groupPink : .buttonTurquoiseLight)
                                }
                            }
                        }
                                    
                        VStack {
                            Spacer()
                            Image(systemName: "figure.stand")
                                .resizable()
                                .frame(width: iconWeight(for: fatherHeightDouble), height: fatherHeightDouble * 1.8)
                                .foregroundColor(.buttonTurquoiseDark)
                            Text("\(Int(fatherHeightDouble)) cm")
                                .font(Font.custom("Inter", size: 14))
                            Text("Father")
                                .font(Font.custom("Inter", size: 14))
                                .foregroundColor(Color.buttonTurquoiseDark)
                        }
                    }
                                
                    VStack(spacing: 0) {
                        Spacer()
                        // Title above the red line
                        Text("\(Int(predictedAdultHeightTwoDigits[0])) cm")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .padding(.bottom, 5)

                        // Red dashed line dynamically adjusted to the width of the child icon
                        HStack(spacing: 4) {
                            ForEach(0..<10, id: \.self) { _ in
                                Rectangle()
                                    .frame(width: 8, height: 2) // Dashed line dimensions
                                    .foregroundColor(.red)
                            }
                        }
                        .frame(width: iconWeight(for: childHeight)) // Match the width of the child icon
                    }
                    .offset(y: -CGFloat(predictedAdultHeightTwoDigits[0] * 1.8) - 28 - 10)
                                
                }
                .frame(height: 430) // Adjust the overall ZStack height if needed
                
                VStack(spacing: 15) {
                    HStack {
                        HStack {
                            Text("Chronological Age")
                            Spacer()
                            Button(action: { showChronologicalAgeInfo.toggle() }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                            .padding(.trailing, 10)
                            .sheet(isPresented: $showChronologicalAgeInfo) {
                                ChronologicalAgeSheet() // Opens the ChronologicalAgeSheet view
                            }
                        }
                        .frame(minWidth: 245, alignment: .leading)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.black, lineWidth: 0.5)
                        )

                        Text("\(chronologicalAgeString)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.buttonPurpleLight, lineWidth: 1.5)
                            )
                    }
                    
                    HStack {
                        HStack {
                            Text("Biological Age")
                            
                            Spacer() // Pushes the button to the right
                            
                            Button(action: { showBiologicalAgeInfo.toggle() }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                            .padding(.trailing, 10) // Adds some space between the button and the border
                            .sheet(isPresented: $showBiologicalAgeInfo) {
                                BiologicalAgeSheet() // Opens the BiologicalAgeSheet view
                            }
                        }
                        .frame(minWidth: 245, alignment: .leading)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.black, lineWidth: 0.5)
                        )
                        Text("\(agePAHString)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.buttonPurpleLight, lineWidth: 1.5)
                            )
                    }
                    
                    HStack {
                        HStack {
                            Text("Percentage of Adult Height")
                            Spacer() // Pushes the button to the right
                            
                            Button(action: { showPercentageOfAdultHeightInfo.toggle() }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                            .padding(.trailing, 10) // Adds some space between the button and the border
                            .sheet(isPresented: $showPercentageOfAdultHeightInfo) {
                                PercentageOfAdultHeightSheet() // Opens the PercentageOfAdultHeightSheet view
                            }
                        }
                        .frame(minWidth: 245, alignment: .leading)
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                        Text(percentageAH[0])
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.buttonPurpleLight, lineWidth: 1.5)
                            )
                    }
                    
                    HStack {
                        HStack {
                            Text("Estimated Adult Height")
                            Spacer() // Pushes the button to the right
                            
                            Button(action: { showEstimatedAdultHeightInfo.toggle() }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                            .padding(.trailing, 10) // Adds some space between the button and the border
                            .sheet(isPresented: $showEstimatedAdultHeightInfo) {
                                EstimatedAdultHeightSheet() // Opens the EstimatedAdultHeightSheet view
                            }
                        }
                        .frame(minWidth: 245, alignment: .leading)
                            .padding(9)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                        Text("\(predictedAdultHeightString)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(9)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.buttonPurpleLight, lineWidth: 1.5)
                            )
                    }
                    
                    HStack {
                        HStack {
                            Text("Maturity Category")
                            Spacer() // Pushes the button to the right
                            
                            Button(action: { showMaturityCategoryInfo.toggle() }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                            .padding(.trailing, 10) // Adds some space between the button and the border
                            .sheet(isPresented: $showMaturityCategoryInfo) {
                                MaturityCategorySheet() // Opens the MaturityCategorySheet view
                            }
                        }
                        .frame(minWidth: 245, alignment: .leading)
                        .padding(9)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.black, lineWidth: 0.5)
                        )
                        let maturityColor: Color = maturityCategory == "pre-PHV" ? .green : maturityCategory == "mid-PHV" ? .red : .yellow
                        
                        Text("\(maturityCategory)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(9)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(maturityColor, lineWidth: 1.5)
                            )
                    }
                    .padding(.bottom, 50)
                }
                .padding(.top, 30)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .cornerRadius(12)
            .shadow(radius: 5)
        }
    }
}

#Preview {
    // Pass the bindings for each property
        PredictedAdultHeight(
            motherHeightDouble: .constant(180.0),
            fatherHeightDouble: .constant(220.0),
            predictedAdultHeightTwoDigits: .constant([185.0]),
            childGender: .constant("Female"),
            childName: .constant("Sarah"),
            childSurname: .constant("Holmes"),
            childHeight: .constant(150.0),
            chronologicalAgeString: .constant("12.5 yrs"),
            predictedAdultHeightString: .constant("189 cm"),
            percentageAH: .constant(["20%"]),
            agePAH: .constant(14.56),
            agePAHString: .constant("14.56"),
            maturityCategory: .constant("mid-PHV")
        )
}
