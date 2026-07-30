//
//  IconTitleButton.swift
//  moog
//
//  Created by Mike Crandall on 7/30/26.
//

import UIKit

class IconTitleButton: UIControl {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var contentView: UIView!
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed(
            "IconTitleButton",
            owner: self,
            options: nil
        )
        
        addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        contentView.isUserInteractionEnabled = false
        
        configureAppearance()
    }
    
    // MARK: - Appearance
    
    private func configureAppearance() {
        
        imageContainerView.layer.cornerRadius = 8
        imageContainerView.layer.borderWidth = 1
        imageContainerView.layer.borderColor =
        UIColor.white.cgColor
        
        imageContainerView.clipsToBounds = true
        
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .systemBlue
        
        accessibilityTraits = .button
    }
    
    // MARK: - Public API
    
    func configure(
        image: UIImage?,
        title: String
    ) {
        
        imageView.image = image
        titleLabel.text = title
    }
    
    func configure(
        systemImage: String,
        title: String,
        pointSize: CGFloat = 28,
        weight: UIImage.SymbolWeight = .regular
    ) {
        
        let config = UIImage.SymbolConfiguration(
            pointSize: pointSize,
            weight: weight
        )
        
        imageView.image = UIImage(
            systemName: systemImage,
            withConfiguration: config
        )
        
        titleLabel.text = title
    }
    
    // MARK: - Highlight
    
    override var isHighlighted: Bool {
        
        didSet {
            
            UIView.animate(withDuration: 0.1) {
                
                self.alpha = self.isHighlighted ? 0.6 : 1.0
                
                self.transform = self.isHighlighted
                ? CGAffineTransform(scaleX: 0.96, y: 0.96)
                : .identity
            }
        }
    }
    
    // MARK: - Selected
    
    override var isSelected: Bool {
        
        didSet {
//            imageContainerView.backgroundColor = isSelected ? tintColor.withAlphaComponent(0.25) : .clear
            imageContainerView.backgroundColor = isSelected ? tintColor.withAlphaComponent(0.25) : .clear
        }
    }
}
