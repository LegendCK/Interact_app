//
//  ParticipantProfileViewModel.swift
//  Interact_app
//
//  Created by admin56 on 17/01/26.
//

import Foundation

final class ParticipantProfileViewModel {

    // MARK: - State

    private let authManager: AuthManager
    private(set) var profile: ParticipantProfile?

    // MARK: - UI Bindings

    var onLoadingStateChange: ((Bool) -> Void)?
    var onProfileLoaded: (() -> Void)?
    var onError: ((String) -> Void)?

    // MARK: - Init

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    // MARK: - Public API

    func loadProfileIfNeeded() {
        guard profile == nil else { return }
        fetchProfile(forceRefresh: false) // Use cache if available
    }

    func refreshProfile() {
        fetchProfile(forceRefresh: true) // Force fresh data
    }

    // MARK: - Private

    private func fetchProfile(forceRefresh: Bool = false) {
        onLoadingStateChange?(true)

        authManager.fetchProfile(forceRefresh: forceRefresh) { [weak self] result in
            DispatchQueue.main.async {
                self?.onLoadingStateChange?(false)

                switch result {
                case .success(let json):
                    guard
                        let json,
                        let profile = ParticipantProfile.from(json: json)
                    else {
                        self?.onError?("Profile not found.")
                        return
                    }

                    self?.profile = profile
                    self?.onProfileLoaded?()

                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Update Profile
    func updateProfile(
        fields: [String: Any],
        completion: @escaping (Bool) -> Void
    ) {
        onLoadingStateChange?(true)
        
        authManager.updateProfile(fields: fields) { [weak self] result in
            DispatchQueue.main.async {
                self?.onLoadingStateChange?(false)
                
                switch result {
                case .success(let json):
                    if let updatedProfile = ParticipantProfile.from(json: json) {
                        self?.profile = updatedProfile
                        self?.onProfileLoaded?()
                        completion(true)
                    } else {
                        self?.onError?("Failed to parse updated profile")
                        completion(false)
                    }
                    
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                    completion(false)
                }
            }
        }
    }

    // MARK: - Upload Profile Photo
    func uploadProfilePhoto(
        imageData: Data,
        completion: @escaping (String?) -> Void
    ) {
        onLoadingStateChange?(true)
        
        authManager.uploadProfilePhoto(imageData: imageData) { [weak self] result in
            DispatchQueue.main.async {
                self?.onLoadingStateChange?(false)
                
                switch result {
                case .success(let url):
                    completion(url)
                    
                case .failure(let error):
                    self?.onError?("Photo upload failed: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }
    }
}
