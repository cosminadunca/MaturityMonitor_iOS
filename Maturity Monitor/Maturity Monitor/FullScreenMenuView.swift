import SwiftUI

struct FullScreenMenuView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var currentPage: String

    private let menuOptions: [(title: String, tag: String, destination: AnyView)] = [
        ("Home", "home", AnyView(HomeView(currentPage: .constant("home")))),
        ("Children & Groups", "group", AnyView(GroupView(currentPage: .constant("group")))),
        ("Maturity Estimations", "resources", AnyView(ResourcesView(currentPage: .constant("resources")))),
        ("Account", "account", AnyView(AccountView(currentPage: .constant("account"))))
    ]

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: dismiss.callAsFunction) {
                            Image(systemName: "xmark")
                                .font(.system(size: 30))
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 20)
                    Spacer()
                    VStack(spacing: 20) {
                        ForEach(menuOptions, id: \.tag) { option in
                            NavigationLink(destination: option.destination) {
                                Text(option.title)
                                    .font(.custom("Inter", size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 330, height: 55)
                                    .background(currentPage == option.tag ? Color.buttonGreyLight : Color.buttonPurpleLight)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                            .disabled(currentPage == option.tag)
                        }
                    }
                    .padding()
                    Spacer()
                    Spacer()
                    Spacer()
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    FullScreenMenuView(currentPage: .constant("home"))
}
