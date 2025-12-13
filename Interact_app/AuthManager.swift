import Foundation
import AuthenticationServices
import Security

public final class AuthManager {

    // MARK: - Properties
    private let client: SupabaseClient
    private let keychain: KeychainService
    private let sessionQueue = DispatchQueue(label: "auth.session.queue", qos: .userInitiated)

    // MARK: - Listeners
    public typealias AuthStateChange = (Bool) -> Void
    private var listeners: [UUID: AuthStateChange] = [:]

    // MARK: - Session Model
    public struct Session: Codable {
        public let accessToken: String
        public let refreshToken: String?
        public let tokenType: String?
        public let expiresAt: Int?
    }

    // MARK: - Init
    public init(client: SupabaseClient, keychain: KeychainService = KeychainService()) {
        self.client = client
        self.keychain = keychain
    }

    // MARK: - Current Session
    public var currentSession: Session? {
        guard let access = keychain.get(KeychainKeys.accessToken) else { return nil }

        return Session(
            accessToken: access,
            refreshToken: keychain.get(KeychainKeys.refreshToken),
            tokenType: keychain.get(KeychainKeys.tokenType),
            expiresAt: keychain.get(KeychainKeys.expiresAt).flatMap { Int($0) }
        )
    }

    // MARK: - Persist Session
    private func persist(session: Session) {
        keychain.set(session.accessToken, for: KeychainKeys.accessToken)
        if let r = session.refreshToken { keychain.set(r, for: KeychainKeys.refreshToken) }
        if let t = session.tokenType { keychain.set(t, for: KeychainKeys.tokenType) }
        if let exp = session.expiresAt { keychain.set(String(exp), for: KeychainKeys.expiresAt) }
        notifyListeners()
    }

    private func clearSession() {
        keychain.clearAll(keys: [
            KeychainKeys.accessToken,
            KeychainKeys.refreshToken,
            KeychainKeys.tokenType,
            KeychainKeys.expiresAt
        ])
        notifyListeners()
    }

    // MARK: - Listeners
    private func notifyListeners() {
        let loggedIn = currentSession != nil
        listeners.values.forEach { $0(loggedIn) }
    }

    public func addListener(_ block: @escaping AuthStateChange) -> UUID {
        let id = UUID()
        listeners[id] = block
        block(currentSession != nil)
        return id
    }

    public func removeListener(_ id: UUID) {
        listeners[id] = nil
    }

    // MARK: - Email/Password Sign Up
    public func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {

        let request = client.makeSignUpRequest(email: email, password: password)

        URLSession.shared.dataTask(with: request) { data, resp, err in
            if let err { completion(.failure(err)); return }

            guard let http = resp as? HTTPURLResponse else {
                completion(.failure(Self.makeError("Invalid response"))); return
            }

            if 200 ... 299 ~= http.statusCode {
                completion(.success(()))
            } else {
                completion(.failure(Self.errorFromResponse(data, status: http.statusCode)))
            }
        }.resume()
    }

