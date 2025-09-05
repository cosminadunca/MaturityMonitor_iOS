// Resources View comments and messages done - needs testing

import SwiftUI
import Mixpanel

struct ResourcesView: View {
    
    @Binding var currentPage: String
    @State private var showMenu = false
    @State private var selectedTab: Tab = .resources

    enum Tab {
        case resources
        case home
    }
    
    // Mixpanel variables
    @State private var viewStartTime: Date = Date()
    @State private var tabSwitchCount: Int = 0
    @State private var previousTab: Tab = .resources

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack {
                    HStack(spacing: 0) {
                        Text("Maturity Estimations")
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
                    .onChange(of: selectedTab) { newTab in
                        if newTab != previousTab {
                            tabSwitchCount += 1
                            previousTab = newTab
                        }
                    }
                    .accentColor(.buttonPurpleLight)
                    .frame(height: UIScreen.main.bounds.height * 0.85)
                }
                .edgesIgnoringSafeArea(.top)
                .edgesIgnoringSafeArea(.bottom)
                .fullScreenCover(isPresented: $showMenu) {
                    FullScreenMenuView(currentPage: $currentPage)
                }.navigationBarBackButtonHidden(true)
                .onAppear {
                    viewStartTime = Date()
                }
                .onDisappear {
                    trackTabSwitches()
                    trackViewTime()
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    // Mixpanel
    private func trackViewTime() {
        let timeSpent = Date().timeIntervalSince(viewStartTime)
        Mixpanel.mainInstance().track(event: "MIX Resources View Time", properties: ["time_spent": timeSpent])
    }
    
    private func trackTabSwitches() {
        Mixpanel.mainInstance().track(event: "MIX Tab Switches in Resources View", properties: [
            "switch_count": tabSwitchCount
        ])
    }

}

#Preview {
    ResourcesView(currentPage: .constant("resources"))
}
