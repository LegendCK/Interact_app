//
//  UIImageView+Extensions.swift
//  Interact_app
//
//  Created by admin73 on 01/01/26.
//



import UIKit

extension UIImageView {
    
    /// Loads an image from a URL string asynchronously
    func loadImage(from urlString: String?, placeholder: UIImage? = nil) {
        if let placeholder = placeholder {
            self.image = placeholder
        }
        
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
