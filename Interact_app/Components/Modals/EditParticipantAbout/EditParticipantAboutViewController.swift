//
//  EditParticipantAboutViewController.swift
//  Interact_app
//
//  Created by admin56 on 18/01/26.
//

import UIKit

final class EditParticipantAboutViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var editAboutTextView: UITextView!
    @IBOutlet weak var characterCounterLabel: UILabel!
    
    // MARK: - Properties
    var originalText: String = "" // Set by profile screen
    private let maxCharacters = 300
    
    // Callback to pass updated text back
    var onSave: ((String) -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTextView()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        title = "About"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func setupTextView() {
        editAboutTextView.delegate = self
        editAboutTextView.text = originalText
        characterCounterLabel.text = "\(originalText.count) / \(maxCharacters)"
        editAboutTextView.becomeFirstResponder()
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        if editAboutTextView.text != originalText {
            let alert = UIAlertController(title: "Discard Changes?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { _ in
                self.dismiss(animated: true)
            }))
            present(alert, animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func saveTapped() {
        onSave?(editAboutTextView.text)
        dismiss(animated: true)
    }
}

// MARK: - UITextViewDelegate
extension EditParticipantAboutViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // Enforce max characters
        if textView.text.count > maxCharacters {
            textView.text = String(textView.text.prefix(maxCharacters))
        }
        // Update counter
        characterCounterLabel.text = "\(textView.text.count) / \(maxCharacters)"
        // Enable save if changed
        navigationItem.rightBarButtonItem?.isEnabled = (textView.text != originalText)
    }
}
