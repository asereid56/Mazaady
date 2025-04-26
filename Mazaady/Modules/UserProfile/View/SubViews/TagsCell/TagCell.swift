//
//  tagCell.swift
//  Mazaady
//
//  Created by Aser Eid on 26/04/2025.
//

import UIKit

class TagCell: UICollectionViewCell {
    
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var tagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    private func setupUI() {
        tagView.layer.cornerRadius = 16
        tagView.layer.masksToBounds = true
        tagView.layer.borderWidth = 0
        tagView.layer.borderColor = UIColor.clear.cgColor
        tagView.backgroundColor = .white
        tagLabel.textColor = .black
        tagLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    }
    
    func configure(with title: String, isSelected: Bool) {
        tagLabel.text = title
            if isSelected {
                tagView.backgroundColor = UIColor(named: "Orange20") ?? UIColor.orange.withAlphaComponent(0.2)
                tagView.layer.borderWidth = 1
                tagView.layer.borderColor = (UIColor(named: "Orange100") ?? UIColor.orange).cgColor
                tagLabel.textColor = UIColor(named: "Orange100") ?? .orange
            } else {
                tagView.backgroundColor = .white
                tagView.layer.borderWidth = 0
                tagView.layer.borderColor = UIColor.clear.cgColor
                tagLabel.textColor = .black
            }
        }
}
