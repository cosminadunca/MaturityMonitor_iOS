import SwiftUI

struct PersonalDataView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var isAccepted: Bool
    
    // Shared email
    let emailText = "Email: us@yorksj.ac.uk"
    let emailText2 = "Email: inspire@yorksj.ac.uk"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.buttonPurpleLight)
                        .padding(.leading, 10)
                    
                    Text("Privacy Notice")
                        .font(Font.custom("Inter", size: 20))
                        .foregroundColor(.purple)
                    
                    Spacer()
                }
                .padding(.leading, 10)
                .padding(.top, 25)
                
                Text("All personal information gathered and held by York St John University relating to its applicants and students is treated with the care and confidentiality required by the General Data Protection Regulation (UK GDPR) and the Data Protection Act 2018.")
                    .font(Font.custom("Inter", size: 15))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                Text("By providing your data, you consent to the University’s use of your personal data as outlined below.")
                    .font(Font.custom("Inter", size: 15))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                Text("Who are we?")
                    .font(Font.custom("Inter", size: 18))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                Text("For the purposes of processing your personal information in this instance, the data controller is York St John University, Lord Mayor’s Walk, York, YO31 7EX. The University’s Data Protection Officer is the University Secretary, York St John University, Lord Mayor’s Walk, York, YO31 7EX, tel: 01904 876027.")
                    .font(Font.custom("Inter", size: 15))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                Text(emailText)
                    .font(Font.custom("Inter", size: 15))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                Text("How do we use your personal information?")
                    .font(Font.custom("Inter", size: 18))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("As we are a university-centred entity, we may use personal information for research purposes. If we do this, your personal information will be handled according to University Ethical Guidelines (available ")
                    
                    // Tappable button for the link
                    Button(action: {
                        if let url = URL(string: "https://www.yorksj.ac.uk/policies-and-documents/research/ethics-and-integrity/process-for-research-ethics-approval/") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("HERE")
                            .font(Font.custom("Inter", size: 15))
                            .foregroundColor(.blue)
                    }
                    
                    Text(") and all your information will remain anonymous. Secondly, we may use personal information for teaching and learning purposes. If so, any data, pictures or videos will be anonymised.")
                }
                .font(Font.custom("Inter", size: 15))
                .foregroundColor(.black)
                .padding(.horizontal, 20)

                
                Text("What legal basis do we have for processing your personal data?")
                    .font(Font.custom("Inter", size: 18))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                Text("The UK GDPR requires us to establish a legal basis for processing your information. For the purpose of this privacy notice the processing is covered under UK GDPR Article 6 (1)(a) where processing is based on consent and the controller shall be able to demonstrate that the data subject has consented to processing of their personal data. You have the right to withdraw your consent at any time and can do so by emailing the University at")
                    .font(Font.custom("Inter", size: 15))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                Text(emailText2)
                    .font(Font.custom("Inter", size: 15))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                Text("As we are also collecting information relating to your health, which the UK GDPR categorises as special category data, we are required to establish an additional condition for processing the information. For the purpose of this privacy notice the processing is covered under GDPR Article 9 (2)(a) where the data subject has given explicit consent to the processing of those personal data for one or more specified purposes.")
                    .font(Font.custom("Inter", size: 15))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                Text("Any questions or concerns?")
                    .font(Font.custom("Inter", size: 18))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                Text("If you have any questions or concerns about the way we are collecting and using your personal data we request that you contact the University by emailing: ")
                    .font(Font.custom("Inter", size: 15))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                Text(emailText2)
                    .font(Font.custom("Inter", size: 15))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("You also have the right to complain to the Information Commissioner's Office (ICO) about the way in which we process your personal data. Details can be found at: ")
                        .font(Font.custom("Inter", size: 15))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    
                    // Tappable link using Link
                    Link("HERE", destination: URL(string: "https://ico.org.uk")!) // Replace with your actual URL
                        .font(Font.custom("Inter", size: 15))
                        .foregroundColor(.blue)
                }.padding(.horizontal, 20)
                
                Text("Statement and Disclaimer")
                    .font(Font.custom("Inter", size: 18))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                Text("The information provided by this app is an indication of biological maturity only. To the best of our knowledge, the information is accurate however at times equations may vary from actual growth patterns. It should be used as an indication of growth and maturation only. Maturity Monitor and York St John University accepts no responsibility for issues arising if this happens.")
                    .font(Font.custom("Inter", size: 15))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                Text("1. I understand that the validated equations used in this app are estimations of somatic maturity and should be used as indications only.")
                    .font(Font.custom("Inter", size: 15))
                    .foregroundColor(.tabviewPurpleDark)
                    .padding(.horizontal, 35)
                
                Text("2. All the personal information that I have provided is accurate and up-to-date.")
                    .font(Font.custom("Inter", size: 15))
                    .foregroundColor(.tabviewPurpleDark)
                    .padding(.horizontal, 35)
                
                Text("3. I consent to the data I input into this app being anonymously stored and potentially used by York St John University for research purposes.")
                    .font(Font.custom("Inter", size: 15))
                    .foregroundColor(.tabviewPurpleDark)
                    .padding(.horizontal, 35)
                
                HStack(spacing: 20) {
                    Button(action: {
                        isAccepted = false // Update the binding
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        CustomButton(
                            title: "Decline",
                            backgroundColor: Color(.buttonGreyLight),
                            textColor: .black
                        )
                    }
                    Button(action: {
                        isAccepted = true // Update the binding
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        CustomButton(
                            title: "Approve",
                            backgroundColor: Color(.buttonPurpleLight),
                            textColor: .white
                        )
                    }
                }.padding(.top, 25)
            }
        }
    }
}

struct PersonalDataView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a dummy binding for preview
        PersonalDataView(isAccepted: .constant(false))
    }
}

