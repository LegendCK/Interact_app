//
//  TeamInfoModal.swift
//  Interact_app
//
//  Created by admin73 on 25/01/26.
//

import UIKit

class TeamInfoModal: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var myTeamName: UILabel!
    
    // MARK: - Properties
        var teamID: UUID!
        var teamName: String = "" // Passed from previous screen
        
        private var members: [TeamMemberDisplay] = []
        private let activityIndicator = UIActivityIndicatorView(style: .large)

        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupNavigation() // Call your new navigation setup
            setupUI()
            setupTableView()
            fetchMembers()
        }
        
        // MARK: - Navigation (Your Code)
        private func setupNavigation() {
            title = "Team Details"
            navigationItem.hidesBackButton = true
            
            // Add "Done" button to close the modal
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Done",
                style: .done,
                target: self,
                action: #selector(didTapDismiss)
            )
        }
        
        @objc private func didTapDismiss() {
            dismiss(animated: true)
        }
        
        // MARK: - UI Setup
        private func setupUI() {
            view.backgroundColor = .systemGroupedBackground
            
            // Setup Loader
            view.addSubview(activityIndicator)
            activityIndicator.center = view.center
            activityIndicator.hidesWhenStopped = true
            
            myTeamName.text = teamName
    
        }
        
        private func setupTableView() {
            tableView.dataSource = self
            tableView.delegate = self
            
            // Register the NIB for your custom cell
            let nib = UINib(nibName: "TeamMembersCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "TeamMembersCell")
            
            // Table styling
            tableView.backgroundColor = .clear
            tableView.separatorStyle = .singleLine
            tableView.rowHeight = 66
            
            // Fix for extra top padding in grouped tables
            tableView.sectionHeaderTopPadding = 0
            
            tableView.backgroundColor = .clear
            tableView.isScrollEnabled = false


        }
        
        // MARK: - Data Fetching
        private func fetchMembers() {
            guard let teamID = teamID else { return }
            
            activityIndicator.startAnimating()
            
            Task {
                do {
                    let allMembers = try await TeamService.shared.fetchTeamMembers(for: teamID)
                    
                    // Filter: Show only accepted members
                    self.members = allMembers.filter { $0.status == "accepted" }
                    
                    // Sort: Leader first, then alphabetically
                    self.members.sort {
                        if $0.role == "leader" { return true }
                        if $1.role == "leader" { return false }
                        return $0.fullName < $1.fullName
                    }
                    
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.tableView.reloadData()
                    }
                } catch {
                    print("Error loading members: \(error)")
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }

        // MARK: - TableView Data Source
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return members.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TeamMembersCell", for: indexPath) as? TeamMembersCell else {
                return UITableViewCell()
            }
            
            let member = members[indexPath.row]
            cell.configure(with: member)
            cell.selectionStyle = .none
            return cell
        }
        
//        // MARK: - Section Header (Team Name)
//        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//            return teamName.isEmpty ? "Team Members" : teamName
//        }
        
        // Make the header larger/bolder
//        func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//            if let header = view as? UITableViewHeaderFooterView {
//                header.textLabel?.font = .systemFont(ofSize: 22, weight: .semibold)
//                header.textLabel?.textColor = .label
//                // Capitalize the team name slightly for better look
////                header.textLabel?.text = header.textLabel?.text?.capitalized
//            }
//        }
        
        // Add height for header so it's not cramped
//        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//            return 30
//        }

}
