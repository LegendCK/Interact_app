import UIKit

final class AvailableSkillCell: UITableViewCell {
    
    static let reuseIdentifier = "AvailableSkillCell"
    
    var onAdd: (() -> Void)?
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .systemGreen
        
        //FIX: Set explicit frame size
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
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
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    func configure(with skillName: String, isEditing: Bool) {
        textLabel?.text = skillName
        
        if isEditing {
            accessoryView = addButton
        } else {
            accessoryView = nil
        }
    }
    
    @objc private func addButtonTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onAdd?()
    }
}
