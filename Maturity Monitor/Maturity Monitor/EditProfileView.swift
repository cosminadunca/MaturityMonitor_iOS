import SwiftUI
import Amplify

struct EditProfileView: View {
    
    let amplifyService = AmplifyService()
    
    var child: Child
    let units = ["cm", "in"]
    @State private var selectedUnit: String = ""
    @State private var fetchedUserId: String?
    @State private var isUserCreator: Bool = false
    @State private var shouldNavigate = false
    @State private var showDeleteConfirmation = false
    @State private var isSaved = false
    @State private var saveErrorMessage = ""
    @State private var deleteAllSuccess = false
    
    @State private var isUpdateAvailable = false
    @State private var buttonErrorMessage: String? = nil
    @State private var showButtonErrorMessage: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    @State private var userID: String
    @State private var name: String
    @State private var surname: String
    @State private var dateOfBirth: String
    @State private var gender: String
    @State private var motherHeight: String
    @State private var fatherHeight: String
    @State private var parentsMeasurement: String
    @State private var country: String
    @State private var ethnicity: String
    @State private var primarySport: String
    @State private var approveData: Bool
    @State private var uniqueId: Int
    
    // Mixpanel
    @State private var calendarTapCount = 0
    
    // Initialization with the Child instance
    init(child: Child) {
        self.child = child
        self._userID = State(initialValue: child.idUser)
        self._name = State(initialValue: child.name)
        self._surname = State(initialValue: child.surname)
        self._dateOfBirth = State(initialValue: child.dateOfBirth)
        self._gender = State(initialValue: child.gender)
        self._motherHeight = State(initialValue: child.motherHeight)
        self._fatherHeight = State(initialValue: child.fatherHeight)
        self._parentsMeasurement = State(initialValue: child.parentsMeasurements)
        self._country = State(initialValue: child.country)
        self._ethnicity = State(initialValue: child.ethnicity)
        self._primarySport = State(initialValue: child.primarySport)
        self._approveData = State(initialValue: child.approveData)
        self._uniqueId = State(initialValue: child.uniqueId)
    }
    
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
    
