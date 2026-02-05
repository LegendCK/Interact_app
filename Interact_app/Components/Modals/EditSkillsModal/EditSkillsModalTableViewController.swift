import UIKit

// MARK: - Model

struct Skill: Hashable {
    let id: UUID
    let name: String
    let domain: String
}

// MARK: - Controller

final class EditSkillsModalTableViewController: UITableViewController {

    // MARK: - State

    private var isEditingSkills = false
    private var pinnedSkills: [Skill] = []
    private var allSkillsByDomain: [String: [Skill]] = [:]
    private var searchText: String = ""

    private var domains: [String] {
        allSkillsByDomain.keys.sorted()
    }
    
    // MARK: - Callbacks & Initial Data
    var initialSkills: [String] = []
    var onSkillsUpdated: (([String]) -> Void)?

    // MARK: - Search

    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search skills"
        return sc
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Skills"

        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.allowsSelection = false

        tableView.register(
            PinnedSkillCell.self,
            forCellReuseIdentifier: PinnedSkillCell.reuseIdentifier
        )
        tableView.register(
            AvailableSkillCell.self,
            forCellReuseIdentifier: AvailableSkillCell.reuseIdentifier
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editTapped)
        )

        definesPresentationContext = true
        loadSkills()
    }

    // MARK: - Edit / Done

    @objc private func editTapped() {
        isEditingSkills.toggle()
        tableView.setEditing(isEditingSkills, animated: true)

        navigationItem.rightBarButtonItem?.title = isEditingSkills ? "Done" : "Edit"

        if isEditingSkills {
            navigationItem.searchController = searchController
        } else {
            navigationItem.searchController = nil
            
            let updatedSkillNames = pinnedSkills.map { $0.name }
            onSkillsUpdated?(updatedSkillNames)
            dismiss(animated: true)
        }

        tableView.reloadData()
    }

    // MARK: - Table Structure

    override func numberOfSections(in tableView: UITableView) -> Int {
        isEditingSkills ? (1 + domains.count) : 1
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        if section == 0 {
            return pinnedSkills.count
        }

        let domain = domains[section - 1]
        let skills = allSkillsByDomain[domain] ?? []

        return skills
            .filter { !pinnedSkills.contains($0) }
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
            .count
    }

    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        if section == 0 {
            return pinnedSkills.isEmpty ? nil : "Pinned"
        }
        return domains[section - 1]
    }

    // MARK: - Cells

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PinnedSkillCell.reuseIdentifier,
                for: indexPath
            ) as! PinnedSkillCell
            
            let skill = pinnedSkills[indexPath.row]
            cell.configure(with: skill.name, isEditing: isEditingSkills)
            
            cell.onRemove = { [weak self] in
                self?.removeSkill(at: indexPath.row)
            }
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: AvailableSkillCell.reuseIdentifier,
                for: indexPath
            ) as! AvailableSkillCell
            
            let domain = domains[indexPath.section - 1]
            let skills = allSkillsByDomain[domain] ?? []
            
            let filtered = skills
                .filter { !pinnedSkills.contains($0) }
                .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
            
            let skill = filtered[indexPath.row]
            cell.configure(with: skill.name, isEditing: isEditingSkills)
            
            cell.onAdd = { [weak self] in
                self?.addSkill(skill)
            }
            
            return cell
        }
    }

    // MARK: - Editing Controls

    override func tableView(
        _ tableView: UITableView,
        canEditRowAt indexPath: IndexPath
    ) -> Bool {
        isEditingSkills && indexPath.section == 0
    }

    override func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
        .none
    }

    // MARK: - Actions

    private func addSkill(_ skill: Skill) {
        guard isEditingSkills else { return }
        pinnedSkills.append(skill)
        tableView.reloadData()
    }

    private func removeSkill(at index: Int) {
        guard isEditingSkills, pinnedSkills.indices.contains(index) else { return }
        pinnedSkills.remove(at: index)
        tableView.reloadData()
    }

    // MARK: - Reordering (Pinned only)

    override func tableView(
        _ tableView: UITableView,
        canMoveRowAt indexPath: IndexPath
    ) -> Bool {
        indexPath.section == 0
    }

    override func tableView(
        _ tableView: UITableView,
        targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
        toProposedIndexPath proposedDestinationIndexPath: IndexPath
    ) -> IndexPath {

        if proposedDestinationIndexPath.section != 0 {
            return IndexPath(row: pinnedSkills.count - 1, section: 0)
        }
        return proposedDestinationIndexPath
    }

    override func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        guard sourceIndexPath.section == 0,
              destinationIndexPath.section == 0 else { return }

        let skill = pinnedSkills.remove(at: sourceIndexPath.row)
        pinnedSkills.insert(skill, at: destinationIndexPath.row)
    }

    // MARK: - Skills Data

    private func loadSkills() {

        func skills(_ names: [String], domain: String) -> [Skill] {
            names.map { Skill(id: UUID(), name: $0, domain: domain) }
        }

        allSkillsByDomain = [
            "Frontend Development": skills([
                "React", "Vue.js", "Angular", "Svelte", "Next.js",
                "TypeScript", "JavaScript", "HTML/CSS",
                "Tailwind CSS", "Bootstrap", "Material UI",
                "Redux", "Webpack", "Vite"
            ], domain: "Frontend Development"),

            "Backend Development": skills([
                "Node.js", "Express.js", "Python", "Django", "Flask",
                "FastAPI", "Java", "Spring Boot", "PHP", "Laravel",
                "Ruby on Rails", "Go", "Rust", "C#", ".NET Core"
            ], domain: "Backend Development"),

            "Mobile Development": skills([
                "Swift", "SwiftUI", "UIKit", "Kotlin",
                "Jetpack Compose", "React Native", "Flutter"
            ], domain: "Mobile Development")
        ]

        pinnedSkills = initialSkills.isEmpty
            ? []
            : convertToSkills(initialSkills)
    }

    private func convertToSkills(_ skillNames: [String]) -> [Skill] {
        var result: [Skill] = []

        for name in skillNames {
            for (_, skills) in allSkillsByDomain {
                if let match = skills.first(where: { $0.name == name }) {
                    result.append(match)
                    break
                }
            }
        }
        return result
    }
}

// MARK: - Search

extension EditSkillsModalTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        tableView.reloadData()
    }
}
