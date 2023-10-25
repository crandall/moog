//
//  OscillatorView.swift
//  moog
//
//  Created by Mike Crandall on 10/19/23.
//

import UIKit

class OscillatorView: UIView {
    
    @IBOutlet weak var label: UILabel!
    
    let nibName = "OscillatorView"
    var contentView: UIView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private
    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        addSubview(view)
        contentView = view
        configureViews()
    }
    
    private
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    private
    func configureViews(){
        print("configureViews")
        
        contentView?.backgroundColor = .clear
    }
    
    
    
}
