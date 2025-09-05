// AddChildStepFour View comments and messages done - needs testing

import SwiftUI
import Mixpanel

struct AddChildStepFourView: View {
    
    @Environment(\.presentationMode) private var presentationMode // Back button
    @ObservedObject var childDetails: ChildDetailsModel
    
    @State private var navigateToNextView: Bool = false
    
    // Mixpanel variables
    @State private var viewStartTime: Date = Date()
    @Binding var numberOfStepsBack: Double
    
    // Units
    let countryUnits = [String(localized: "Afghanistan"), String(localized: "Albania"), String(localized: "Algeria"), String(localized: "Andorra"), String(localized: "Angola"), String(localized: "Antigua & Deps"), String(localized: "Argentina"), String(localized: "Armenia"), String(localized: "Australia"), String(localized: "Austria"), String(localized: "Azerbaijan"), String(localized: "Bahamas"), String(localized: "Bahrain"), String(localized: "Bangladesh"), String(localized: "Barbados"), String(localized: "Belarus"), String(localized: "Belgium"), String(localized: "Belize"), String(localized: "Benin"), String(localized: "Bhutan"), String(localized: "Bolivia"), String(localized: "Bosnia Herzegovina"), String(localized: "Botswana"), String(localized: "Brazil"), String(localized: "Brunei"), String(localized: "Bulgaria"), String(localized: "Burkina"), String(localized: "Burundi"), String(localized: "Cambodia"), String(localized: "Cameroon"), String(localized: "Canada"), String(localized: "Cape Verde"), String(localized: "Central African Rep"), String(localized: "Chad"), String(localized: "Chile"), String(localized: "China"), String(localized: "Colombia"), String(localized: "Comoros"), String(localized: "Congo"), String(localized: "Congo {Democratic Rep}"), String(localized: "Costa Rica"), String(localized: "Croatia"), String(localized: "Cuba"), String(localized: "Cyprus"), String(localized: "Czech Republic"), String(localized: "Denmark"), String(localized: "Djibouti"), String(localized: "Dominica"), String(localized: "Dominican Republic"), String(localized: "East Timor"), String(localized: "Ecuador"), String(localized: "Egypt"), String(localized: "El Salvador"), String(localized: "Equatorial Guinea"), String(localized: "Eritrea"), String(localized: "Estonia"), String(localized: "Ethiopia"), String(localized: "Fiji"), String(localized: "Finland"), String(localized: "France"), String(localized: "Gabon"), String(localized: "Gambia"), String(localized: "Georgia"), String(localized: "Germany"), String(localized: "Ghana"), String(localized: "Greece"), String(localized: "Grenada"), String(localized: "Guatemala"), String(localized: "Guinea"), String(localized: "Guinea-Bissau"), String(localized: "Guyana"), String(localized: "Haiti"), String(localized: "Honduras"), String(localized: "Hungary"), String(localized: "Iceland"), String(localized: "India"), String(localized: "Indonesia"), String(localized: "Iran"), String(localized: "Iraq"), String(localized: "Ireland {Republic}"), String(localized: "Israel"), String(localized: "Italy"), String(localized: "Ivory Coast"), String(localized: "Jamaica"), String(localized: "Japan"), String(localized: "Jordan"), String(localized: "Kazakhstan"), String(localized: "Kenya"), String(localized: "Kiribati"), String(localized: "Korea North"), String(localized: "Korea South"), String(localized: "Kosovo"), String(localized: "Kuwait"), String(localized: "Kyrgyzstan"), String(localized: "Laos"), String(localized: "Latvia"), String(localized: "Lebanon"), String(localized: "Lesotho"), String(localized: "Liberia"), String(localized: "Libya"), String(localized: "Liechtenstein"), String(localized: "Lithuania"), String(localized: "Luxembourg"), String(localized: "Macedonia"), String(localized: "Madagascar"), String(localized: "Malawi"), String(localized: "Malaysia"), String(localized: "Maldives"), String(localized: "Mali"), String(localized: "Malta"), String(localized: "Marshall Islands"), String(localized: "Mauritania"), String(localized: "Mauritius"), String(localized: "Mexico"), String(localized: "Micronesia"), String(localized: "Moldova"), String(localized: "Monaco"), String(localized: "Mongolia"), String(localized: "Montenegro"), String(localized: "Morocco"), String(localized: "Mozambique"), String(localized: "Myanmar, {Burma}"), String(localized: "Namibia"), String(localized: "Nauru"), String(localized: "Nepal"), String(localized: "Netherlands"), String(localized: "New Zealand"), String(localized: "Nicaragua"), String(localized: "Niger"), String(localized: "Nigeria"), String(localized: "Norway"), String(localized: "Oman"), String(localized: "Pakistan"), String(localized: "Palau"), String(localized: "Panama"), String(localized: "Papua New Guinea"), String(localized: "Paraguay"), String(localized: "Peru"), String(localized: "Philippines"), String(localized: "Poland"), String(localized: "Portugal"), String(localized: "Qatar"), String(localized: "Romania"), String(localized: "Russian Federation"), String(localized: "Rwanda"), String(localized: "St Kitts & Nevis"), String(localized: "St Lucia"), String(localized: "Saint Vincent & the Grenadines"), String(localized: "Samoa"), String(localized: "San Marino"), String(localized: "Sao Tome & Principe"), String(localized: "Saudi Arabia"), String(localized: "Senegal"), String(localized: "Serbia"), String(localized: "Seychelles"), String(localized: "Sierra Leone"), String(localized: "Singapore"), String(localized: "Slovakia"), String(localized: "Slovenia"), String(localized: "Solomon Islands"), String(localized: "Somalia"), String(localized: "South Africa"), String(localized: "South Sudan"), String(localized: "Spain"), String(localized: "Sri Lanka"), String(localized: "Sudan"), String(localized: "Suriname"), String(localized: "Swaziland"), String(localized: "Sweden"), String(localized: "Switzerland"), String(localized: "Syria"), String(localized: "Taiwan"), String(localized: "Tajikistan"), String(localized: "Tanzania"), String(localized: "Thailand"), String(localized: "Togo"), String(localized: "Tonga"), String(localized: "Trinidad & Tobago"), String(localized: "Tunisia"), String(localized: "Turkey"), String(localized: "Turkmenistan"), String(localized: "Tuvalu"), String(localized: "Uganda"), String(localized: "Ukraine"), String(localized: "United Arab Emirates"), String(localized: "United Kingdom"), String(localized: "United States"), String(localized: "Uruguay"), String(localized: "Uzbekistan"), String(localized: "Vanuatu"), String(localized: "Vatican City"), String(localized: "Venezuela"), String(localized: "Vietnam"), String(localized: "Yemen"), String(localized: "Zambia"), String(localized: "Zimbabwe")]
    
