//
//  ConnectionsViewController.swift
//  Interact_app
//
//  Created by admin73 on 13/01/26.
//

import UIKit

class ConnectionsViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    

    // MARK: - Properties
        // "allItems" holds the master list from DB
        private var allItems: [ProfileDisplayModel] = []
        
        // "filteredItems" is what is actually displayed (affected by search)
        private var filteredItems: [ProfileDisplayModel] = []
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupCollectionView()
            setupSearchBar()
            loadData()
        }
        
        // MARK: - UI Setup
    private func setupCollectionView() {
            // 1. Register Nib
            let nib = UINib(nibName: "ProfilesCollectionViewCell", bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: "ProfilesCollectionViewCell")
            
            // 2. Delegates
            collectionView.delegate = self
            collectionView.dataSource = self
            
            // 3. List Layout (One below the other)
            let layout = UICollectionViewFlowLayout()
            let padding: CGFloat = 16
            
            // CHANGE: Width is now full screen width minus left/right padding
            let itemWidth = view.frame.width - padding
            
            layout.itemSize = CGSize(width: itemWidth, height: 90) // Reduced height looks better for lists
            layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
            layout.minimumLineSpacing = padding // Space between items vertically
            
            collectionView.collectionViewLayout = layout
        }
        
        private func setupSearchBar() {
            searchBar.delegate = self
//            searchBar.placeholder = "Search by name..."
            // Dismiss keyboard on scroll
            collectionView.keyboardDismissMode = .onDrag
        }
        
        // MARK: - Data Loading
        private func loadData() {
            Task {
                do {
                    // 1. Fetch Profiles
                    async let profilesTask = ProfileService.shared.fetchProfilesLite()
                    
                    // 2. Fetch ALL connections (Pending, Accepted, etc.)
                    // We pass 'nil' here explicitly to get everything
                    async let connectionsTask = ConnectionService.shared.fetchMyConnections(status: nil)
                    
                    let (profiles, connections) = try await (profilesTask, connectionsTask)
                    
                    // 3. Merge Logic
                    self.allItems = profiles.map { profile in
                        
                        // Find if there is ANY connection object for this user
                        let connection = connections.first(where: {
                            $0.senderId == profile.id || $0.receiverId == profile.id
                        })
                        
                        // If connection exists, this passes its status (e.g. "pending")
                        // If connection is nil, this passes nil (which makes the button "Connect")
                        return ProfileDisplayModel(profile: profile, connectionStatus: connection?.status)
                    }
                    
                    // 4. Update UI
                    self.filteredItems = self.allItems
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    
                } catch {
                    print("Failed to load data: \(error)")
                }
            }
        }
        
        // MARK: - Actions
    private func handleConnectTap(for index: Int) {
            let item = filteredItems[index]
            let indexPath = IndexPath(item: index, section: 0)
            
            // 1. Optimistic Update: Set to Pending immediately
            var updatedItem = item
            updatedItem.connectionStatus = "pending"
            filteredItems[index] = updatedItem
            collectionView.reloadItems(at: [indexPath])
            
            // 2. Send API Request
            Task {
                do {
                    try await ConnectionService.shared.sendConnectionRequest(to: item.profile.id)
                    print("Request Sent Successfully")
                } catch let error as NSError {
                    // MARK: - Handle 409 (Already Exists)
                    if error.code == 409 {
                        print("⚠️ Request already exists (409). Keeping UI as Pending.")
                        // Do NOT revert the UI.
                        // The user wanted it to be pending, and the server says it IS pending.
                        // So we do nothing here, letting the UI stay as "Pending".
                    } else {
                        // MARK: - Handle Real Errors
                        print("Request Failed: \(error)")
                        
                        // Revert UI only for actual failures (e.g., Network offline)
                        DispatchQueue.main.async {
                            self.filteredItems[index] = item // Revert to original state
                            self.collectionView.reloadItems(at: [indexPath])
                            
                            let alert = UIAlertController(title: "Error", message: "Could not send request.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        }
}

// MARK: - Collection View Delegate & DataSource
extension ConnectionsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfilesCollectionViewCell", for: indexPath) as? ProfilesCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let model = filteredItems[indexPath.item]
        
        // Configure cell UI
        cell.configure(with: model)
        
        // Handle Button Tap
        // [weak self] prevents memory leaks
        cell.onConnectTapped = { [weak self] in
            self?.handleConnectTap(for: indexPath.item)
        }
        
        return cell
    }
}

// MARK: - Search Bar Delegate
extension ConnectionsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredItems = allItems
        } else {
            filteredItems = allItems.filter { item in
                return item.profile.fullName.lowercased().contains(searchText.lowercased())
            }
        }
        collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
