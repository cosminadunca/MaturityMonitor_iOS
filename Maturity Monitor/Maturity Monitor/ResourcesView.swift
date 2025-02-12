// Resources View comments and messages done - needs testing

import SwiftUI

struct ResourcesView: View {
    
    @Binding var currentPage: String
    @State private var showMenu = false
    @State private var selectedTab: Tab = .resources

    enum Tab {
        case resources
        case home
    }

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack {
                    HStack(spacing: 0) {
                        Text("Resources")
                            .font(Font.custom("Inter-Regular", size: 20))
                            .foregroundColor(.black)
                        Spacer()
                        Button(action: {
                            showMenu = true
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .font(Font.custom("Inter", size: 35))
                                .foregroundColor(.black)
                                .padding(.leading, 8)
                        }
                    }
                    .padding()
                    .padding(.top, 70)
                    
                    TabView(selection: $selectedTab) {
                        Graphs(BetaValues: loadCSVData(fileName: "exampleFileName")) 
                            .tabItem {
                                VStack {
                                    Image(systemName: "aspectratio")
                                    Text("Graphs")
                                        .font(.footnote)
                                }
                            }
                            .tag(Tab.resources)
                        
                        VideosView()
                            .tabItem {
                                VStack {
                                    Image(systemName: "video.fill")
                                    Text("Videos")
                                        .font(.footnote)
                                }
                            }
                            .tag(Tab.home)
                    }
                    .accentColor(.buttonPurpleLight)
                    .frame(height: UIScreen.main.bounds.height * 0.85)
                }
                .edgesIgnoringSafeArea(.top)
                .edgesIgnoringSafeArea(.bottom)
                .fullScreenCover(isPresented: $showMenu) {
                    FullScreenMenuView(currentPage: $currentPage)
                }.navigationBarBackButtonHidden(true)
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    ResourcesView(currentPage: .constant("resources"))
}
