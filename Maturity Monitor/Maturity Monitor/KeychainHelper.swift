import Security

class KeychainHelper {
    
    static let shared = KeychainHelper()
    
    func saveCredentials(email: String, password: String) -> Bool {
        // Save email
        let emailData = email.data(using: .utf8)!
        let emailQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "userEmail",
            kSecValueData as String: emailData
        ]
        SecItemDelete(emailQuery as CFDictionary) // Delete any existing email
        let emailStatus = SecItemAdd(emailQuery as CFDictionary, nil)
        
        // Save password
        let passwordData = password.data(using: .utf8)!
        let passwordQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "userPassword",
            kSecValueData as String: passwordData
        ]
        SecItemDelete(passwordQuery as CFDictionary) // Delete any existing password
        let passwordStatus = SecItemAdd(passwordQuery as CFDictionary, nil)
        
        return emailStatus == errSecSuccess && passwordStatus == errSecSuccess
    }
    
    func retrieveCredentials() -> (email: String?, password: String?) {
        // Retrieve email
        let emailQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "userEmail",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let emailStatus = SecItemCopyMatching(emailQuery as CFDictionary, &result)
        
        var email: String?
        if emailStatus == errSecSuccess, let data = result as? Data {
            email = String(data: data, encoding: .utf8)
        }
        
        // Retrieve password
        let passwordQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "userPassword",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        result = nil
        let passwordStatus = SecItemCopyMatching(passwordQuery as CFDictionary, &result)
        
        var password: String?
        if passwordStatus == errSecSuccess, let data = result as? Data {
            password = String(data: data, encoding: .utf8)
        }
        
        return (email, password)
    }
    
    func deleteCredentials() {
        let emailQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "userEmail"
        ]
        SecItemDelete(emailQuery as CFDictionary)
        
        let passwordQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "userPassword"
        ]
        SecItemDelete(passwordQuery as CFDictionary)
    }
}