    // MARK: - Sign In
    public func signIn(email: String, password: String, completion: @escaping (Result<Session, Error>) -> Void) {

        let request = client.makeSignInRequest(email: email, password: password)

        URLSession.shared.dataTask(with: request) { data, resp, err in

            if let err { completion(.failure(err)); return }

            guard let http = resp as? HTTPURLResponse, let data else {
                completion(.failure(Self.makeError("Invalid response"))); return
            }

            if 200 ... 299 ~= http.statusCode {

                let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]

                guard let access = json?["access_token"] as? String else {
                    completion(.failure(Self.makeError("Missing access token")))
                    return
                }

                let expires = (json?["expires_in"] as? Int).map {
                    Int(Date().timeIntervalSince1970) + $0
                }

                let session = Session(
                    accessToken: access,
                    refreshToken: json?["refresh_token"] as? String,
                    tokenType: json?["token_type"] as? String,
                    expiresAt: expires
                )

                self.persist(session: session)
                completion(.success(session))
                return
            }

            completion(.failure(Self.errorFromResponse(data, status: http.statusCode)))

        }.resume()
    }

    // MARK: - Reset Password
    public func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {

        let request = client.makeRecoverRequest(email: email)

        URLSession.shared.dataTask(with: request) { _, resp, err in

            if let err { completion(.failure(err)); return }

            guard let http = resp as? HTTPURLResponse else {
                completion(.failure(Self.makeError("Invalid response"))); return
            }

            if 200 ... 299 ~= http.statusCode {
                completion(.success(()))
            } else {
                completion(.failure(Self.makeError("Reset failed: \(http.statusCode)")))
            }

        }.resume()
    }

    // MARK: - Sign Out
    public func signOut(serverSide: Bool = false, completion: @escaping (Result<Void, Error>) -> Void) {

        guard let session = currentSession else {
            completion(.success(())); return
        }

        if serverSide {
            let req = client.makeSignOutRequest(accessToken: session.accessToken)
            URLSession.shared.dataTask(with: req) { _, _, _ in
                self.clearSession()
                completion(.success(()))
            }.resume()
        } else {
            clearSession()
            completion(.success(()))
        }
    }

    // MARK: - Google OAuth
    public func signInWithGoogle(
        redirectTo: String = "interact://auth/callback",
        presentationContext: UIViewController?,
        completion: ((Result<Session, Error>) -> Void)? = nil
    ) {

        guard let url = client.makeAuthorizeURL(provider: "google", redirectTo: redirectTo) else {
            completion?(.failure(Self.makeError("Invalid OAuth URL")))
            return
        }

        let scheme = URL(string: redirectTo)?.scheme

        let session = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: scheme
        ) { callbackURL, error in

            if let error {
                completion?(.failure(error)); return
            }

            guard let callbackURL else {
                completion?(.failure(Self.makeError("Missing callback"))); return
            }

            self.handleRedirect(url: callbackURL, completion: completion)
        }

        if let ctx = presentationContext as? ASWebAuthenticationPresentationContextProviding {
            session.presentationContextProvider = ctx
        }

        session.prefersEphemeralWebBrowserSession = false
        session.start()
    }

    // MARK: - OAuth Redirect Handler
    public func handleRedirect(url: URL, completion: ((Result<Session, Error>) -> Void)? = nil) {

        let raw = url.fragment ?? url.query ?? ""
        var params: [String: String] = [:]

        raw.split(separator: "&").forEach { pair in
            let p = pair.split(separator: "=")
            if p.count == 2 {
                params[String(p[0])] = String(p[1]).removingPercentEncoding
            }
        }

        guard let access = params["access_token"] else {
            completion?(.failure(Self.makeError("Missing access token")))
            return
        }

        let exp = params["expires_in"].flatMap { Int($0) }.map {
            Int(Date().timeIntervalSince1970) + $0
        }

        let session = Session(
            accessToken: access,
            refreshToken: params["refresh_token"],
            tokenType: params["token_type"],
            expiresAt: exp
        )

        self.persist(session: session)
        completion?(.success(session))
    }

    // MARK: - Fetch User
    public func getUser(completion: @escaping (Result<[String: Any], Error>) -> Void) {

        guard let session = currentSession else {
            completion(.failure(Self.makeError("No active session"))); return
        }

        let request = client.makeGetUserRequest(accessToken: session.accessToken)

        URLSession.shared.dataTask(with: request) { data, resp, err in

            if let err { completion(.failure(err)); return }

            guard let http = resp as? HTTPURLResponse, let data else {
                completion(.failure(Self.makeError("Invalid response"))); return
            }

            if 200 ... 299 ~= http.statusCode {
                let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                if let json { completion(.success(json)) }
                else { completion(.failure(Self.makeError("User decode failed"))) }
            } else {
                completion(.failure(Self.errorFromResponse(data, status: http.statusCode)))
            }

        }.resume()
    }

    // MARK: - Create ORG Profile
    public func createOrgProfile(
        payload: [String: Any],
        maxRetries: Int = 3,
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {

        insertProfile(
            payload: payload,
            table: "org_profiles",
            defaultRole: "organizer",
            isParticipant: false,
            maxRetries: maxRetries,
            completion: completion
        )
    }

    // MARK: - Create PARTICIPANT Profile
    public func createParticipantProfile(
        payload: [String: Any],
        maxRetries: Int = 3,
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {

        insertProfile(
            payload: payload,
            table: "participant_profiles",
            defaultRole: "participant",
            isParticipant: true,
            maxRetries: maxRetries,
            completion: completion
        )
    }

    // MARK: - Shared Insert Logic
    private func insertProfile(
        payload: [String: Any],
        table: String,
        defaultRole: String,
        isParticipant: Bool,
        maxRetries: Int,
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {

        sessionQueue.async {

            // Must be logged in
            guard let session = self.currentSession else {
                DispatchQueue.main.async {
                    completion(.failure(Self.makeError("Not authenticated")))
                }
                return
            }

            guard let uid = Self.extractUserId(fromAccessToken: session.accessToken) else {
                DispatchQueue.main.async {
                    completion(.failure(Self.makeError("Unable to decode user ID")))
                }
                return
            }

            // Build body
            var body = payload
            body["id"] = uid
            body["role"] = body["role"] ?? defaultRole

            // username generation if missing
            if body["username"] == nil {
                if isParticipant {
                    let first = (body["first_name"] as? String) ?? "user"
                    let last = (body["last_name"] as? String) ?? ""
                    body["username"] = Self.generateParticipantUsername(first: first, last: last)
                } else {
                    let org = (body["org_name"] as? String) ?? "org"
                    body["username"] = Self.generateOrgUsername(from: org)
                }
            }

            // encode
            guard let json = try? JSONSerialization.data(withJSONObject: body) else {
                DispatchQueue.main.async {
                    completion(.failure(Self.makeError("Invalid JSON body")))
                }
                return
            }

            let request = self.client.makePostgrestInsertRequest(
                table: table,
                body: json,
                accessToken: session.accessToken
            )

            URLSession.shared.dataTask(with: request) { data, resp, err in

                func fail(_ msg: String) {
                    DispatchQueue.main.async { completion(.failure(Self.makeError(msg))) }
                }

                if let err { fail(err.localizedDescription); return }
                guard let http = resp as? HTTPURLResponse, let data else {
                    fail("Invalid response"); return
                }

                if 200 ... 299 ~= http.statusCode {

                    if let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                       let row = arr.first {
                        DispatchQueue.main.async {
                            completion(.success(row))
                        }
                        return
                    }

                    fail("Unexpected response")
                    return
                }

                // username conflict → retry
                let text = String(data: data, encoding: .utf8) ?? "Error"

                if http.statusCode == 409 && maxRetries > 0 {

                    var retry = body

                    if isParticipant {
                        let first = (retry["first_name"] as? String) ?? "user"
                        let last = (retry["last_name"] as? String) ?? ""
                        retry["username"] = Self.generateParticipantUsername(first: first, last: last)
                    } else {
                        let org = (retry["org_name"] as? String) ?? "org"
                        retry["username"] = Self.generateOrgUsername(from: org)
                    }

                    self.insertProfile(
                        payload: retry,
                        table: table,
                        defaultRole: defaultRole,
                        isParticipant: isParticipant,
                        maxRetries: maxRetries - 1,
                        completion: completion
                    )
                    return
                }

                fail("Insert failed: \(text)")

            }.resume()
        }
    }

    // MARK: - Username Generators
    public static func generateOrgUsername(from org: String) -> String {

        var slug = org.lowercased()
            .replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)

        while slug.contains("--") { slug = slug.replacingOccurrences(of: "--", with: "-") }
        slug = slug.trimmingCharacters(in: CharacterSet(charactersIn: "-"))

        if slug.isEmpty { slug = "org" }

        return "org-\(slug)-\(randomHex(length: 6))"
    }

    public static func generateParticipantUsername(first: String, last: String) -> String {

        let f = first.lowercased().replacingOccurrences(of: " ", with: "-")
        let l = last.lowercased().replacingOccurrences(of: " ", with: "-")

        return "\(f)-\(l)-\(randomHex(length: 6))"
    }

    public static func randomHex(length: Int) -> String {
        var bytes = [UInt8](repeating: 0, count: (length + 1) / 2)
        SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        let hex = bytes.map { String(format: "%02x", $0) }.joined()
        let end = hex.index(hex.startIndex, offsetBy: length)
        return String(hex[..<end])
    }

    // MARK: - JWT Decode Helpers
    public static func extractUserId(fromAccessToken token: String) -> String? {
        decodeJWT(token)["sub"] as? String
    }

    public static func extractEmail(fromAccessToken token: String) -> String? {
        decodeJWT(token)["email"] as? String
    }

    private static func decodeJWT(_ token: String) -> [String: Any] {

        let parts = token.split(separator: ".")
        guard parts.count >= 2 else { return [:] }

        var payload = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        while payload.count % 4 != 0 { payload.append("=") }

        guard let data = Data(base64Encoded: payload),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return [:] }

        return json
    }

    // MARK: - Error Helpers
    private static func makeError(_ msg: String) -> NSError {
        NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: msg])
    }

    private static func errorFromResponse(_ data: Data?, status: Int) -> NSError {
        let text = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
        return NSError(domain: "AuthManager", code: status, userInfo: [NSLocalizedDescriptionKey: text])
    }
}
