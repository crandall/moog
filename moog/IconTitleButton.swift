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
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var waveformImageView: UIImageView!
    @IBOutlet weak var titleImageView: UIImageView!
    
    var waveType: WaveType?
    
    let controlColor = UIColor(
        red: 30/255.0,
        green: 90/255.0,
        blue: 155/255.0,
        alpha: 1.0
    )
    let controlFont = UIFont(name: "DINCondensed-Bold", size: 30)
    
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
        
        self.contentView.backgroundColor = .clear
        self.imageContainerView.backgroundColor = .clear
        bgImageView.backgroundColor = .clear
        waveformImageView.backgroundColor = .clear
        titleImageView.backgroundColor = .clear

        accessibilityTraits = .button
        
        self.isSelected = false
    }
    
    // MARK: - Public API
    
    func configure(
        image: UIImage?,
        title: String
    ) {
        
        waveformImageView.image = image
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
        
        waveformImageView.image = UIImage(
            systemName: systemImage,
            withConfiguration: config
        )
    }
    
    func setSelected(isSelected:Bool){
        print("\(String(describing: waveType)):\(isSelected ? "selected" : "unselected")")
    }
    
    // MARK: - Highlight
    
    override var isHighlighted: Bool {
        
        didSet {
            
            UIView.animate(withDuration: 0.1) {
                
                self.alpha = self.isHighlighted ? 0.6 : 1.0
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
            }
        }
    }
    
    // MARK: - Selected
    
    override var isSelected: Bool {
        
        didSet {
            imageContainerView.backgroundColor = isSelected ? controlColor : .white
        }
    }
}
