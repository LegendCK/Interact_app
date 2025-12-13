//
//  SupabaseConfig.swift
//  Interact_app
//
//  Created by admin56 on 10/12/25.
//

import Foundation

public struct SupabaseConfig {
    public let url: URL
    public let anonKey: String

    public enum SupabaseConfigError: Error {
        case missingInfo(String)
        case invalidURL(String)
    }

    public init(bundle: Bundle = .main) throws {
        guard let info = bundle.infoDictionary else {
            throw SupabaseConfigError.missingInfo("Info.plist is missing")
        }

        guard let urlString = info["SUPABASE_URL"] as? String, !urlString.isEmpty else {
            throw SupabaseConfigError.missingInfo("SUPABASE_URL not set in Info.plist / xcconfig")
        }
        guard let anon = info["SUPABASE_ANON_KEY"] as? String, !anon.isEmpty else {
            throw SupabaseConfigError.missingInfo("SUPABASE_ANON_KEY not set in Info.plist / xcconfig")
        }
        guard let url = URL(string: urlString) else {
            throw SupabaseConfigError.invalidURL("SUPABASE_URL is not a valid URL: \(urlString)")
        }

        self.url = url
        self.anonKey = anon
    }
}
