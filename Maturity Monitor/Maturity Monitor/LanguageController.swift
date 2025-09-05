import Foundation

//// Define a constant to use as the key for storing the selected language in UserDefaults
//let LocalizeUserDefaultKey = "LocalizeUserDefaultKey"
//// Attempt to fetch the user's preferred language from UserDefaults. If not found, default to "en" (English).
//var LocalizeDefaultLanguage = UserDefaults.standard.string(forKey: LocalizeUserDefaultKey) ?? "en"
//
//extension String {
//    // Define a function to return the translated string for the current language
//    func translated() -> String {
//        // Try to locate the resource file for the language (e.g., en.lproj, fr.lproj, etc.)
//        if let path = Bundle.main.path(forResource: LocalizeDefaultLanguage, ofType: "lproj") {
//            // If path is found, create a Bundle instance for that language
//            if let bundle = Bundle(path: path) {
//                // Return the localized string using the NSLocalizedString function, which looks for a string translation
//                // in the specified language bundle.
//                return NSLocalizedString(self, bundle: bundle, comment: "")
//            } else {
//                // Print an error if the bundle couldn't be created
//                print("Failed to create bundle for language: \(LocalizeDefaultLanguage) at path: \(path)")
//            }
//        } else {
//            // Print an error if the language folder doesn't exist
//            print("Language folder not found for language: \(LocalizeDefaultLanguage)")
//        }
//        // If the resource file is not found or bundle creation fails, return an empty string as a fallback.
//        return ""
//    }
//}
//
//// Extend Notification.Name to define a custom notification name called "languageChanged"
//extension Notification.Name {
//    static let languageChanged = Notification.Name("languageChanged")
//}
