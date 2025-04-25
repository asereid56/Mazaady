//
//  ProductCell.swift
//  Mazaady
//
//  Created by Aser Eid on 25/04/2025.
//

import UIKit

class ProductCell: UICollectionViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceValue: UILabel!
    @IBOutlet weak var offerPriceLabel: UILabel!
    @IBOutlet weak var offerPriceValue: UILabel!
    @IBOutlet weak var lotStartInLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dayCount: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var hourCount: UILabel!
    @IBOutlet weak var minuteLabel: UILabel!
    @IBOutlet weak var minuteCount: UILabel!
    @IBOutlet weak var dayView: UIStackView!
    @IBOutlet weak var hourView: UIStackView!
    @IBOutlet weak var minuteView: UIStackView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        layer.cornerRadius = 24
        layer.masksToBounds = true
        backgroundColor = .white
        productImage.layer.cornerRadius = 20
        productImage.contentMode = .scaleAspectFill
        productImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        priceLabel.text = NSLocalizedString("Price", comment: "")
        offerPriceLabel.text = NSLocalizedString("Offer Price", comment: "")
        lotStartInLabel.text = NSLocalizedString("Lot Starts In", comment: "")
        dayLabel.text = NSLocalizedString("D", comment: "")
        minuteLabel.text = NSLocalizedString("M", comment: "")
        hourLabel.text = NSLocalizedString("H", comment: "")
        
        dayView.layer.cornerRadius = 14
        dayView.layer.masksToBounds = true
        hourView.layer.cornerRadius = 14
        hourView.layer.masksToBounds = true
        minuteView.layer.cornerRadius = 14
        minuteView.layer.masksToBounds = true
    }
    
    func configure(with product: ProductEntity) {
        if let imageUrl = URL(string: product.image) {
            productImage.kf.setImage(
                with: imageUrl,
                placeholder: UIImage(named: "productPlaceholder"),
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]
            )
        }
        
        productName.text = product.name
        
        priceValue.text = "\(product.price) \(product.currency)"
        
        if let offer = product.offer {
            offerPriceLabel.isHidden = false
            offerPriceValue.isHidden = false
            offerPriceValue.text = "\(offer) \(product.currency)"
        } else {
            offerPriceLabel.isHidden = true
            offerPriceValue.isHidden = true
        }
        
        if let endDate = product.endDate {
            let (days, hours, minutes) = calculateTimeRemaining(endDate: endDate)
            dayCount.text = "\(days)"
            hourCount.text = "\(hours)"
            minuteCount.text = "\(minutes)"
            lotStartInLabel.isHidden = false
            dayLabel.isHidden = false
            dayCount.isHidden = false
            hourLabel.isHidden = false
            hourCount.isHidden = false
            minuteLabel.isHidden = false
            minuteCount.isHidden = false
            dayView.isHidden = false
            hourView.isHidden = false
            minuteView.isHidden = false
        } else {
            lotStartInLabel.isHidden = true
            dayLabel.isHidden = true
            dayCount.isHidden = true
            hourLabel.isHidden = true
            hourCount.isHidden = true
            minuteLabel.isHidden = true
            minuteCount.isHidden = true
            dayView.isHidden = true
            hourView.isHidden = true
            minuteView.isHidden = true
        }
    }
    
    private func calculateTimeRemaining(endDate: Double) -> (days: Int, hours: Int, minutes: Int) {
        let currentDate = Date()
        let endDate = Date(timeIntervalSince1970: endDate)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute], from: currentDate, to: endDate)
        
        let days = max(components.day ?? 0, 0)
        let hours = max(components.hour ?? 0, 0)
        let minutes = max(components.minute ?? 0, 0)
        
        return (days, hours, minutes)
    }
}
