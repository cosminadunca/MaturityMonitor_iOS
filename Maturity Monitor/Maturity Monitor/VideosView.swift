// Videos View comments and messages done - needs testing

import SwiftUI
import WebKit

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
                WebView(urlString: "https://www.youtube.com/embed/2D9kWCz-EyE?rel=0&modestbranding=1&autohide=1&showinfo=0&controls=1")
                    .frame(height: 200)
                    .cornerRadius(10)
                    .padding()
            }
        }
    }
}

#Preview {
    VideosView()
}