    // Create a NumberFormatter instance
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none // This prevents commas from being added
        return formatter
    }()
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        SimpleCustomTextTitle(title: "Edit profile")
                            .padding(.bottom, 10)
                        Text("You can only edit children accounts that you have created! ")
                            .font(Font.custom("Inter", size: 15))
                            .foregroundColor(.buttonTurquoiseDark)
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                        Text("Unique code: \(numberFormatter.string(from: NSNumber(value: uniqueId)) ?? "")")
                            .padding(.top, 20)
                            .font(.headline)
                        VStack(alignment: .leading) {
                            Text("Change name: ")
                            SimpleCustomTextField(placeholder: "Name", text: $name, viewName: "Edit Profile View")
                            Text("Change surname: ")
                            SimpleCustomTextField(placeholder: "Surname", text: $surname, viewName: "Edit Profile View")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        VStack{
                            Text("Change date of birth: ")
                            CustomDateTextField(
                                placeholder: "DD/MM/YYYY",
                                dateText: $dateOfBirth,
                                viewName: "Edit Profile",
                                calendarTapCount: $calendarTapCount
                            )
                        }
                        Text("Change gender: ")
                        CustomCheckbox(
                            options: [Gender.male, Gender.female],
                            selectedOption: Binding(
                                get: { Gender(rawValue: gender) },
                                set: { gender = $0?.rawValue ?? "" }
                            ),
                            font: Font.custom("Inter", size: 18)
                        ).padding(.bottom, 30)
                        Text("The same measurement unit applies to both values! Choose between cm & in.")
                            .font(Font.custom("Inter", size: 15))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                        Text("If you change the measuremnt type for one of the parents' height, make sure to change it for the other parent too so they both are either in cm or in.")
                            .font(Font.custom("Inter", size: 15))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                        Text("Current measurement type is: \(selectedUnit)!")
                            .font(Font.custom("Inter", size: 15))
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                        VStack(spacing: 15) {
                            DropDownTextField(
                                label: "Birth Mother Height",
                                placeholder: "0 \(selectedUnit)",
                                fieldWidth: 130,
                                units: units,
                                text: $motherHeight,
                                selectedUnit: $selectedUnit
                            )
                            DropDownTextField(
                                label: "Birth Father Height",
                                placeholder: "0 \(selectedUnit)",
                                fieldWidth: 130,
                                units: units,
                                text: $fatherHeight,
                                selectedUnit: $selectedUnit
                            )
                        }
                        .padding()
                        VStack {
                            Text("Are these details measured or estimated?")
                                .font(Font.custom("Inter", size: 15))
                                .foregroundColor(.black)
                                .padding(.bottom, 20)
                            CustomCheckbox(
                                options: [MeasurementType.measured, MeasurementType.estimated],
                                selectedOption: Binding(
                                    get: { MeasurementType(rawValue: parentsMeasurement) },
                                    set: { parentsMeasurement = $0?.rawValue ?? "" }
                                ),
                                font: Font.custom("Inter", size: 18)
                            )
                        }
                        .padding()
                        VStack(alignment: .leading) {
                            DropDownTextField(
                                label: "Country",
                                placeholder: "Select Country",
                                fieldWidth: 170,
                                units: countryUnits,
                                text: $country,
                                selectedUnit: $country,
                                isTextFieldDisabled: true
                            )
                            DropDownTextField(
                                label: "Ethnicity",
                                placeholder: "Select Ethnicity",
                                fieldWidth: 170,
                                units: ethnicityUnits,
                                text: $ethnicity,
                                selectedUnit: $ethnicity,
                                isTextFieldDisabled: true
                            ).padding(.top, 10)
                            DropDownTextField(
                                label: "Primary Sport",
                                placeholder: "Select Sport",
                                fieldWidth: 170,
                                units: sportUnits,
                                text: $primarySport,
                                selectedUnit: $primarySport,
                                isTextFieldDisabled: true
                            ).padding(.top, 10)
                        }
                        .padding()
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        Toggle("Approve Data for Research", isOn: $approveData)
                            .toggleStyle(SwitchToggleStyle(tint: .buttonTurquoiseDark))
                        Spacer()
                        if showButtonErrorMessage {
                            ErrorCustomText(title: buttonErrorMessage!)
                        }
                        if isUserCreator == true {
                            HStack(spacing: 10) {
                                Button(action: {
                                    Task {
                                        showDeleteConfirmation = true
                                        DispatchQueue.main.async {
                                            showButtonErrorMessage = false
                                        }
                                    }
                                }) {
                                    CustomButton(
                                        title: "Delete Account",
                                        backgroundColor: Color(.buttonGreyLight),
                                        textColor: .black
                                    )
                                }
                                Button(action: {
                                    checkIfNotEmptyVariables()
                                    print(buttonErrorMessage)
                                    print(showButtonErrorMessage)
                                    if (buttonErrorMessage != nil) {
                                        showButtonErrorMessage = true
                                        return
                                    }
                                    if !showButtonErrorMessage {
                                        Task {
                                            await saveChanges()
                                            DispatchQueue.main.async {
                                                showButtonErrorMessage = false
                                            }
                                        }
                                    }
                                }) {
                                    CustomButton(
                                        title: "Save",
                                        backgroundColor: Color.buttonPurpleLight,
                                        textColor: .white
                                    )
                                }
                            }
                            .padding(.bottom, 30)
                        } else {
                            Text("If you haven't created this child, you are not allowed to change details or delete the account.")
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding()
                        }
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
                    .padding()
                    .alert(isPresented: $showDeleteConfirmation) {
                        Alert(
                            title: Text("Are you sure?"),
                            message: Text("This action will permanently delete the account. Do you want to proceed?"),
                            primaryButton: .destructive(Text("Delete")) {
                                let childId = child.id
                                let userId = userID
                                Task {
                                    await deleteAccount(childId: childId, userId: userId)
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                .onAppear {
                    // Handle motherHeight to set the selected unit
                    DispatchQueue.global().async {
                        var newUnit: String = ""
                        if motherHeight.count > 2 {
                            let unit = motherHeight.suffix(2).trimmingCharacters(in: .whitespacesAndNewlines)
                            if units.contains(unit) {
                                newUnit = unit
                            }
                        }
                        DispatchQueue.main.async {
                            selectedUnit = newUnit
                        }
                    }
                    // Fetch user ID asynchronously to determine if the user is the creator
                    Task {
                        let userId = await amplifyService.fetchCurrentUserId()
                        DispatchQueue.main.async {
                            isUserCreator = (userId == userID)
                        }
                    }
                }
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                    .foregroundColor(.black)
                                    .font(.system(size: 18))
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .background(
                    NavigationLink(destination: RegistrationHomeView(), isActive: $deleteAllSuccess) {
                        EmptyView()
                    }
                )
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func checkIfNotEmptyVariables() {
        // Check for empty fields
        if name.isEmpty || surname.isEmpty || dateOfBirth.isEmpty || gender.isEmpty || motherHeight.isEmpty || fatherHeight.isEmpty || parentsMeasurement.isEmpty {
            buttonErrorMessage = "There are fields that are empty. Ensure all fields are complete!"
            showButtonErrorMessage = true
            return
        }
        // Validate date of birth
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" // Adjusted to DD/MM/YYYY format
        if let date = dateFormatter.date(from: dateOfBirth) {
            if date > Date() {
                buttonErrorMessage = "Date of birth cannot be in the future!"
                showButtonErrorMessage = true
                return
            }
        } else {
            buttonErrorMessage = "Please enter a valid date of birth!"
            showButtonErrorMessage = true
            return
        }
        // Compare fields with the original data (child data)
        var isUpdateAvailable = false
        // Checking if fields have changed
        if name.trimmingCharacters(in: .whitespacesAndNewlines) != child.name.trimmingCharacters(in: .whitespacesAndNewlines) ||
           surname.trimmingCharacters(in: .whitespacesAndNewlines) != child.surname.trimmingCharacters(in: .whitespacesAndNewlines) ||
           dateOfBirth != child.dateOfBirth || // Compare directly with string dateOfBirth, if needed
           gender != child.gender ||
           "\(motherHeight) \(selectedUnit)" != child.motherHeight ||
            "\(fatherHeight) \(selectedUnit)" != child.fatherHeight ||
           parentsMeasurement != child.parentsMeasurements ||
           primarySport != child.primarySport ||
           country != child.country ||
           ethnicity != child.ethnicity ||
           approveData != child.approveData {
            
            isUpdateAvailable = true
        }
        // Log the result of the comparison
        if isUpdateAvailable {
            print("Fields have changed, ready for update.")
        } else {
            print("No fields have changed.")
        }
        // If no fields are changed, show an error message
        if !isUpdateAvailable {
            buttonErrorMessage = "No profile field has been changed. Nothing to update!"
            showButtonErrorMessage = true
            return
        }
        // Clear any existing error messages if update is available
        buttonErrorMessage = nil
        showButtonErrorMessage = false
    }

    // Save changes to the backend or data store
    private func saveChanges() {
        print("INSIDE SAVE FUNCTION")
        Task {
            do {
                // Update the child's data
                var updatedChild = child
                updatedChild.name = name
                updatedChild.surname = surname
                updatedChild.dateOfBirth = dateOfBirth
                updatedChild.gender = gender
                updatedChild.motherHeight = "\(motherHeight) \(selectedUnit)"
                updatedChild.fatherHeight = "\(fatherHeight) \(selectedUnit)"
                updatedChild.parentsMeasurements = parentsMeasurement
                updatedChild.country = country
                updatedChild.ethnicity = ethnicity
                updatedChild.primarySport = primarySport
                updatedChild.approveData = approveData
                updatedChild.uniqueId = uniqueId
                
                try await Amplify.DataStore.save(updatedChild)
                print("Child updated locally in Datastore")
                print(updatedChild)
                    
                // Set the flag to trigger UI refresh
                isSaved = true
                saveErrorMessage = ""
                presentationMode.wrappedValue.dismiss()
            } catch {
                print("Failed to save child data: \(error.localizedDescription)")
                saveErrorMessage = "Failed to save child data: \(error.localizedDescription)"
                isSaved = false
            }
        }
    }
    
    // Assuming this function is in the view that contains the button
    func deleteAccount(childId: String, userId: String) async {
        print("Attempting to delete child account with childId: \(childId) and userId: \(userId)")
        
        // Fetch all links where the childId appears
        print("Fetching links for childId: \(childId)...")
        guard let links = await amplifyService.fetchLinksForChild(childId: childId) else {
            print("No links found for childId \(childId)")
            return
        }
        
        let linkCount = links.count
        print("Found \(linkCount) link(s) for childId \(childId)")
        
        if linkCount == 1 {
            print("Only one link exists for this child. Fetching linked children for userId: \(userId)...")
            
            if let linkedChildren = await amplifyService.fetchLinkedChildrenForUser(userID: userId) {
                print("Found \(linkedChildren.count) linked child(ren) for userId \(userId)")
                
                if linkedChildren.count > 1 {
                    print("More than one linked child found. Searching for a different child to switch to...")
                    
                    guard let child = await amplifyService.queryChildByIdDataStore(childId: childId) else {
                        print("Child with id \(childId) not found.")
                        return
                    }
                    print("Child details fetched: \(child)")
                    
                    for linkedChild in linkedChildren {
                        let childTemp = linkedChild.child
                        print("Inspecting linked child with ID: \(childTemp.id)")
                        
                        guard let child2 = await amplifyService.queryChildByIdDataStore(childId: childTemp.id) else {
                            print("Linked child with id \(childTemp.id) not found in datastore.")
                            continue
                        }
                        
                        if child.id != child2.id {
                            print("Found a different child to switch to with ID: \(child2.id)")
                            
                            await amplifyService.updateCurrentChildAttribute(with: childTemp.id)
                            print("Current child attribute updated to \(childTemp.id)")
                            
                            if let linkToDelete = await amplifyService.fetchLinkForUserAndChild(childId: childId, userId: userId) {
                                print("Removing link with ID: \(linkToDelete.id)...")
                                await amplifyService.removeLinkById(linkId: linkToDelete.id)
                            } else {
                                print("No link found for the user and child.")
                            }

                            
                            print("Deleting child with ID: \(childId)...")
                            let result = await amplifyService.removeChild(childId: childId, userId: userId)
                            
                            switch result {
                            case .success():
                                print("Child account with ID \(childId) successfully deleted.")
                            case .failure(let error):
                                print("Error deleting child account with ID \(childId): \(error)")
                            }
                            
                            print("Exiting after handling the child switch.")
                            presentationMode.wrappedValue.dismiss()
                            break
                        }
                    }
                } else {
                    print("Only one linked child found for this user. Proceeding to delete...")
                    
                    await amplifyService.updateCurrentChildAttribute(with: "-")
                    print("Current child attribute updated to -")
                    
                    print("Deleting child with ID: \(childId)...")
                    let result = await amplifyService.removeChild(childId: childId, userId: userId)
                    
                    switch result {
                    case .success():
                        print("Child account with ID \(childId) successfully deleted.")
                        deleteAllSuccess = true
                    case .failure(let error):
                        print("Error deleting child account with ID \(childId): \(error)")
                    }
                }
            } else {
                print("No linked children found for userId \(userId).")
            }
        } else {
            print("Multiple users are linked to this child. Deletion is not allowed.")
            buttonErrorMessage = "Other users are linked to this child! You cannot delete this account."
            showButtonErrorMessage = true
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        
        //  for prreview
        let mockChild = Child(
            id: "1",
            idUser: "user1",
            userName: "bla",
            userSurname: "blabla",
            name: "John",
            surname: "Doe",
            dateOfBirth: "29 Jan 2015",
            gender: "Male",
            motherHeight: "160 cm",
            fatherHeight: "180 cm",
            parentsMeasurements: "Measured",
            country: "USA",
            ethnicity: "Caucasian",
            primarySport: "Soccer",
            approveData: true,
            uniqueId: 123456,
            status: .active,
            entries: [],
            linkChildToUser: []
        )
        EditProfileView(child: mockChild)
    }
    
}
