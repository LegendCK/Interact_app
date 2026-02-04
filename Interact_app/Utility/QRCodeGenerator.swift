//
//  QRCodeGenerator.swift
//  Interact_app
//
//  Created by admin56 on 14/01/26.
//

import UIKit
import CoreImage

enum QRCodeGenerator {

    static func generate(from string: String, size: CGFloat = 220) -> UIImage? {
        let data = string.data(using: .utf8)

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")

        guard let output = filter.outputImage else { return nil }

        let scale = size / output.extent.width
        let transformed = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        return UIImage(ciImage: transformed)
    }
}

