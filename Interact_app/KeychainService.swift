//
//  KeychainService.swift
//  Interact_app
//
//  Created by admin56 on 10/12/25.
//

import Foundation
import Security

public final class KeychainService {
    private let service: String

    public init(service: String = Bundle.main.bundleIdentifier ?? "supabase.app") {
        self.service = service
    }

    @discardableResult
    public func set(_ value: String, for key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
        let add: [String: Any] = query.merging([kSecValueData as String: data]) { (_, new) in new }
        let status = SecItemAdd(add as CFDictionary, nil)
        return status == errSecSuccess
    }

    public func get(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data, let str = String(data: data, encoding: .utf8) else {
            return nil
        }
        return str
    }

    @discardableResult
    public func delete(_ key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    public func clearAll(keys: [String]) {
        for k in keys { _ = delete(k) }
    }
}

public enum KeychainKeys {
    public static let accessToken = "supabase_access_token"
    public static let refreshToken = "supabase_refresh_token"
    public static let tokenType = "supabase_token_type"
    public static let expiresAt = "supabase_expires_at"
}
