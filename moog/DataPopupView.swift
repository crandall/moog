//
//  DataPopupView.swift
//  moog
//
//  Created by Mike Crandall on 7/21/26.
//

import UIKit

class DataPopupView: UIView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var dataLabel: UILabel!
    @IBOutlet private weak var closeButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        print("commonInit")
        
        Bundle.main.loadNibNamed(
            "DataPopupView",
            owner: self,
            options: nil
        )
        
        guard let contentView = contentView else {
            fatalError("contentView outlet not connected")
        }
        
        addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        layer.cornerRadius = 12
        layer.cornerCurve = .continuous
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 4)
        
        clipsToBounds = false
        
        contentView.layer.cornerRadius = 12
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true
    }
    
    var onClose: (() -> Void)?
    @IBAction func onClose(_ sender: UIButton) {
        print("DataPopupView.onClose")
        onClose?()
    }

}
