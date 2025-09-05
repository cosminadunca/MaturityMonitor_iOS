// Videos View comments and messages done - needs testing

import SwiftUI
import WebKit
import Mixpanel

// WebView to load and display YouTube videos
struct WebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}

struct VideosView: View {
    
    // Mixpanel variables
    @State private var viewStartTime: Date = Date()
    
    var body: some View {
        ScrollView {
            VStack {
                // Video 1
                Text("How to measure weight")
                    .font(Font.custom("Inter", size: 15))
                    .padding(.top)
                WebView(urlString: "https://www.youtube.com/embed/Z8sU-W49ZGE?rel=0&modestbranding=1&autohide=1&showinfo=0&controls=1")
                    .frame(height: 200) // Adjust frame height to remove space at the bottom of video
                    .cornerRadius(10)
                    .padding()
                    .padding(.bottom, 25)

                // Video 2
                Text("How to measure height")
                    .font(Font.custom("Inter", size: 15))
                    .padding(.top)
                WebView(urlString: "https://www.youtube.com/embed/2D9kWCz-EyE?rel=0&modestbranding=1&autohide=1&showinfo=0&controls=1")
                    .frame(height: 200)
                    .cornerRadius(10)
                    .padding()
                    .padding(.bottom, 25)

                // Video 3
                Text("How to measure standing height")
                    .font(Font.custom("Inter", size: 15))
                    .padding(.top)
                WebView(urlString: "https://www.youtube.com/embed/Q-BjPHS5pfQ?rel=0&modestbranding=1&autohide=1&showinfo=0&controls=1")
                    .frame(height: 200)
                    .cornerRadius(10)
                    .padding()
            }
        }
        .onAppear {
            viewStartTime = Date()
        }
        .onDisappear {
            trackViewTime()
        }
    }
    
    // Mixpanel
    private func trackViewTime() {
        let timeSpent = Date().timeIntervalSince(viewStartTime)
        Mixpanel.mainInstance().track(event: "MIX Videos View Time", properties: ["time_spent": timeSpent])
    }
}

#Preview {
    VideosView()
}
