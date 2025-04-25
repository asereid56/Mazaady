//
//  advertisementCell.swift
//  Mazaady
//
//  Created by Aser Eid on 25/04/2025.
//

import UIKit

class advertisementCell: UITableViewCell {

    @IBOutlet weak var advertismentCell: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        advertismentCell.layer.cornerRadius = 21
        advertismentCell.clipsToBounds = true
        advertismentCell.contentMode = .scaleAspectFill
    }
}
