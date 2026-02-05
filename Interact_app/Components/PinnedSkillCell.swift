import UIKit

final class PinnedSkillCell: UITableViewCell {

    static let reuseIdentifier = "PinnedSkillCell"

    var onRemove: (() -> Void)?

    private let removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none

        contentView.addSubview(removeButton)

        NSLayoutConstraint.activate([
            removeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            removeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            removeButton.widthAnchor.constraint(equalToConstant: 24),
            removeButton.heightAnchor.constraint(equalToConstant: 24)
        ])

        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
    }

    func configure(with skillName: String, isEditing: Bool) {
        textLabel?.text = skillName

        removeButton.isHidden = !isEditing
        showsReorderControl = isEditing
    }

    @objc private func removeButtonTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onRemove?()
    }
}
