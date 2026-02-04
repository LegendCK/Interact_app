import UIKit

class RoleShperesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var roleContainer: UIView!
    @IBOutlet weak var roleImage: UIImageView!
    @IBOutlet weak var roleName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        roleContainer.layer.cornerRadius = roleContainer.bounds.width / 2
    }

    private func setupUI() {

        // Circle style
        roleContainer.backgroundColor = .clear
        roleContainer.layer.borderWidth = 1
        roleContainer.layer.borderColor = UIColor.systemGray4.cgColor
        roleContainer.clipsToBounds = true

        // IMAGE VIEW FIX (THIS IS THE KEY)
        roleImage.contentMode = .scaleAspectFit
        roleImage.tintColor = .label

        // Label
        roleName.textColor = .label
        roleName.textAlignment = .center
    }

    func configure(role: String, icon: UIImage?) {
        roleName.text = role

        // Force SF Symbol sizing to behave
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        roleImage.image = icon?
            .withConfiguration(config)
            .withRenderingMode(.alwaysTemplate)
    }

    override var isSelected: Bool {
        didSet { updateSelectionState() }
    }

    private func updateSelectionState() {
        if isSelected {
            roleContainer.backgroundColor = .systemBlue
            roleContainer.layer.borderColor = UIColor.systemBlue.cgColor
            roleImage.tintColor = .white
            roleName.textColor = .systemBlue
        } else {
            roleContainer.backgroundColor = .clear
            roleContainer.layer.borderColor = UIColor.systemGray4.cgColor
            roleImage.tintColor = .label
            roleName.textColor = .label
        }
    }
}
