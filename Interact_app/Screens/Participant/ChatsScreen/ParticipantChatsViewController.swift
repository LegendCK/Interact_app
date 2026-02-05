import UIKit

final class ParticipantChatsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var chats: [ChatItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupTableView()
        loadDummyData()
    }

    private func setupNavigation() {
        title = "Messages"
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Requests",
            style: .plain,
            target: self,
            action: #selector(didTapRequests)
        )
    }

    private func setupTableView() {
        tableView.register(
            UINib(nibName: InboxChatCell.nibName, bundle: nil),
            forCellReuseIdentifier: InboxChatCell.identifier
        )

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }

    private func loadDummyData() {
        chats = ChatItem.dummyData()
        tableView.reloadData()
    }

    @objc private func didTapRequests() {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = "Message Requests"
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ParticipantChatsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chats.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: InboxChatCell.identifier,
            for: indexPath
        ) as? InboxChatCell else {
            return UITableViewCell()
        }

        cell.configure(with: chats[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ParticipantChatsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let chat = chats[indexPath.row]

        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = chat.name
        navigationController?.pushViewController(vc, animated: true)
    }
}
