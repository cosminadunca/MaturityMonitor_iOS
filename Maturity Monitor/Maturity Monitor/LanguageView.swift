import SwiftUI

struct LanguageView: View {
    @Binding var currentPage: String
    @State private var showMenu = false
    
    private let languages = [
        ("English", "en"),
        ("العربية", "ar"),
        ("Français", "fr"),
        ("Deutsch", "de"),
        ("Español", "es")
    ]

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack(spacing: 20) {
                    // Top Menu Header
                    HStack {
                        Spacer()
                        Button(action: {
                            showMenu = true
                            print("Menu button tapped")
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .font(Font.custom("Inter", size: 35))
                                .foregroundColor(.black)
                                .padding(.leading, 8)
                        }
                    }
                    .padding()
                    .padding(.top, 70)
                    
                    Text(NSLocalizedString("changeLanguageMessage", comment: "Change language of entire app below:"))
                        .padding(.leading, 10)
                    
                    List {
                        ForEach(languages, id: \.1) { language in
                            HStack {
                                Text(language.0)
                                Spacer()
                                if languageManager.selectedLanguage == language.1 {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                print("Language tapped: \(language.0) (\(language.1))")
                                languageManager.setLanguage(language.1)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    
                    Spacer()
                }
                .edgesIgnoringSafeArea(.top)
                .fullScreenCover(isPresented: $showMenu) {
                    FullScreenMenuView(currentPage: $currentPage)
                }
                .navigationBarBackButtonHidden(true)
            }
        } else {
            // Fallback on earlier versions: display a Text view instead of print()
            Text("This feature is not available on versions prior to iOS 16.0")
                .foregroundColor(.red)
                .padding()
        }
    }
}

#Preview {
    LanguageView(currentPage: .constant("account"))
}
