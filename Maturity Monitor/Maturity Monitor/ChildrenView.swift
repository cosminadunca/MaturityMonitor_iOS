// Improvements:
// 1. Add image picture of user who created the child
// 2. Add picture of the child

import SwiftUI
import Amplify

struct ChildrenView: View {
    
    private let amplifyService = AmplifyService()
    
    // 1
    @State private var children: [Child] = []
    @State private var currentUserID: String = ""
    // 2
    @State private var currentChildId: String = ""
    @State private var isLinkActive: Bool = false
    @State private var searchText: String = ""
    @State private var filterChildren: [Child] = []
    
    //  for changing the list
//    @State private var children: [Child] = [
//        Child(idUser: "8236SHG4jdk98109", userName: "bla", userSurname: "bli", name: "John", surname: "Doe", dateOfBirth: "14/03/2012", gender: "Male", motherHeight: "165", fatherHeight: "171", parentsMeasurements: "cm", country: "Romania", ethnicity: "White", primarySport: "swimming", approveData: true, disserartionApproval: true, uniqueId: 123456, status: .active),
//        Child(idUser: "8236SHG4jdk98109", userName: "bla", userSurname: "bli", name: "Maria", surname: "Doe", dateOfBirth: "14/03/2012", gender: "Male", motherHeight: "165", fatherHeight: "171", parentsMeasurements: "cm", country: "Romania", ethnicity: "White", primarySport: "swimming", approveData: true, disserartionApproval: true, uniqueId: 123456, status: .active),
//        Child(idUser: "8236SHG4jdk98109", userName: "bla", userSurname: "bli", name: "John", surname: "Mark", dateOfBirth: "14/03/2012", gender: "Male", motherHeight: "165", fatherHeight: "171", parentsMeasurements: "cm", country: "Romania", ethnicity: "White", primarySport: "swimming", approveData: true, disserartionApproval: true, uniqueId: 123456, status: .active)
//    ]
//    @State private var currentChildId: String = "1" // Static current child ID
    
    //  end for changing the list
    
    // This will change the list
    var filteredChildren: [Child] {
        if searchText.isEmpty {
            return children
        } else {
            return children.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.surname.localizedCaseInsensitiveContains(searchText)
            }
            .sorted { $0.name < $1.name }
        }
    }

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search by name or surname...", text: $searchText)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 8)
                    .accentColor(Color("ButtonGreyLight"))
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 8)
            List(filteredChildren, id: \.id) { child in
                HStack (spacing: 20) {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: child.gender == "Male" ? "figure.stand" : "figure.stand.dress")
                                .resizable()
                                .frame(width: 10, height: 20)
                                .foregroundColor(.buttonTurquoiseDark)
                            Text("\(child.name) \(child.surname)")
                                .font(Font.custom("Inter", size: 18))
                                .foregroundColor(.black)
                        }
                        Text("Unique code: \(String(format: "%06d", child.uniqueId))")
                            .font(Font.custom("Inter", size: 14))
                            .foregroundColor(.black)
                        Spacer()
                        if currentUserID != child.idUser {
                            Text("Created by: \(child.userName) \(child.userSurname)")
                                .font(Font.custom("Inter", size: 14))
                                .foregroundColor(.black)
                        } else {
                            Text("Created by: YOU")
                                .font(Font.custom("Inter", size: 14))
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    VStack {
                        if currentChildId != child.id {
                            Button(action: {
                                Task {
                                    await switchCurrentChild(to: child.id)
                                }
                            }) {
                                HStack{
                                    Text("Switch to this child")
                                    Image(systemName: "arrow.uturn.forward")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.black)
                                        .padding(.top, 5)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        Spacer()
                        NavigationLink(destination: EditProfileView(child: child)) {
                            CustomButton(
                                title: "View Profile",
                                backgroundColor: Color(.buttonPurpleLight),
                                textColor: .white,
                                width: 120,
                                height: 30,
                                cornerRadius: 10
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                }
                .frame(height: 150)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.buttonTurquoiseDark, lineWidth: 2)
                )
            }
            .listStyle(PlainListStyle())
            .onAppear {
                Task {
                    await loadChildren()
                }
            }
            NavigationLink(destination: GroupView(currentPage: .constant("group")), isActive: $isLinkActive) {
                EmptyView()
            }
            .hidden()
        }
    }
    
    // Load list of children
    private func loadChildren() async {
        do {
            if let userId = await amplifyService.fetchCurrentUserId() {
                print("Fetched User ID: \(userId)")
                self.currentUserID = userId
            } else {
                print("Failed to fetch User ID")
            }
            
            if let currentChild = try await amplifyService.getCurrentChild() {
                print("Fetched Current Child ID: \(currentChild)")
                self.currentChildId = currentChild
            } else {
                print("No Current Child Found")
            }
            
            let linkToDelete = await amplifyService.fetchLinkForUserAndChild(childId: currentChildId, userId: currentUserID)
            
            if let linkedChildren = await amplifyService.fetchLinkedChildrenForUser(userID: currentUserID) {
                print("Fetched Linked Children: \(linkedChildren)")
                var fetchedChildren: [Child] = []
                for linkedChild in linkedChildren {
                    print("Entered here!!")
                    let childFromLink = linkedChild.child
                    print("Child from Link: \(childFromLink)")

                    // Access the ID of the `Child` instance
                    let childId = childFromLink.id
                    print("Child ID from Child Instance: \(childId)")
                    
                    if let childDetails = await amplifyService.queryChildByIdDataStore(childId: childId) {
                        fetchedChildren.append(childDetails)
                        print("Fetched details for child ID: \(childDetails)")
                    } else {
                        print("Failed to fetch details for child ID: \(linkToDelete)")
                    }
                }
                self.children = fetchedChildren
                print("Fetched Children: \(self.children)")
            } else {
                print("No Linked Children Found")
            }
        } catch {
            print("Error loading children: \(error)")
        }
    }

    // Switch current child
    private func switchCurrentChild(to childId: String) async {
        let result = await amplifyService.updateCurrentChildAttribute(with: childId)
        if result.contains("successfully") {
            self.currentChildId = childId
            self.isLinkActive = true
        } else {
            print(result)
        }
    }
}

struct ChildrenView_Previews: PreviewProvider {
    static var previews: some View {
        ChildrenView()
    }
}
