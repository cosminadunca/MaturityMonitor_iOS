// AddChildStepFour View comments and messages done - needs testing

import SwiftUI

struct AddChildStepFourView: View {
    
    @Environment(\.presentationMode) private var presentationMode // Back button
    @ObservedObject var childDetails: ChildDetailsModel
    
    @State private var navigateToNextView: Bool = false
    
    // Units
    let countryUnits = ["Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua & Deps", "Argentina", "Armenia", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia", "Bosnia Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Central African Rep", "Chad", "Chile", "China", "Colombia", "Comoros", "Congo", "Congo {Democratic Rep}", "Costa Rica", "Croatia", "Cuba", "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "East Timor", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Fiji", "Finland", "France", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Honduras", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland {Republic}", "Israel", "Italy", "Ivory Coast", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Korea North", "Korea South", "Kosovo", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Macedonia", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius", "Mexico", "Micronesia", "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique", "Myanmar, {Burma}", "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Norway", "Oman", "Pakistan", "Palau", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Romania", "Russian Federation", "Rwanda", "St Kitts & Nevis", "St Lucia", "Saint Vincent & the Grenadines", "Samoa", "San Marino", "Sao Tome & Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Swaziland", "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Togo", "Tonga", "Trinidad & Tobago", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "Uruguay", "Uzbekistan", "Vanuatu", "Vatican City", "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe"]
    
    let ethnicityUnits = [
        "Asian, British Asian, Welsh Asian",
        "Black, British Black, Welsh Black, Caribbean, African",
        "Mixed or Multiple Ethnicities",
        "White: UK or British",
        "White: Irish",
        "White: Gypsy, Traveller, Roma, or Other White",
        "Other Ethnic Group"
    ]
    
    let sportUnits = ["Triathlon","Tennis","Swimming","Squash","Running","Rugby Union","Rugby League","Netball","Hockey (Ice)","Hockey (Field)","Golf","Football","Cycling","Crossfit","Cricket","Boxing","Basketball","Badminton","Athletics","American Football"]
    
    var body: some View {
        VStack {
            Spacer()
            Spacer()
            SimpleCustomTextTitle(title: "Child's details")
            Text("(Optional)")
                .font(Font.custom("Inter", size: 15))
                .foregroundColor(.black)
                .padding(.top, 20)
            Spacer()
            VStack(alignment: .leading) {
                DropDownTextField(
                    label: "Country",
                    placeholder: "Select Country",
                    fieldWidth: 170,
                    units: countryUnits,
                    text: $childDetails.country,
                    selectedUnit: $childDetails.country,
                    isTextFieldDisabled: true
                )
                DropDownTextField(
                    label: "Ethnicity",
                    placeholder: "Select Ethnicity",
                    fieldWidth: 170,
                    units: ethnicityUnits,
                    text: $childDetails.ethnicity,
                    selectedUnit: $childDetails.ethnicity,
                    isTextFieldDisabled: true
                ).padding(.top, 10)
                DropDownTextField(
                    label: "Primary Sport",
                    placeholder: "Select Sport",
                    fieldWidth: 170,
                    units: sportUnits,
                    text: $childDetails.primarySport,
                    selectedUnit: $childDetails.primarySport,
                    isTextFieldDisabled: true
                ).padding(.top, 10)
            }
            .padding()
            
            Spacer()
            Spacer()
            Spacer()
            
            HStack(spacing: 10) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    CustomButton(
                        title: "Previous step",
                        backgroundColor: Color(.buttonGreyLight),
                        textColor: .black
                    )
                }
                NavigationLink(destination: AddChildStepFiveView(childDetails: childDetails), isActive: $navigateToNextView) {
                    EmptyView()
                }
                Button(action: {
                    navigateToNextView = true
                }) {
                    CustomButton(
                        title: "Next step",
                        backgroundColor: Color(.buttonGreyLight),
                        textColor: .black
                    )
                }
            }
            .padding(.bottom, 60)
            ProgressBar(progressMultiplier: 4)
        }
        .onTapGesture {
            hideKeyboard() // Hide keyboard when tapping outside
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        hideKeyboard()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    AddChildStepFourView(childDetails: ChildDetailsModel())
}
