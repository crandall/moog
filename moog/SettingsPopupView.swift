//
//  SettingsPopupView.swift
//  moog
//
//  Created by Mike Crandall on 7/17/26.
//

import UIKit

enum SettingsType: String, CaseIterable {    case sineOnly
    case displayData
    
    var key: String {
        switch self {
        case .sineOnly:
            return "sineOnly"
        case .displayData:
            return "showData"
        }
    }
    
    var defaultValue: Bool {
        switch self {
        case .sineOnly:
            return false
            
        case .displayData:
            return false
        }
    }
    
    static func type(for section: Int) -> SettingsType {
        allCases[section]
    }
    
    var headerTitle: String {
        switch self {
        case .sineOnly:
            return "SineOnly"
            
        case .displayData:
            return "Display Data"
        }
    }
}


class SettingsPopupView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var closeButton: UIButton!
    
    var onClose: (() -> Void)?
    var onSineOnly: ((_ newValue: Bool?) -> Void)?
    var onDisplayData: ((_ newValue: Bool?) -> Void)?
    var currSineOnly: Bool = false
    var currDisplayData: Bool = false

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func prepareForDisplay() {
        currSineOnly = SettingsDefaults.setting(for: .sineOnly)
        currDisplayData = SettingsDefaults.setting(for: .displayData)
        tableView.reloadData()
    }
    
    private func commonInit() {
        print("commonInit")
        
        Bundle.main.loadNibNamed(
            "SettingsPopupView",
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
        
        self.titleLabel.text = "Settings"
        self.closeButton.isHidden = true
        
        let nib = UINib(nibName: "SettingsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SettingsCell")
        
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        print("SettingsPopupView.onClose")
        onClose?()
    }
    
    // MARK: -- tableView
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SettingsType.allCases[section] {
        case .sineOnly:
            return 2
        case .displayData:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let settingType = SettingsType.type(for: section)
        
        let label = UILabel()
        label.text = settingType.headerTitle
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .label
        
        let view = UIView()
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6)
        ])
        
        return view
    }
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        cell.selectionStyle = .none
        
        let setting = SettingsType.type(for: indexPath.section)
        switch setting {
        case .sineOnly:
            let str = indexPath.row == 0 ? "Sine/Noise only" : "All Waveforms"
            cell.titleLabel.text = str
            cell.configureSwitch(isVisible: false, currValue: false)

            if indexPath.row == 0 {
                cell.accessoryType = currSineOnly == true ? .checkmark : .none
            } else if indexPath.row == 1 {
                cell.accessoryType = currSineOnly == true ? .none : .checkmark
            }

            
        case .displayData:
            let str = "Show Waveform Data"
            cell.accessoryType = .none
            cell.titleLabel.text = str
            cell.configureSwitch(isVisible: true, currValue: currDisplayData)
            cell.onSwitchChanged = { [weak self] newValue in
                self?.handleDataDisplaySwitch(value: newValue)
            }
        }
        return cell
    }
    
    func handleDataDisplaySwitch(value:Bool?){
        guard let value = value else { return }
        SettingsDefaults.setSetting(value, for: .displayData)
        self.onDisplayData?(value)
    }
    
    func handleSineOnly(isSineOnly:Bool?){
        guard let isSineOnly = isSineOnly else { return }
        SettingsDefaults.setSetting(isSineOnly, for: .sineOnly)
        self.onSineOnly?(isSineOnly)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let setting = SettingsType.type(for: indexPath.section)
        switch setting {
        case .sineOnly:
            handleSineOnly(isSineOnly: indexPath.row == 0)
            self.currSineOnly = indexPath.row == 0 ? true : false
        case .displayData:
            let str = "Show Waveform Data"
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
