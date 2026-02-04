//
//  ProfileCache.swift
//  Interact_app
//
//  Created by admin56 on 14/01/26.
//

import Foundation

enum ProfileCache {
    
    // MARK: - Keys
    private static let qrTokenKey = "qr_public_token"
    private static let profileDataKey = "cached_profile_data"
    private static let profileTimestampKey = "cached_profile_timestamp"
    
    // MARK: - Cache Expiry
    private static let cacheExpiryDuration: TimeInterval = 3600 // 1 hour
    
    // MARK: - QR Token Methods
    static func saveQRToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: qrTokenKey)
    }
    
    static func getQRToken() -> String? {
        UserDefaults.standard.string(forKey: qrTokenKey)
    }
    
    // MARK: - Profile Cache Methods
    
    /// Save profile JSON to cache with current timestamp
    static func saveProfile(_ profileJSON: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: profileJSON) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: profileDataKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: profileTimestampKey)
    }
    
    /// Get cached profile if valid (not expired)
    static func getProfile() -> [String: Any]? {
        // Check if cache exists
        guard let data = UserDefaults.standard.data(forKey: profileDataKey),
              let timestamp = UserDefaults.standard.double(forKey: profileTimestampKey) as Double? else {
            return nil
        }
        
        // Check if cache is expired
        let cacheAge = Date().timeIntervalSince1970 - timestamp
        if cacheAge > cacheExpiryDuration {
            clearProfile() // Clear expired cache
            return nil
        }
        
        // Parse and return cached data
        guard let profileJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        return profileJSON
    }
    
    /// Check if cached profile is valid (exists and not expired)
    static func isProfileValid() -> Bool {
        guard let timestamp = UserDefaults.standard.double(forKey: profileTimestampKey) as Double? else {
            return false
        }
        
        let cacheAge = Date().timeIntervalSince1970 - timestamp
        return cacheAge <= cacheExpiryDuration
    }
    
    /// Get cache age in seconds (for debugging)
    static func getProfileCacheAge() -> TimeInterval? {
        guard let timestamp = UserDefaults.standard.double(forKey: profileTimestampKey) as Double? else {
            return nil
        }
        return Date().timeIntervalSince1970 - timestamp
    }
    
    /// Clear only profile cache
    static func clearProfile() {
        UserDefaults.standard.removeObject(forKey: profileDataKey)
        UserDefaults.standard.removeObject(forKey: profileTimestampKey)
    }
    
    // MARK: - Clear All Cache
    
    /// Clear all cached data (QR token + profile)
    static func clearAll() {
        UserDefaults.standard.removeObject(forKey: qrTokenKey)
        clearProfile()
    }
}
