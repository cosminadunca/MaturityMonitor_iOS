// Group View comments and messages done - needs testing

import SwiftUI
import Amplify

struct GroupView: View {
    
    private let amplifyService = AmplifyService()
    
    @Binding var currentPage: String
    @State private var selectedTab = 0
    @State private var showMenu = false

    @State private var userName: String = ""
    @State private var userSurname: String = ""
    @State private var currentChildName: String = ""
    @State private var currentChildGender: String = ""

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                ZStack {
                    VStack(spacing: 0) {
                        topBar
                        childInfo
                        tabButtons
                        Divider()
                            .background(Color.buttonGreyLightStroke)
                            .frame(height: 1)
                        contentArea
                    }
                    .padding(.top, 70)
                    .edgesIgnoringSafeArea(.top)
                    bottomMenu
                }
            }
            .fullScreenCover(isPresented: $showMenu) {
                FullScreenMenuView(currentPage: $currentPage)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true) // Hide the whole navigation bar
            .interactiveDismissDisabled(true) // Disable swipe back gesture
            .onAppear {
                fetchUserDetails()
            }
        } else {
            // Fallback on earlier versions
        }
    }

    private var topBar: some View {
        HStack(spacing: 0) {
            Spacer()
            Button(action: { showMenu = true }) {
                Image(systemName: "line.horizontal.3")
                    .font(Font.custom("Inter", size: 35))
                    .foregroundColor(.black)
                    .padding(.leading, 8)
            }
        }
        .padding(.trailing)
        .padding(.top)
    }

    private var childInfo: some View {
        HStack {
            Text("Child: ")
                .font(Font.custom("Inter-Regular", size: 25))
                .foregroundColor(.black)

            Text(currentChildName)
                .font(Font.custom("Inter-Regular", size: 25))
                .foregroundColor(.buttonPurpleLight)
        }
        .padding(.top, 25)
        .padding(.bottom, 25)
    }

    private var tabButtons: some View {
        HStack(spacing: 20) {
            Button(action: { selectedTab = 0 }) {
                Text("Children")
                    .font(Font.custom("Inter", size: 15))
                    .foregroundColor(selectedTab == 0 ? Color.black.opacity(0.6) : .white)
                    .frame(width: 140, height: 35)
                    .background(selectedTab == 0 ? Color.buttonGreyLight : Color.buttonTurquoiseDark)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedTab == 0 ? Color.clear : Color.buttonGreyLightStroke, lineWidth: 1)
                    )
                    .shadow(color: selectedTab == 0 ? Color.clear : Color.black.opacity(0.2), radius: 4, x: 5, y: 5)
                    .padding(.bottom, 20)
            }.disabled(selectedTab == 0)

            Button(action: { selectedTab = 1 }) {
                Text("Groups")
                    .font(Font.custom("Inter", size: 15))
                    .foregroundColor(selectedTab == 1 ? Color.black.opacity(0.6) : .black)
                    .frame(width: 140, height: 35)
                    .background(selectedTab == 1 ? Color.buttonGreyLight : Color.groupPink)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedTab == 1 ? Color.clear : Color.buttonGreyLightStroke, lineWidth: 1)
                    )
                    .shadow(color: selectedTab == 1 ? Color.clear : Color.black.opacity(0.2), radius: 4, x: 5, y: 5)
                    .padding(.bottom, 20)
            }.disabled(selectedTab == 1)
        }
    }

    private var contentArea: some View {
        Group {
            if selectedTab == 0 {
                ChildrenView()
            } else {
                GroupListView()
            }
        }
    }

    private var bottomMenu: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Menu {
                    NavigationLink(destination: GroupView(currentPage: .constant("group"))) {
                        Label("Switch account", systemImage: "arrow.left.arrow.right")
                    }
                    NavigationLink(destination: RequestGroupAccessView()) {
                        Label("Link group", systemImage: "figure.2.arms.open")
                    }
                    NavigationLink(destination: RequestChildAccessView()) {
                        Label("Link child", systemImage: "figure")
                    }
                    NavigationLink(destination: AddChildStepOneView()) {
                        Label("Add new child", systemImage: "plus")
                    }
                } label: {
                    Image(systemName: currentChildGender == "Male" ? "figure.stand" : "figure.stand.dress")
                        .font(.system(size: 45))
                        .foregroundColor(.buttonTurquoiseDark)
                        .padding()
                        .shadow(color: Color.buttonTurquoiseDark.opacity(0.25), radius: 10)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 0)
        }
    }

    private func fetchUserDetails() {
        Task {
            if let (firstName, lastName, currentChildId) = await amplifyService.fetchUserAttributes() {
                userName = firstName
                userSurname = lastName
                await fetchCurrentChild(childId: currentChildId)
            }
        }
    }

    private func fetchCurrentChild(childId: String) async {
        if let child = await amplifyService.queryChildByIdDataStore(childId: childId) {
            currentChildName = "\(child.name) \(child.surname)"
            currentChildGender = child.gender
            print("Successfully retrieved child: \(child)")
        } else {
            print("Could not find child")
        }
    }
}


#Preview {
    GroupView(currentPage: .constant("group"))
}
