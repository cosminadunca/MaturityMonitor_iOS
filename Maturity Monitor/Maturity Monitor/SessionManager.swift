import Foundation

class SessionManager {
    static let shared = SessionManager()
    
    let sessionID: String
    
    private init() {
        // Use a persistent or per-launch UUID
        self.sessionID = UUID().uuidString
        print("🆔 Generated Session ID: \(sessionID)")
    }
}
