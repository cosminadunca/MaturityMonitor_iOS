import Amplify
import UIKit
import Foundation

class AmplifyService {
    
    // FUNCTIONS FOR ANALYTICS
    
    // Track New vs Returning User
    func trackUserType() async {
        let isNewUser = await isNewUser()  // Custom logic to determine new vs returning
        let userType = isNewUser ? "NewUser" : "ReturningUser"
            
        let event = BasicAnalyticsEvent(name: "UserType",
                                            properties: ["Type": userType])
        Amplify.Analytics.record(event: event)
        print("Tracked: \(userType)")
    }

    // Example logic to check if a user is new
    func isNewUser() async -> Bool {
        let userAttributes = try? await Amplify.Auth.fetchUserAttributes()
        return userAttributes?.first(where: { $0.key == AuthUserAttributeKey.emailVerified }) == nil
    }
    
    // END FUNCTIONS FOR ANALYTICS

    // Sign up function
    func signUp(username: String, password: String, userAttributes: [AuthUserAttribute]) async -> Result<AuthSignUpResult, Error> {
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        do {
            let signUpResult = try await Amplify.Auth.signUp(
                username: username.trimmingCharacters(in: .whitespaces),
                password: password.trimmingCharacters(in: .whitespaces),
                options: options
            )
            return .success(signUpResult)
        } catch {
            return .failure(error)
        }
    }
    
    // Sign in function - ASYNC
    func signIn(username: String, password: String) async throws -> Bool {
        let signInResult = try await Amplify.Auth.signIn(username: username.trimmingCharacters(in: .whitespaces), password: password.trimmingCharacters(in: .whitespaces))
        return signInResult.isSignedIn
    }
    
    // Sign out function returning success status - ASYNC
    func signOut() async -> Bool {
        await Amplify.Auth.signOut()
        return true // Sign-out is complete; returning true to indicate success
    }
    
    // Function to confirm sign-up - ASYNC
    func confirmSignUp(email: String, confirmationCode: String) async throws -> Bool {
        let result = try await Amplify.Auth.confirmSignUp(for: email, confirmationCode: confirmationCode)
        return result.isSignUpComplete
    }
    
