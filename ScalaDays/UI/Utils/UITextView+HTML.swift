import UIKit

extension UITextView {
    var textHTML: String? {
        get { text }
        set(value) {
            setTextHTML(value ?? "",
                        font: self.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize))
        }
    }
    
    func setHTMLAppareance(_ appareance: [NSAttributedString.Key : Any], textColor: UIColor? = nil, font: UIFont? = nil) {
        self.textColor = textColor ?? self.textColor
        self.font = font ?? self.font
        self.linkTextAttributes = appareance
    }
    
    // MARK: - private <helpers>
    private func setTextHTML(_ text: String, font: UIFont) {
        guard !text.isEmpty,
              let attributedText = "\(styleHTML(font: font))\(text.plain2HTML)".htmlAttributedString else { return }
        
        self.attributedText = attributedText
    }
    
    private func styleHTML(font: UIFont) -> String {
        """
        <style type='text/css'>
            body {
                font-family: '\(font.fontName)';
                font-size: \(font.pointSize)px;
                color: "#\(textColor?.hex ?? "#000000");
            };
        </style>
        """
    }
}

// MARK: Helpers
private extension String {
    
    var htmlAttributedString: NSAttributedString? {
        guard let data = data(using: .utf16) else { return nil }
        return try? NSAttributedString(data: data,
                                       options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf16.rawValue],
                                       documentAttributes: nil)
    }
    
    var plain2HTML: String {
        replacingOccurrences(of: "\n", with: "")
    }
}