    let ethnicityUnits = [
        String(localized: "Asian, British Asian, Welsh Asian"),
        String(localized: "Black, British Black, Welsh Black, Caribbean, African"),
        String(localized: "Mixed or Multiple Ethnicities"),
        String(localized: "White: UK or British"),
        String(localized: "White: Irish"),
        String(localized: "White: Gypsy, Traveller, Roma, or Other White"),
        String(localized: "Other Ethnic Group")
    ]
    
    let sportUnits = [String(localized: "Triathlon"),String(localized: "Tennis"),String(localized: "Swimming"),String(localized: "Squash"),String(localized: "Running"),String(localized: "Rugby Union"),String(localized: "Rugby League"),String(localized: "Netball"),String(localized: "Hockey (Ice)"),String(localized: "Hockey (Field)"),String(localized: "Golf"),String(localized: "Football"),String(localized: "Cycling"),String(localized: "Crossfit"),String(localized: "Cricket"),String(localized: "Boxing"),String(localized: "Basketball"),String(localized: "Badminton"),String(localized: "Athletics"),String(localized: "American Football")]
    
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
                    viewName: "Add Child Step Four",
                    isTextFieldDisabled: true
                )

                DropDownTextField(
                    label: "Ethnicity",
                    placeholder: "Select Ethnicity",
                    fieldWidth: 170,
                    units: ethnicityUnits,
                    text: $childDetails.ethnicity,
                    selectedUnit: $childDetails.ethnicity,
                    viewName: "Add Child Step Four",
                    isTextFieldDisabled: true
                )
                .padding(.top, 10)

                DropDownTextField(
                    label: "Primary Sport",
                    placeholder: "Select Sport",
                    fieldWidth: 170,
                    units: sportUnits,
                    text: $childDetails.primarySport,
                    selectedUnit: $childDetails.primarySport,
                    viewName: "Add Child Step Four",
                    isTextFieldDisabled: true
                )
                .padding(.top, 10)
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
                Button(action: {
                    validateFields()
                }) {
                    CustomButton(
                        title: "Next step",
                        backgroundColor: Color(.buttonGreyLight),
                        textColor: .black
                    )
                }

                // NavigationLink to next view (AddChildStepFourView)
                NavigationLink(
                    destination: AddChildStepFiveView(childDetails: childDetails, numberOfStepsBack: $numberOfStepsBack),
                    isActive: $navigateToNextView
                ) {
                    EmptyView()
                }
            }
            .padding(.bottom, 60)
            ProgressBar(progressMultiplier: 4)
        }
        .onAppear {
            viewStartTime = Date()
        }
        .onDisappear {
            trackViewTime()
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
    
    // Mixpanel
    private func trackViewTime() {
        let timeSpent = Date().timeIntervalSince(viewStartTime)
        Mixpanel.mainInstance().track(event: "MIX Add Child Step Four View Time", properties: ["time_spent": timeSpent])
    }
    
    private func validateFields() {
        // Track Mixpanel events for each completed field
        if !childDetails.country.trimmingCharacters(in: .whitespaces).isEmpty {
            Mixpanel.mainInstance().track(event: "MIX Country Completed", properties: [
                "country": childDetails.country,
                "view": "Add Child Step Four"
            ])
        }

        if !childDetails.ethnicity.trimmingCharacters(in: .whitespaces).isEmpty {
            Mixpanel.mainInstance().track(event: "MIX Ethnicity Completed", properties: [
                "ethnicity": childDetails.ethnicity,
                "view": "Add Child Step Four"
            ])
        }

        if !childDetails.primarySport.trimmingCharacters(in: .whitespaces).isEmpty {
            Mixpanel.mainInstance().track(event: "MIX Primary Sport Completed", properties: [
                "sport": childDetails.primarySport,
                "view": "Add Child Step Four"
            ])
        }

        // Proceed to next view
        navigateToNextView = true
    }

}

#Preview {
    AddChildStepFourView(
        childDetails: ChildDetailsModel(),
        numberOfStepsBack: .constant(0)
    )
}