    // Function to check if the user is signed in - ASYNC
    func isUserSignedIn() async -> Bool {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            return session.isSignedIn
        } catch {
            print("Failed to fetch session: \(error)")
            return false
        }
    }
    
    // Function to fetch current user - ASYNC
    func fetchCurrentUserId() async -> String? {
        do {
            let user = try await Amplify.Auth.getCurrentUser()
            return user.userId // Return the logged-in user's ID
        } catch {
            print("Error fetching current user ID: \(error)")
            return nil // Return nil if there is an error
        }
    }
    
    // Function to fetch all of the current user attributes
    func fetchUserAttributes() async -> (firstName: String, lastName: String, currentChildId: String)? {
        do {
            let attributes = try await Amplify.Auth.fetchUserAttributes()
            print("User attributes - \(attributes)")
            var firstName = "", lastName = "", currentChildId = ""
            for attribute in attributes {
                if attribute.key == .custom("firstName") {
                    firstName = attribute.value
                } else if attribute.key == .custom("lastName") {
                    lastName = attribute.value
                } else if attribute.key == .custom("currentChild") {
                    currentChildId = attribute.value
                }
            }
            return (firstName, lastName, currentChildId)
        } catch let error as AuthError {
            print("Fetching user attributes failed with error \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
        return nil
    }
    
    // Function to fetch the "currentChild" custom attribute - ASYNC
    func getCurrentChild() async throws -> String? {
        let userAttributes = try await Amplify.Auth.fetchUserAttributes()
        return userAttributes.first(where: { $0.key == AuthUserAttributeKey.custom("currentChild") })?.value
    }
    
    // Function to update the "currentChild" custom attribute - ASYNC
    func updateCurrentChildAttribute(with childId: String) async -> String {
        do {
            let updateResult = try await Amplify.Auth.update(
                userAttribute: AuthUserAttribute(.custom("currentChild"), value: childId)
            )
            
            switch updateResult.nextStep {
                case .confirmAttributeWithCode(let deliveryDetails, let info):
                    return "Confirm the attribute update with details sent to - \(deliveryDetails) \(String(describing: info))"
                case .done:
                    return "Attribute update completed successfully!"
            }
        } catch let error as AuthError {
            return "Update attribute failed with error: \(error)"
        } catch {
            return "Unexpected error: \(error)"
        }
    }

    // Function to reset password - ASYNC
    func resetPassword(username: String) async throws -> AuthResetPasswordStep {
        let resetResult = try await Amplify.Auth.resetPassword(for: username)
        return resetResult.nextStep
    }

    // Function to confirm password reset - ASYNC
    func confirmResetPassword(username: String, newPassword: String, confirmationCode: String) async throws {
        try await Amplify.Auth.confirmResetPassword(for: username, with: newPassword, confirmationCode: confirmationCode)
    }
    
    // Function to resend the confirmation code - ASYNC
    func resendConfirmationCode(email: String) async throws {
        _ = try await Amplify.Auth.resendSignUpCode(for: email)
    }
    
    // Function for changing the user's password based on other old password
    func changePassword(oldPassword: String, newPassword: String) async -> Bool {
        do {
            try await Amplify.Auth.update(oldPassword: oldPassword, to: newPassword)
            print("Password changed successfully")
            return true
        } catch {
            print("Error changing password: \(error.localizedDescription)")
            return false
        }
    }

    // Function for error handling
    func handleAuthError(_ error: AuthError) -> String {
        switch error {
        case .service(let message, _, _):
            if message.contains("usernameExists") {
                return "An account with this email already exists!"
            } else if message.contains("password") {
                return "Password does not meet the requirements!"
            } else {
                return message
            }
        case .unknown(let message):
            return "Unknown error: \(message)"
        default:
            return "An unexpected error occurred: \(error.errorDescription)"
        }
    }
    
    //  Queries
    
    // Query the database for child based on surname, dob and unique code
    func queryChildByAttributesDataStore(surname: String, dateOfBirth: String, uniqueId: String) async -> (Child?, Bool) {
        do {
            // Fetch all children with the given dateOfBirth and uniqueId
            let children = try await Amplify.DataStore.query(
                Child.self,
                where: Child.keys.dateOfBirth.eq(dateOfBirth)
                    .and(Child.keys.uniqueId.eq(uniqueId))
            )
            
            // Filter the results for surname matching (case-insensitive and ignoring spaces)
            let filteredChildren = children.filter { child in
                let normalizedChildSurname = child.surname.lowercased().replacingOccurrences(of: " ", with: "")
                let normalizedInputSurname = surname.lowercased().replacingOccurrences(of: " ", with: "")
                
                // Check if all characters in the input surname appear in the child's surname
                return normalizedInputSurname.allSatisfy { normalizedChildSurname.contains($0) }
            }
            
            // Check if we found a matching child
            guard let firstChild = filteredChildren.first else {
                return (nil, false) // No matching child found
            }
            
            // Check if the child is already linked to the current user
            let childId = firstChild.id
            let userId = await fetchCurrentUserId()
            var childAlreadyLinked = false
            
            if let userId = userId {
                let linkedChildren = try await Amplify.DataStore.query(
                    LinkChildToUser.self,
                    where: LinkChildToUser.keys.child.eq(childId)
                        .and(LinkChildToUser.keys.idUser.eq(userId))
                )
                childAlreadyLinked = !linkedChildren.isEmpty
            }

            // Return the matching child and its linked status
            return (firstChild, childAlreadyLinked)
        } catch {
            print("Error querying children: \(error)")
            return (nil, false) // Return nil for the child and false for linked status in case of error
        }
    }
    
    func queryChildByIdDataStore(childId: String) async -> Child? {
        do {
            try await Amplify.DataStore.start()
            // Query for child using only the id
            let children = try await Amplify.DataStore.query(
                Child.self,
                where: Child.keys.id.eq(childId)
            )

            // If a child is found, return it
            return children.first // Assuming id is unique, so the first should be the only match
        } catch {
            print("Error querying child by ID: \(error)")
            return nil // Return nil if there is an error
        }
    }
    
    // Function to fetch entries for a child
    func fetchEntriesForChild(childId: String) async -> [Entry]? {
        do {
            let predicate = Entry.keys.child.eq(childId)
            return try await Amplify.DataStore.query(Entry.self, where: predicate)
        } catch {
            print("Error querying entries: \(error)")
            return nil
        }
    }
    
    // Function to fetch children for a user account
    func fetchLinkedChildrenForUser(userID: String) async -> [LinkChildToUser]? {
        do {
            let predicate = LinkChildToUser.keys.idUser.eq(userID)
            let linkedChildren = try await Amplify.DataStore.query(LinkChildToUser.self, where: predicate)
            return linkedChildren
        } catch {
            print("Error querying linked children for user: \(error)")
            return nil
        }
    }
    
    // Function to fetch links where the childId appears
    func fetchLinksForChild(childId: String) async -> [LinkChildToUser]? {
        do {
            // Fetch the child based on the childId
            guard let child = await queryChildByIdDataStore(childId: childId) else {
                print("Child with id \(childId) not found.")
                return nil
            }
            
            // Now query links based on the fetched child
            let predicate = LinkChildToUser.keys.child.eq(child.id)
            let links = try await Amplify.DataStore.query(LinkChildToUser.self, where: predicate)
            
            return links
        } catch {
            print("Error querying links for childId \(childId): \(error)")
            return nil
        }
    }
    
    func fetchLinkForUserAndChild(childId: String, userId: String) async -> LinkChildToUser? {
        do {
            // Modify the query to look for the specific childId and userId link
            let predicate = LinkChildToUser.keys.child.eq(childId).and(LinkChildToUser.keys.idUser.eq(userId))
            let links = try await Amplify.DataStore.query(LinkChildToUser.self, where: predicate)
            return links.first
        } catch {
            print("Error querying link: \(error)")
            return nil
        }
    }
      
    //  Create
    
    // Function to upload an image to S3 and get back the URL
    func uploadImageToS3(image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image conversion failed!"])
        }

        let imageKey = UUID().uuidString + ".jpg"
        _ = try await Amplify.Storage.uploadData(key: imageKey, data: imageData)
        return imageKey  // or result if you need additional response data
    }
    
    // Function to create a new Child entry and save it to DataStore - ASYNC
    func createChild(childDetails: ChildDetailsModel, uniqueId: Int) async -> Result<Void, Error> {
        // Fetch current user ID
        guard let userId = await fetchCurrentUserId() else {
            return .failure(AuthError.unknown("User ID not found!"))
        }
            
        let childStatus: ChildStatus = .active
            
        // Fetch user attributes
        guard let userAttributes = await fetchUserAttributes() else {
            return .failure(AuthError.unknown("User attributes not found!"))
        }
            
        let userName = userAttributes.firstName
        let userSurname = userAttributes.lastName
            
        // Upload image to S3 and get the image URL (if image is selected)
        var imageURL: String? = nil
        if let selectedImage = childDetails.image {
            do {
                imageURL = try await uploadImageToS3(image: selectedImage)
            } catch {
                print("Failed to upload image: \(error)")
                return .failure(error)  // Fail if image upload fails
            }
        }
        
        // Create the Child object
//        let child = Child(
//            id: UUID().uuidString,
//            idUser: userId,
//            userName: userName,
//            userSurname: userSurname,
//            name: childDetails.name,
//            surname: childDetails.surname,
//            dateOfBirth: childDetails.dateOfBirth,
//            gender: childDetails.gender?.rawValue ?? "-",
//            motherHeight: childDetails.momHeight ?? "-",
//            fatherHeight: childDetails.dadHeight ?? "-",
//            parentsMeasurements: childDetails.measurementType?.rawValue ?? "-",
//            country: childDetails.country.isEmpty ? "-" : childDetails.country,
//            ethnicity: childDetails.ethnicity.isEmpty ? "-" : childDetails.ethnicity,
//            primarySport: childDetails.primarySport.isEmpty ? "-" : childDetails.primarySport,
//            approveData: childDetails.agreeToResearch,
//            uniqueId: uniqueId,
//            status: childStatus,
//            entries: [],  // Initialize as empty list
//            linkChildToUser: []  // Initialize as empty list
//        )
        
        let child = Child(
            id: UUID().uuidString,
            idUser: userId,
            userName: "Cosmina",
            userSurname: "Dunca",
            name: "Blah",
            surname: "Blah blah",
            dateOfBirth: "25/03/2011",
            gender: "-",
            motherHeight:  "-",
            fatherHeight: "-",
            parentsMeasurements: "-",
            country:  "-" ,
            ethnicity: "-" ,
            primarySport: "-" ,
            approveData: true,
            uniqueId: 785362,
            status: childStatus,
            entries: List(elements: []),  // Initialize as empty list
            linkChildToUser: List(elements: [])  // Initialize as empty list
        )
            
        do {
            print("Saving child: \(child)")
            // Save child to DataStore
            try await Amplify.DataStore.save(child)
            print("✅ Child saved successfully to DataStore")
            
            // Create the LinkChildToUser object to associate the child with the user
            await createLinkChildToUser(childId: child.id, child: child)
            
            // Optionally update the current child attribute (e.g., for the logged-in user)
            await updateCurrentChildAttribute(with: child.id)
            
            return .success(())
        } catch {
            print("❌ Failed to save child to DataStore: \(error)")
            return .failure(error)
        }
    }
    
    // Create new entry for one child
    func createEntry(
        weight: String,
        height: String,
        sittingHeight: String,
        dateText: String,
        selectedUnit: String
    ) async throws {
        // Determine units based on the selected unit
        let weightUnit = selectedUnit == "cm/kg" ? "kg" : "lbs"
        let heightUnit = selectedUnit == "cm/kg" ? "cm" : "in"

        // Append the unit to the values
        let weightWithUnit = "\(weight) \(weightUnit)"
        let heightWithUnit = "\(height) \(heightUnit)"
        let sittingHeightWithUnit = "\(sittingHeight) \(heightUnit)"

        // Fetch user ID
        guard let userId = await fetchCurrentUserId() else {
            throw NSError(domain: "AmplifyService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch User ID"])
        }
        
        // Fetch current child ID from user attributes
        guard let currentChildId = try await getCurrentChild() else {
            throw NSError(domain: "AmplifyService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch Current Child ID"])
        }
        
        guard let userAttributes = await fetchUserAttributes() else {
                throw NSError(domain: "AmplifyService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch User attributes"])
            }
            
        let userName = userAttributes.firstName
        let userSurname = userAttributes.lastName

        // Fetch child based on the current child ID (which you already have)
        let child = await queryChildByIdDataStore(childId: currentChildId)

        guard let child = child else {
            throw NSError(domain: "AmplifyService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch Child details"])
        }

        print("Here right before adding the entry to the dataset!")
        // Create the Entry object
        let entry = Entry(
            id: UUID().uuidString,
            idUser: userId,
            userName: userName,
            userSurname: userSurname,
            weight: weightWithUnit,
            height: heightWithUnit,
            sittingHeigh: sittingHeightWithUnit,
            dateOfEntry: dateText,
            child: child
        )

        // Save entry to DataStore
        try await Amplify.DataStore.save(entry)

        // Optionally, show a success message or handle success
        print("Entry added successfully!")
    }

    // Create link between user and child
    func createLinkChildToUser(childId: String, child: Child) async {
        do {
            guard let userId = await fetchCurrentUserId() else {
                print("Failed to fetch User ID!")
                return
            }
                
            let link = LinkChildToUser(idUser: userId, child: child)
            try await Amplify.DataStore.save(link)
            print("Successfully created link between user and child: \(link)")
        } catch {
            print("Failed to create link: \(error)")
        }
    }
    
    //  Remove

    func removeEntry(entryId: String, userId: String) async -> Result<Void, Error> {
        do {
                let predicate = Entry.keys.id.eq(entryId)
                let entries = try await Amplify.DataStore.query(Entry.self, where: predicate)
                
                guard let entry = entries.first else {
                    return .failure(NSError(domain: "EntryError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Entry not found."]))
                }
                
                if entry.idUser == userId {
                    try await Amplify.DataStore.delete(entry)
                    return .success(())
                } else {
                    return .failure(NSError(domain: "EntryError", code: 403, userInfo: [NSLocalizedDescriptionKey: "You are not authorized to delete this entry."]))
                }
            } catch {
                print("Error removing entry: \(error)")
                return .failure(error)
        }
    }
    
    func removeChild(childId: String, userId: String) async -> Result<Void, Error> {
        do {
            // Query to find the child based on the childId
            let predicate = Child.keys.id.eq(childId)
            let children = try await Amplify.DataStore.query(Child.self, where: predicate)
            
            print("Children found: \(children)")  // Debugging line
            
            guard let child = children.first else {
                print("Child not found for id: \(childId)")  // Debugging line
                return .failure(NSError(domain: "ChildError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Child not found."]))
            }
            
            print("Child found: \(child)")  // Debugging line
            
            // Check if the current user is the owner of the child record
            if child.idUser == userId {
                print("User \(userId) is the owner of child \(childId)")  // Debugging line
                
                // Fetch all related entries for this child
                guard let entries = await fetchEntriesForChild(childId: childId) else {
                    print("Entries not found for child \(childId)")  // Debugging line
                    return .failure(NSError(domain: "EntryError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Entries not found."]))
                }
                
                print("Entries found: \(entries)")  // Debugging line
                
                // Delete all related entries for this child
                for entry in entries {
                    print("Deleting entry: \(entry)")  // Debugging line
                    try await Amplify.DataStore.delete(entry)
                }
                
                // Delete the specific link between the user and this child
                if let link = await fetchLinkForUserAndChild(childId: childId, userId: userId) {
                    print("Found link between user and child: \(link)")  // Debugging line
                    try await Amplify.DataStore.delete(link)
                } else {
                    print("Link between user and child not found")  // Debugging line
                    return .failure(NSError(domain: "LinkError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Link between user and child not found."]))
                }
                
                // Now delete the child record
                print("Deleting child: \(child)")  // Debugging line
                try await Amplify.DataStore.delete(child)
                return .success(())
            } else {
                print("User \(userId) is not authorized to delete this child")  // Debugging line
                return .failure(NSError(domain: "ChildError", code: 403, userInfo: [NSLocalizedDescriptionKey: "You are not authorized to delete this child."]))
            }
        } catch {
            print("Error removing child: \(error)")  // Debugging line
            return .failure(error)
        }
    }
    
    func removeLinkById(linkId: String) async -> Result<Void, Error> {
        do {
            // Create a predicate to query the LinkChildToUser entry for the specific id
            let predicate = LinkChildToUser.keys.id.eq(linkId)
            
            // Query the DataStore for the matching link
            let links = try await Amplify.DataStore.query(LinkChildToUser.self, where: predicate)
            
            // Ensure a link exists
            guard let link = links.first else {
                return .failure(NSError(
                    domain: "LinkChildToUserError",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Link not found."]
                ))
            }
            
            // Delete the link
            try await Amplify.DataStore.delete(link)
            return .success(())
        } catch {
            print("Error removing link: \(error)")
            return .failure(error)
        }
    }
}
