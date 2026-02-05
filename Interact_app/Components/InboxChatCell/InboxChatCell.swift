import UIKit

class InboxChatCell: UITableViewCell {

    @IBOutlet weak var avatarContainerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!

    @IBOutlet weak var unreadBadgeView: UIView!
    @IBOutlet weak var unreadCountLabel: UILabel!

    static let identifier = "InboxChatCell"
    static let nibName = "InboxChatCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {

        avatarContainerView.layer.cornerRadius = 25
        avatarContainerView.backgroundColor = .systemGray5
        avatarContainerView.clipsToBounds = true

        avatarImageView.layer.cornerRadius = 25
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill

        unreadBadgeView.layer.cornerRadius = 12
        unreadBadgeView.backgroundColor = .systemRed
        unreadBadgeView.clipsToBounds = true

        unreadCountLabel.textColor = .white
        unreadCountLabel.font = .systemFont(ofSize: 12, weight: .bold)
        unreadCountLabel.textAlignment = .center

        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        lastMessageLabel.font = .systemFont(ofSize: 14)
        lastMessageLabel.textColor = .secondaryLabel

        timestampLabel.font = .systemFont(ofSize: 12)
        timestampLabel.textColor = .secondaryLabel
    }

    func configure(with chat: ChatItem) {

        nameLabel.text = chat.name
        lastMessageLabel.text = chat.lastMessage
        timestampLabel.text = chat.timeString

        avatarImageView.image = UIImage(
            systemName: chat.isGroup ? "person.3.fill" : "person.circle.fill"
        )
        avatarImageView.tintColor = .systemGray3

        if chat.unreadCount > 0 {
            unreadBadgeView.isHidden = false
            unreadCountLabel.text = "\(chat.unreadCount)"
        } else {
            unreadBadgeView.isHidden = true
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        unreadBadgeView.isHidden = true
    }
}
