import Foundation
import UIKit
import Darwin

extension String
{
    //MARK: Methods
    
    /**
     Finds the localized string for the provided key in the main bundle and returns it.
     
     - Returns: A localized version of the provided key.
     */
    func translate() -> String
    {
        return NSLocalizedString(self, comment: "")
    }
    
    /**
     Gets a string that contains both bold and regular text.
     
     - Parameter nonBoldTextRange: Range where the text will not be bold.
     
     - Returns: A NSAttributedString containing the desired attributes.
     */
    func getBoldStringWithNonBoldText(_ nonBoldTextRange: NSRange) -> NSAttributedString
    {
        let fontSize = UIFont.systemFontSize
        let attrs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize),
            NSForegroundColorAttributeName: UIColor.black
        ]
        
        let nonBoldAttribute = [
            NSFontAttributeName: UIFont.systemFont(ofSize: fontSize),
            NSForegroundColorAttributeName: UIColor.black//.withAlphaComponent(0.5)
        ]
        
        let attrStr = NSMutableAttributedString(string: self, attributes: attrs)
        attrStr.setAttributes(nonBoldAttribute, range: nonBoldTextRange)
        
        return attrStr
    }
}
