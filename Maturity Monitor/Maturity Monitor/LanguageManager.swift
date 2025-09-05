//import Foundation
//import Combine
//
//class LanguageManager: ObservableObject {
//    @Published var selectedLanguage: String {
//        didSet {
//            // Post a notification when the language changes
//            NotificationCenter.default.post(name: .languageChanged, object: nil)
//        }
//    }
//
//    init() {
//        // Initialize the language from UserDefaults
//        self.selectedLanguage = UserDefaults.standard.string(forKey: LocalizeUserDefaultKey) ?? "en"
//    }
//
//    func setLanguage(_ code: String) {
//        selectedLanguage = code
//        UserDefaults.standard.setValue(code, forKey: LocalizeUserDefaultKey)
//    }
//}
