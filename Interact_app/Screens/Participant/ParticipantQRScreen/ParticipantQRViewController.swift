import UIKit

class ParticipantQRViewController: UIViewController {

    @IBOutlet weak var outerContainter: UIView!
    @IBOutlet weak var profileImageContainer: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var qrCode: UIImageView!
    @IBOutlet weak var shareMyQRButton: UIButton!

    private var qrToken: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadQR()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Make profile image circular
        profileImageContainer.layer.cornerRadius = profileImageContainer.bounds.width / 2
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
    }

    // MARK: - Setup UI
    private func setupUI() {
        outerContainter.layer.cornerRadius = 10
        outerContainter.layer.borderWidth = 1
        outerContainter.layer.borderColor = UIColor.systemGray4.cgColor
        
        // Setup profile image container
        profileImageContainer.clipsToBounds = true
        profileImageContainer.layer.borderWidth = 2
        profileImageContainer.layer.borderColor = UIColor.systemGray5.cgColor
        
        // Setup profile image
        profileImage.clipsToBounds = true
        profileImage.contentMode = .scaleAspectFill
        profileImage.image = UIImage(systemName: "person.circle.fill") // Placeholder
        profileImage.tintColor = .systemGray3
        
        // Placeholder for name
        nameLabel.text = "—"
    }

    // MARK: - Load QR
    private func loadQR() {
        // Try to get cached profile first
        if let cachedProfile = ProfileCache.getProfile() {
            loadProfileData(from: cachedProfile)
            return
        }

        // Fetch from server if no cache
        guard
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
            let authManager = sceneDelegate.authManager
        else { return }

        authManager.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    guard let profile else { return }
                    self?.loadProfileData(from: profile)

                case .failure(let error):
                    print("QR profile fetch failed:", error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Load Profile Data
    private func loadProfileData(from profile: [String: Any]) {
        // Load QR token
        if let token = profile["qr_public_token"] as? String {
            ProfileCache.saveQRToken(token)
            self.qrToken = token
            renderQR(token: token)
        }
        
        // Load name
        let firstName = profile["first_name"] as? String ?? ""
        let lastName = profile["last_name"] as? String ?? ""
        
        if !firstName.isEmpty || !lastName.isEmpty {
            nameLabel.text = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        } else {
            nameLabel.text = "Participant"
        }
        
        // Load profile image
        if let avatarUrl = profile["avatar_url"] as? String {
            loadProfileImage(from: avatarUrl)
        }
    }
    
    // MARK: - Load Profile Image
    private func loadProfileImage(from urlString: String) {
        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data,
                  let image = UIImage(data: data),
                  error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self?.profileImage.image = image
            }
        }.resume()
    }

    // MARK: - Render QR
    private func renderQR(token: String) {
        let deepLink = "https://interact.app/profile/\(token)"
        qrCode.image = QRCodeGenerator.generate(from: deepLink)
    }

    // MARK: - Share
    @IBAction func shareQR(_ sender: UIButton) {
        guard let image = qrCode.image else { return }

        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(activityVC, animated: true)
    }
}
