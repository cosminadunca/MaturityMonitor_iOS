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
    
    // Function to calculate icon weight based on height
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
                HStack {
                    Text("Predicted Adult Height for:")
                    Text("\(childName) \(childSurname)")
                        .foregroundColor(.buttonPurpleLight)
                }
                Text("Current Height: \(Int(childHeight)) cm")
                            
                ZStack(alignment: .bottom) {
                    // Icons and labels (appear above the red line)
                    HStack(spacing: 40) {
                        VStack {
                            Spacer()
                            Text("\(Int(motherHeightDouble)) cm")
                            Image(systemName: "figure.stand.dress")
                                .resizable()
                                .frame(width: iconWeight(for: motherHeightDouble), height: motherHeightDouble * 1.8)
                                .foregroundColor(.buttonPurpleLight)
                        }
                                    
                        VStack {
                            Spacer()
                            ZStack {
                                VStack(spacing: -2) {
                                    Spacer()
                                    if predictedAdultHeightTwoDigits[0] > childHeight {
                                        Image(systemName: "arrow.up")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: CGFloat((predictedAdultHeightTwoDigits[0] - childHeight) * 1.8))
                                            .foregroundColor(.red)
                                    }
                                                    
                                    Image(systemName: childGender == "Female" ? "figure.stand.dress" : "figure.stand")
                                        .resizable()
                                        .frame(width: iconWeight(for: childHeight), height: childHeight * 1.8)
                                        .foregroundColor(childGender == "Female" ? .buttonPurpleLight : .buttonTurquoiseDark)
                                }
                            }
                        }
                                    
                        VStack {
                            Spacer()
                            Text("\(Int(fatherHeightDouble)) cm")
                            Image(systemName: "figure.stand")
                                .resizable()
                                .frame(width: iconWeight(for: fatherHeightDouble), height: fatherHeightDouble * 1.8)
                                .foregroundColor(.buttonTurquoiseDark)
                        }
                    }
                                
                    VStack(spacing: 0) {
                                        // Title above the red line
                                        Text("\(Int(predictedAdultHeightTwoDigits[0])) cm")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.red)
                                            .padding(.bottom, 4) // Add some spacing between the text and the line

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
                                    .offset(y: -CGFloat(predictedAdultHeightTwoDigits[0] * 1.8)) // Adjust position dynamically
                                
                            }
                            .frame(height: 430) // Adjust the overall ZStack height if needed
                
                VStack(spacing: 20) {
                    HStack (spacing: 20) {
                        Text("Chronological Age: ")
                            .padding(10) // Add space between text and border
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                        
                        Text("\(chronologicalAgeString)")
                            .padding(10) // Add space between text and border
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.buttonPurpleLight, lineWidth: 1.5)
                            )
                    }
                    HStack (spacing: 20) {
                        Text("Biological Age: ")
                            .padding(10) // Add space between text and border
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                        
                        Text("\(agePAHString)")
                            .padding(10) // Add space between text and border
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.buttonPurpleLight, lineWidth: 1.5)
                            )
                    }
                    HStack (spacing: 20) {
                        Text("Percentage of Adult Height: ")
                            .padding(10) // Add space between text and border
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                        
                        Text(percentageAH[0])
                            .padding(10) // Add space between text and border
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.buttonPurpleLight, lineWidth: 1.5)
                            )
                    }
                    HStack (spacing: 20) {
                        Text("Estimated Adult Height: ")
                            .padding(10) // Add space between text and border
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                        
                        Text("\(predictedAdultHeightString)")
                            .padding(10) // Add space between text and border
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.buttonPurpleLight, lineWidth: 1.5)
                            )
                    }
                    HStack (spacing: 20) {
                        Text("Maturity Category: ")
                            .padding(10) // Add space between text and border
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                        if (maturityCategory == "pre-PHV") {
                            Text("\(maturityCategory)")
                                .padding(10) // Add space between text and border
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.green, lineWidth: 1.5)
                                )
                        } else if (maturityCategory == "mid-PHV") {
                            Text("\(maturityCategory)")
                                .padding(10) // Add space between text and border
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.red, lineWidth: 1.5)
                                )
                        } else {
                            Text("\(maturityCategory)")
                                .padding(10) // Add space between text and border
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.yellow, lineWidth: 1.5)
                                )
                        }
                    }
                }
                .padding(.top, 30)
                
                Text("Documentaion for the values above:")
                    .padding(.top, 40)
                
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(1..<3) { index in
                        HStack {
                            Text("\(index).")
                                .font(.headline)
                                .padding(.trailing, 5)
                            
                            if index == 1 {
                                Text("Percentage of Adult Height")
                                    .font(.headline)
                                    .font(Font.system(size: 15))
                            } else if index == 2 {
                                Text("Maturity Category")
                                    .font(.headline)
                                    .font(Font.system(size: 15))
                            }
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            if index == 1 {
                                Text("• If percentage is less than 88% it is PRE-PHV")
                                Text("• If percentage is between 88-95% it is MID-PHV")
                                Text("• If percentage is more than 95% it is POST-PHV")
                            } else if index == 2 {
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
                            }
                        }
                        .font(.subheadline)
                        .padding(.leading, 20) // Indentation for bullet points
                    }
                }
                .padding(.top, 10)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .cornerRadius(12)
            .shadow(radius: 5)
            .padding(.bottom, 150)
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
            percentageAH: .constant(["%20"]),
            agePAH: .constant(14.56),
            agePAHString: .constant("14.56"),
            maturityCategory: .constant("mid-PHV")
        )
}
