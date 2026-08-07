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
    
    var waveType: WaveType? {
        didSet{
            self.setText(waveType: self.waveType)
            self.setSelected(isSelected: false)
        }
    }
    
    
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
        
        self.contentView.backgroundColor = .orange
        self.imageContainerView.backgroundColor = .lightGray
        bgImageView.backgroundColor = .clear
        waveformImageView.backgroundColor = .clear
        titleImageView.backgroundColor = .clear

        accessibilityTraits = .button
        
        self.isSelected = false
    }
    
    // MARK: - Public API
    
    func setText(waveType:WaveType?){
        guard let waveType = waveType else { return }
        var waveImageStr = ""
        switch waveType {
        case .sine:
            waveImageStr = "text_sine"
        case .square:
            waveImageStr = "text_square"
        case .triangle:
            waveImageStr = "text_triangle"
        case .sawtooth:
            waveImageStr = "text_saw"
        case .noise:
            waveImageStr = "text_noise"
        }
        
        let image = UIImage(named: waveImageStr)
        self.titleImageView.image = image
    }

    func waveImage(waveType:WaveType?, isSelected:Bool)->UIImage?{
        var waveImageStr = ""
        switch waveType {
        case .sine:
            waveImageStr = isSelected ? "button_sine_active" : "button_sine"
        case .square:
            waveImageStr = isSelected ? "button_square_active" : "button_square"
        case .triangle:
            waveImageStr = isSelected ? "button_triangle_active" : "button_triangle"
        case .sawtooth:
            waveImageStr = isSelected ? "button_sawtooth_active" : "button_sawtooth"
        case .noise:
            waveImageStr = isSelected ? "button_noise_active" : "button_noise"
        default:
            return nil
        }
        
        return UIImage(named: waveImageStr)
    }
    
    func setSelected(isSelected:Bool){
        let bgImageStr = isSelected ? "button_active" : "button_inactive"
        let image = UIImage(named: bgImageStr)
        bgImageView.image = image
        
        if let wfImage = self.waveImage(waveType: self.waveType, isSelected: isSelected) as UIImage? {
            waveformImageView.image = wfImage
        }
        
    }
    
}
