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
                            SimpleCustomTextField(placeholder: "Name", text: $name)
                            Text("Change surname: ")
                            SimpleCustomTextField(placeholder: "Surname", text: $surname)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        VStack{
                            Text("Change date of birth: ")
                            CustomDateTextField(dateText: $dateOfBirth)
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
