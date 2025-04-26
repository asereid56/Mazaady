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
    
    private var timer: Timer?
    private var remainingSeconds: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timer?.invalidate()
        timer = nil
    }
    
    private func setupUI() {
        layer.cornerRadius = 24
        layer.masksToBounds = true
        backgroundColor = .white
        productImage.layer.cornerRadius = 20
        productImage.contentMode = .scaleAspectFill
        productImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        priceLabel.text = "Price".localized()
        offerPriceLabel.text = "Offer Price".localized()
        lotStartInLabel.text = "Lot Starts In".localized()
        dayLabel.text = "D".localized()
        minuteLabel.text = "M".localized()
        hourLabel.text = "H".localized()
        
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
        
        if let endDateDuration = product.endDate {
            remainingSeconds = Int(endDateDuration)
            startTimer()
            updateCountdownLabels()
            showCountdownViews(true)
        } else {
            showCountdownViews(false)
        }
    }
    
    private func startTimer() {
        timer?.invalidate() 
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.remainingSeconds -= 1
            self.updateCountdownLabels()
            if self.remainingSeconds <= 0 {
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
    
    private func updateCountdownLabels() {
        let days = remainingSeconds / (24 * 3600)
        let hours = (remainingSeconds % (24 * 3600)) / 3600
        let minutes = (remainingSeconds % 3600) / 60
        
        dayCount.text = "\(max(days, 0))"
        hourCount.text = "\(max(hours, 0))"
        minuteCount.text = "\(max(minutes, 0))"
    }
    
    private func showCountdownViews(_ isVisible: Bool) {
        lotStartInLabel.isHidden = !isVisible
        dayLabel.isHidden = !isVisible
        dayCount.isHidden = !isVisible
        hourLabel.isHidden = !isVisible
        hourCount.isHidden = !isVisible
        minuteLabel.isHidden = !isVisible
        minuteCount.isHidden = !isVisible
        dayView.isHidden = !isVisible
        hourView.isHidden = !isVisible
        minuteView.isHidden = !isVisible
    }
}
