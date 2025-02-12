// Improvements:
// 1. Add image picture of user who created the entry

import SwiftUI
import Amplify

struct AllEntriesView: View {
    
    private let amplifyService = AmplifyService()
    
    @State private var entries: [Entry] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    @State private var showDeleteConfirmation: Bool = false
    @State private var entryIdToDelete: String? = nil
    @State private var currentUserId: String? = nil
    
    //  for changing the list
//    @State private var childEx = Child(
//            idUser: "8236SHG4jdk98109",
//            name: "John",
//            surname: "Doe",
//            dateOfBirth: "14/03/2012",
//            gender: "Male",
//            motherHeight: "165",
//            fatherHeight: "171",
//            parentsMeasurements: "cm",
//            country: "Romania",
//            ethnicity: "White",
//            primarySport: "swimming",
//            approveData: true,
//            disserartionApproval: true,
//            uniqueId: 123456,
//            status: .active
//        )
//        
//    @State private var entries: [Entry]
//        
//    init() {
//        let child = Child(
//            idUser: "8236SHG4jdk98109",
//            name: "John",
//            surname: "Doe",
//            dateOfBirth: "14/03/2012",
//            gender: "Male",
//            motherHeight: "165",
//            fatherHeight: "171",
//            parentsMeasurements: "cm",
//            country: "Romania",
//            ethnicity: "White",
//            primarySport: "swimming",
//            approveData: true,
//            disserartionApproval: true,
//            uniqueId: 123456,
//            status: .active
//        )
//        
//        _entries = State(initialValue: [
//            Entry(idUser: "8236SHG4jdk98109", weight: "123", height: "123", sittingHeigh: "123", dateOfEntry: "11/03/2014", child: child),
//            Entry(idUser: "8236SHG4jdk98109", weight: "123", height: "123", sittingHeigh: "123", dateOfEntry: "15/08/2022", child: child),
//            Entry(idUser: "8236SHG4jdk98109", weight: "123", height: "123", sittingHeigh: "123", dateOfEntry: "01/11/2016", child: child),
//            Entry(idUser: "8236SHG4jdk98109", weight: "123", height: "123", sittingHeigh: "123", dateOfEntry: "11/03/2014", child: child),
//            Entry(idUser: "8236SHG4jdk98109", weight: "123", height: "123", sittingHeigh: "123", dateOfEntry: "15/08/2022", child: child),
//            Entry(idUser: "8236SHG4jdk98109", weight: "123", height: "123", sittingHeigh: "123", dateOfEntry: "01/11/2016", child: child)
//        ])
//    }
    
    //  for changing the list
    

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading entries...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = errorMessage {
                Spacer()
                ErrorCustomText(title: errorMessage)
                Spacer()
            } else {
                if entries.isEmpty {
                    Spacer()
                    Text("No entries available yet. Add a new entry!")
                    Spacer()
                } else {
                    List(entries, id: \.id) { entry in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(entry.dateOfEntry)")
                                    .font(Font.custom("Inter", size: 18))
                                    .foregroundColor(.black)
                                Spacer()
                                
                                if entry.idUser == currentUserId {
                                    Button(action: {
                                        entryIdToDelete = entry.id
                                        showDeleteConfirmation = true
                                    }) {
                                        CustomButton(
                                            title: "Remove",
                                            backgroundColor: Color.buttonPurpleLight,
                                            textColor: .white,
                                            width: 120,
                                            height: 30,
                                            cornerRadius: 10
                                        )
                                    }
                                }
                            }
                            .padding()
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Weight: \(entry.weight)")
                                        .font(Font.custom("Inter", size: 15))
                                        .foregroundColor(.black)
                                    Text("Height: \(entry.height)")
                                        .font(Font.custom("Inter", size: 15))
                                        .foregroundColor(.black)
                                        .padding(.top, 5)
                                    Text("Sitting Height: \(entry.sittingHeigh)")
                                        .font(Font.custom("Inter", size: 15))
                                        .foregroundColor(.black)
                                        .padding(.top, 5)
                                }
                                Spacer()
                                if entry.idUser != currentUserId {
                                    Text("Created by: \(entry.userName) \(entry.userSurname)")
                                        .font(Font.custom("Inter", size: 14))
                                        .foregroundColor(.buttonTurquoiseDark)
                                } else {
                                    Text("Created by: YOU")
                                        .font(Font.custom("Inter", size: 14))
                                        .foregroundColor(.buttonTurquoiseDark)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding()
                        }
                    }
                    .listStyle(PlainListStyle())
                    .padding(.horizontal, -10)
                }
            }
        }
        .onAppear {
            Task {
                await loadEntries()
            }
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Confirm Deletion"),
                message: Text("Are you sure you want to delete this entry created by you?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let entryId = entryIdToDelete {
                        Task {
                            await deleteEntry(entryId: entryId)
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func loadEntries() async {
        do {
            guard let userId = try await amplifyService.fetchCurrentUserId() else {
                throw NSError(domain: "AuthError", code: 403, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch user ID."])
            }
            self.currentUserId = userId

            guard let currentChildId = try await amplifyService.getCurrentChild(),
                  let childDetails = await amplifyService.queryChildByIdDataStore(childId: currentChildId),
                  let fetchedEntries = await amplifyService.fetchEntriesForChild(childId: childDetails.id) else {
                throw NSError(domain: "DataError", code: 404, userInfo: [NSLocalizedDescriptionKey: "No entries found."])
            }

            // Log fetched entries
            print("Fetched Entries: \(fetchedEntries)")

            // Attempt to parse and sort entries
            self.entries = fetchedEntries.sorted { entry1, entry2 in
                if let date1 = dateFormatter.date(from: entry1.dateOfEntry),
                let date2 = dateFormatter.date(from: entry2.dateOfEntry) {
                    print("Parsed Dates: \(date1) vs \(date2)")
                    return date1 > date2 // Newest first
                } else {
                    print("Failed to parse dates for entries: \(entry1.dateOfEntry), \(entry2.dateOfEntry)")
                    return false // Keep original order if parsing fails
                }
            }

            // Log the sorted result
            print("Sorted Entries: \(self.entries)")

            self.isLoading = false
        } catch {
            print("Error loading entries: \(error)")
            self.errorMessage = "Failed to load entries."
            self.isLoading = false
        }
    }
    
    private func deleteEntry(entryId: String) async {
        guard let userId = currentUserId else {
            self.errorMessage = "Unable to identify current user."
            return
        }
        
        let result = await amplifyService.removeEntry(entryId: entryId, userId: userId)
        
        switch result {
        case .success:
            await loadEntries()
        case .failure(let error):
            print("Error deleting entry: \(error)")
            self.errorMessage = error.localizedDescription
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy" // Adjust this to match your date format
        return formatter
    }()
}

#Preview {
    AllEntriesView()
}
