import UIKit

// MARK: - Model

struct Skill: Hashable {
    let id: UUID
    let name: String
    let domain: String
}

// MARK: - Controller

final class EditSkillsModalTableViewController: UITableViewController {

    // MARK: - Reuse Identifiers

    private enum ReuseID {
        static let pinned = "PinnedSkillCell"
        static let available = "AvailableSkillCell"
    }

    // MARK: - State

    private var isEditingSkills = false
    private var pinnedSkills: [Skill] = []
    private var allSkillsByDomain: [String: [Skill]] = [:]
    private var searchText: String = ""

    private var domains: [String] {
        allSkillsByDomain.keys.sorted()
    }

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

        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: ReuseID.pinned)
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: ReuseID.available)

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
            dismiss(animated: true)
        }

        tableView.reloadData()
    }

    // MARK: - Table Structure

    override func numberOfSections(in tableView: UITableView) -> Int {
        return isEditingSkills ? (1 + domains.count) : 1
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {

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

    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return pinnedSkills.isEmpty ? nil : "Pinned"
        }
        return domains[section - 1]
    }

    // MARK: - Cells

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ReuseID.pinned,
                for: indexPath
            )
            resetCell(cell)
            configurePinnedCell(cell, indexPath: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ReuseID.available,
                for: indexPath
            )
            resetCell(cell)
            configureAvailableCell(cell, indexPath: indexPath)
            return cell
        }
    }

    private func resetCell(_ cell: UITableViewCell) {
        cell.textLabel?.text = nil
        cell.accessoryView = nil
        cell.showsReorderControl = false
        cell.selectionStyle = .none
    }

    private func configurePinnedCell(_ cell: UITableViewCell,
                                     indexPath: IndexPath) {

        let skill = pinnedSkills[indexPath.row]
        cell.textLabel?.text = skill.name

        guard isEditingSkills else { return }

        cell.showsReorderControl = true

        // ✅ FIX: Minus button for pinned skills
        let removeButton = UIButton(type: .system)
        removeButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        removeButton.tintColor = .systemRed
        removeButton.tag = indexPath.row
        removeButton.addTarget(self,
                               action: #selector(removeSkill(_:)),
                               for: .touchUpInside)

        cell.accessoryView = removeButton
    }

    private func configureAvailableCell(_ cell: UITableViewCell,
                                        indexPath: IndexPath) {

        let domain = domains[indexPath.section - 1]
        let skills = allSkillsByDomain[domain] ?? []

        let filtered = skills
            .filter { !pinnedSkills.contains($0) }
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }

        let skill = filtered[indexPath.row]
        cell.textLabel?.text = skill.name

        guard isEditingSkills else { return }

        // ✅ FIX: Plus button for available skills
        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addButton.tintColor = .systemGreen
        addButton.tag = skill.hashValue
        addButton.addTarget(self,
                            action: #selector(addSkill(_:)),
                            for: .touchUpInside)

        cell.accessoryView = addButton
    }

    // MARK: - CRITICAL FIX: UIKit Editing Control

    override func tableView(_ tableView: UITableView,
                            canEditRowAt indexPath: IndexPath) -> Bool {
        // ✅ ONLY pinned rows are editable
        return isEditingSkills && indexPath.section == 0
    }

    override func tableView(_ tableView: UITableView,
                            editingStyleForRowAt indexPath: IndexPath)
    -> UITableViewCell.EditingStyle {
        // ✅ Prevent UIKit minus button in other sections
        return indexPath.section == 0 ? .none : .none
    }

    // MARK: - Actions

    @objc private func addSkill(_ sender: UIButton) {
        guard isEditingSkills else { return }

        for domain in domains {
            if let skill = allSkillsByDomain[domain]?.first(where: {
                $0.hashValue == sender.tag
            }) {
                pinnedSkills.append(skill)
                break
            }
        }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        tableView.reloadData()
    }

    @objc private func removeSkill(_ sender: UIButton) {
        let index = sender.tag
        guard pinnedSkills.indices.contains(index) else { return }

        pinnedSkills.remove(at: index)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        tableView.reloadData()
    }

    // MARK: - Reordering (Pinned only)

    override func tableView(_ tableView: UITableView,
                            canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }

    override func tableView(_ tableView: UITableView,
                            moveRowAt sourceIndexPath: IndexPath,
                            to destinationIndexPath: IndexPath) {

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

        pinnedSkills = [
            allSkillsByDomain["Mobile Development"]![0],
            allSkillsByDomain["Frontend Development"]![0]
        ]
    }
}

// MARK: - Search

extension EditSkillsModalTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        tableView.reloadData()
    }
}
