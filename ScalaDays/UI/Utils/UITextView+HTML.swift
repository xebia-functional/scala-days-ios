import UIKit

extension UITextView {
    var textHTML: String? {
        get {
            return self.text
        }
        set(value) {
            let font = self.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
            setTextHTML(value ?? "", font: font)
        }
    }
    
    private func setTextHTML(_ text: String, font: UIFont) {
        guard !text.isEmpty else { return }
        let attributedString = "\(styleHTML(font: font))\(text.plain2HTML)".htmlAttributedString
        self.attributedText = attributedString
    }
    
    private func styleHTML(font: UIFont) -> String {
        let style = """
                    <style type='text/css'>
                        body {
                            font-family: '\(font.fontName)';
                            font-size: \(font.pointSize)px;
                            color: "#\(textColor?.hex ?? "#000000");
                        };
                    </style>
                    """
        return style
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
