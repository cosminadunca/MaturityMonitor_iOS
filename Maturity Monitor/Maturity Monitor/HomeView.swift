import SwiftUI
import Amplify

struct HomeView: View {
    
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
                    
                    if showMenu {
                        FullScreenMenuView(currentPage: $currentPage)
                            .transition(.move(edge: .bottom)) // Smooth transition
                    }
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
            Text("Hi, \(userName) \(userSurname)!")
                .font(Font.custom("Inter-Regular", size: 15))
                .foregroundColor(.black)
            Spacer()
            Button(action: {
                withAnimation {
                    showMenu.toggle()
                }
            }) {
                Image(systemName: "line.horizontal.3")
                    .font(Font.custom("Inter", size: 35))
                    .foregroundColor(.black)
            }
        }
        .padding()
    }
    
    private var childInfo: some View {
        HStack {
            SimpleCustomText(title: "Child: ")
            SimpleCustomText(title: currentChildName)
        }
        .padding(.top, 25)
        .padding(.bottom, 35)
    }

    private var tabButtons: some View {
        HStack(spacing: 20) {
            ForEach(0..<2) { index in
                tabButton(title: index == 0 ? "New" : "Previous", index: index)
            }
        }
    }
    
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: { selectedTab = index }) {
            Text(title)
                .font(Font.custom("Inter", size: 15))
                .foregroundColor(selectedTab == index ? Color.black.opacity(0.6) : .black)
                .frame(width: 140, height: 35)
                .background(Color(red: 0.88, green: 0.88, blue: 0.88))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selectedTab == index ? Color.clear : Color.buttonGreyLightStroke, lineWidth: 1)
                )
                .shadow(color: selectedTab == index ? Color.clear : Color.black.opacity(0.2), radius: 4, x: 5, y: 5)
                .padding(.bottom, 20)
        }
    }
    
    private var contentArea: some View {
        Group {
            if selectedTab == 0 {
                NewEntryView()
            } else {
                AllEntriesView()
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
    HomeView(currentPage: .constant("home"))
}
