import UIKit

final class ParticipantProfileViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var rankingsView: UIView!
    @IBOutlet weak var innerRankingsView: UIView!
    @IBOutlet weak var totalPointsView: UIView!
    @IBOutlet weak var totalWinsView: UIView!
    @IBOutlet weak var recentEventsView: UIView!
    @IBOutlet weak var skillsView: UIView!
    @IBOutlet weak var editProfileButton: ButtonComponent!
    @IBOutlet weak var editSkillsButton: UIButton!
    @IBOutlet weak var editAboutButton: UIButton!
    @IBOutlet weak var viewLeaderboardContainer: UIView!
    @IBOutlet weak var qrCodeButton: UIButton!
    @IBOutlet weak var skillsCollectionView: UICollectionView!
    
    // Profile content
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var educationLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var participantProfileImage: UIImageView!
    @IBOutlet weak var participantProfileImageContainer: UIView!
    
    // MARK: - Dependencies
    var viewModel: ParticipantProfileViewModel!

    // MARK: - Internal State
    private var fullAboutText: String = ""
    private var isAboutExpanded = false
    private let aboutTruncateLimit = 150

    // MARK: - Skills State
    private var displayedSkills: [String] = []
    private let maxVisibleSkills = 5
    private var emptySkillsLabel: UILabel!

    // MARK: - Styling
    private var aboutBaseAttributes: [NSAttributedString.Key: Any] {
        [
            .font: UIFont.systemFont(ofSize: 15, weight: .regular),
            .foregroundColor: UIColor(
                red: 142/255,
                green: 142/255,
                blue: 147/255,
                alpha: 1
            )
        ]
    }

    // MARK: - Lifecycle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update corner radius after layout is finalized
        participantProfileImageContainer.layer.cornerRadius = participantProfileImageContainer.bounds.width / 2
        participantProfileImage.layer.cornerRadius = participantProfileImage.bounds.width / 2
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(viewModel != nil, "ParticipantProfileViewModel must be injected before use")

        setupUI()
        bindViewModel()
        viewModel.loadProfileIfNeeded()
        
        editProfileButton.onTap = { [weak self] in
            guard let self else { return }

            let editProfileVC = EditParticipantProfileModalViewController(
                nibName: "EditParticipantProfileModalViewController",
                bundle: nil
            )
            
            // Pass profile data and viewModel
            editProfileVC.profile = self.viewModel.profile
            editProfileVC.viewModel = self.viewModel
            editProfileVC.onSave = { [weak self] in
                // Profile already updated in viewModel, UI will refresh via binding
            }

            let navController = UINavigationController(rootViewController: editProfileVC)
            navController.modalPresentationStyle = .pageSheet

            if let sheet = navController.sheetPresentationController {
                sheet.detents = [
                    .medium(),
                    .large()
                ]

                sheet.selectedDetentIdentifier = .large
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            }

            present(navController, animated: true)
        }
    }

    // MARK: - UI Setup
    private func setupUI() {

        editProfileButton.configure(title: "Edit Profile")

        viewLeaderboardContainer.layer.cornerRadius = 10
        viewLeaderboardContainer.layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        viewLeaderboardContainer.layer.masksToBounds = true

        [aboutView, rankingsView, innerRankingsView, skillsView, recentEventsView].forEach {
            $0?.layer.borderWidth = 1
            $0?.layer.cornerRadius = 10
            $0?.layer.borderColor = UIColor.systemGray4.cgColor
        }

        totalPointsView.layer.cornerRadius = 10
        totalWinsView.layer.cornerRadius = 10

        //Make profile image container and image circular
        participantProfileImageContainer.layer.cornerRadius = participantProfileImageContainer.bounds.width / 2
        participantProfileImageContainer.clipsToBounds = true
        
        participantProfileImage.layer.cornerRadius = participantProfileImage.bounds.width / 2
        participantProfileImage.clipsToBounds = true
        participantProfileImage.contentMode = .scaleAspectFill
        
        // Add a subtle border (optional)
        participantProfileImageContainer.layer.borderWidth = 2
        participantProfileImageContainer.layer.borderColor = UIColor.systemGray5.cgColor

        // Placeholders
        nameLabel.text = "—"
        educationLabel.text = "—"
        locationLabel.text = "—"

        // About TextView setup
        aboutTextView.delegate = self
        aboutTextView.isEditable = false
        aboutTextView.isScrollEnabled = false
        aboutTextView.isSelectable = true
        aboutTextView.backgroundColor = .clear
        aboutTextView.textContainerInset = .zero
        aboutTextView.textContainer.lineFragmentPadding = 0
        aboutTextView.textAlignment = .justified

        editAboutButton.addTarget(self, action: #selector(editAboutTapped), for: .touchUpInside)
        
        //Configure Skills Collection View from XIB
        setupSkillsCollectionView()
    }
    
    // MARK: - Skills Collection View Setup
    private func setupSkillsCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        
        skillsCollectionView.collectionViewLayout = layout
        skillsCollectionView.backgroundColor = .clear
        skillsCollectionView.showsHorizontalScrollIndicator = false
        skillsCollectionView.isScrollEnabled = false
        skillsCollectionView.delegate = self
        skillsCollectionView.dataSource = self
        
        skillsCollectionView.register(SkillPillCell.self,
                                       forCellWithReuseIdentifier: SkillPillCell.reuseIdentifier)
        
        //Setup empty state label
        emptySkillsLabel = UILabel()
        emptySkillsLabel.text = "No skills added yet"
        emptySkillsLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        emptySkillsLabel.textColor = UIColor(
            red: 142/255,
            green: 142/255,
            blue: 147/255,
            alpha: 1
        )
        emptySkillsLabel.textAlignment = .center
        emptySkillsLabel.translatesAutoresizingMaskIntoConstraints = false
        emptySkillsLabel.isHidden = true
        
        skillsView.addSubview(emptySkillsLabel)
        
        NSLayoutConstraint.activate([
            emptySkillsLabel.leadingAnchor.constraint(equalTo: skillsView.leadingAnchor, constant: 16),
            emptySkillsLabel.trailingAnchor.constraint(equalTo: skillsView.trailingAnchor, constant: -16),
            emptySkillsLabel.centerYAnchor.constraint(equalTo: skillsView.centerYAnchor)
        ])
    }
    
    // MARK: - ViewModel Binding
    private func bindViewModel() {

        viewModel.onLoadingStateChange = { [weak self] isLoading in
            self?.view.isUserInteractionEnabled = !isLoading
        }

        viewModel.onProfileLoaded = { [weak self] in
            self?.updateUI()
        }

        viewModel.onError = { message in
            print("Profile error:", message)
        }
    }

    // MARK: - UI Update
    private func updateUI() {
        guard let profile = viewModel.profile else { return }

        nameLabel.text = profile.displayName
        fullAboutText = profile.bio ?? ""
        isAboutExpanded = false
        updateAboutText()

        educationLabel.text = profile.displayEducation
        locationLabel.text = profile.location ?? "—"
        
        // Load profile image
        loadProfileImage(from: profile.avatarUrl)
        
        //Update skills display
        updateSkillsDisplay()
    }

    // MARK: - Load Profile Image
    private func loadProfileImage(from urlString: String?) {
        // Set default placeholder
        participantProfileImage.image = UIImage(systemName: "person.circle.fill")
        participantProfileImage.tintColor = .systemGray3
        
        guard let urlString = urlString,
              !urlString.isEmpty,
              let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data,
                  let image = UIImage(data: data),
                  error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self?.participantProfileImage.image = image
                self?.participantProfileImage.contentMode = .scaleAspectFill
            }
        }.resume()
    }
    
    // MARK: - Update Skills Display
    private func updateSkillsDisplay() {
        guard let profile = viewModel.profile else { return }
        
        let skills = profile.skills
        
        if skills.isEmpty {
            //Show empty state
            displayedSkills = []
            emptySkillsLabel.isHidden = false
            skillsCollectionView.isHidden = true
        } else {
            //Show skills
            emptySkillsLabel.isHidden = true
            skillsCollectionView.isHidden = false
            
            if skills.count > maxVisibleSkills {
                displayedSkills = Array(skills.prefix(maxVisibleSkills))
                let remaining = skills.count - maxVisibleSkills
                displayedSkills.append("+\(remaining)")
            } else {
                displayedSkills = skills
            }
        }
        
        skillsCollectionView.reloadData()
    }

    // MARK: - About Text Logic
    private func updateAboutText() {

        let attributedText = NSMutableAttributedString(
            string: "",
            attributes: aboutBaseAttributes
        )

        guard !fullAboutText.isEmpty else {
            aboutTextView.attributedText = NSAttributedString(
                string: "—",
                attributes: aboutBaseAttributes
            )
            return
        }

        if !isAboutExpanded && fullAboutText.count > aboutTruncateLimit {
            let truncated = String(fullAboutText.prefix(aboutTruncateLimit)) + "… "

            attributedText.append(
                NSAttributedString(
                    string: truncated,
                    attributes: aboutBaseAttributes
                )
            )

            let readMore = NSAttributedString(
                string: "Read more",
                attributes: [
                    .link: URL(string: "toggleabout://")!,
                    .foregroundColor: UIColor.systemBlue,
                ]
            )
            attributedText.append(readMore)

        } else {
            attributedText.append(
                NSAttributedString(
                    string: fullAboutText + " ",
                    attributes: aboutBaseAttributes
                )
            )

            if fullAboutText.count > aboutTruncateLimit {
                let readLess = NSAttributedString(
                    string: "Read less",
                    attributes: [
                        .link: URL(string: "toggleabout://")!,
                        .foregroundColor: UIColor.systemBlue,
                    ]
                )
                attributedText.append(readLess)
            }
        }

        aboutTextView.attributedText = attributedText
        aboutTextView.invalidateIntrinsicContentSize()
    }

    // MARK: - Actions
    @IBAction func editSkillsTapped(_ sender: UIButton) {
        presentEditSkillsModal()
    }

    @IBAction func shareQR(_ sender: UIButton) {
        let vc = ParticipantQRViewController(
            nibName: "ParticipantQRViewController",
            bundle: nil
        )
        vc.title = "QR Code"
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func editAboutTapped() {
        let editVC = EditParticipantAboutViewController(
            nibName: "EditParticipantAboutViewController",
            bundle: nil
        )
        editVC.originalText = fullAboutText

        editVC.onSave = { [weak self] updatedText in
            guard let self = self else { return }
            
            // Update locally
            self.fullAboutText = updatedText
            self.isAboutExpanded = false
            self.updateAboutText()
            
            // Save to Supabase
            self.viewModel.updateProfile(fields: ["about": updatedText]) { success in
                if !success {
                    print("Failed to save bio to Supabase")
                }
            }
        }

        let navController = UINavigationController(rootViewController: editVC)
        navController.modalPresentationStyle = .pageSheet

        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

        present(navController, animated: true)
    }

    // MARK: - Modal Presentation
    private func presentEditSkillsModal() {
        let skillsVC = EditSkillsModalTableViewController()
        
        // Pass current skills
        if let currentSkills = viewModel.profile?.skills {
            skillsVC.initialSkills = currentSkills
        }
        
        // Callback to receive updated skills
        skillsVC.onSkillsUpdated = { [weak self] updatedSkillNames in
            guard let self = self else { return }
            
            // Save to Supabase
            self.viewModel.updateProfile(fields: ["skills": updatedSkillNames]) { success in
                if success {
                    print("Skills updated successfully")
                } else {
                    print("Failed to save skills to Supabase")
                }
            }
        }
        
        let navController = UINavigationController(rootViewController: skillsVC)
        navController.modalPresentationStyle = .pageSheet
        
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(navController, animated: true)
    }
}

// MARK: - UITextViewDelegate
extension ParticipantProfileViewController: UITextViewDelegate {

    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {

        if URL.scheme == "toggleabout" {
            isAboutExpanded.toggle()
            updateAboutText()
            return false
        }
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension ParticipantProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                       numberOfItemsInSection section: Int) -> Int {
        return displayedSkills.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SkillPillCell.reuseIdentifier,
            for: indexPath
        ) as! SkillPillCell
        
        cell.configure(with: displayedSkills[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ParticipantProfileViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                       didSelectItemAt indexPath: IndexPath) {
        // Tap any pill to open edit modal
        presentEditSkillsModal()
    }
}
