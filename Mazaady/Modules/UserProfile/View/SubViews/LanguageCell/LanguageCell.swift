//
//  LanguageCell.swift
//  Mazaady
//
//  Created by Aser Eid on 26/04/2025.
//

import UIKit

class LanguageCell: UITableViewCell {

    @IBOutlet weak var isSelectedImage: UIImageView!
    @IBOutlet weak var languageName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configure(with language: LanguageEntity) {
         languageName.text = language.name
         isSelectedImage.image = UIImage(named: language.isSelected ? "radioSelected" : "radioNotSelected")
     }
    
}
