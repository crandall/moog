//
//  SettingsCell.swift
//  moog
//
//  Created by Mike Crandall on 7/24/26.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var displayDataSwitch: UISwitch!

    var onSwitchChanged: ((_ newValue:Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.titleLabel.textColor = .black
    }
    
    override func prepareForReuse(){
        super.prepareForReuse()
        self.displayDataSwitch.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureSwitch(isVisible:Bool, currValue:Bool){
        self.displayDataSwitch.isHidden = !isVisible
        self.displayDataSwitch.setOn(currValue, animated: false)
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        self.onSwitchChanged?(sender.isOn)
    }
    
}
