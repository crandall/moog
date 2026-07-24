//
//  SettingsPopupView.swift
//  moog
//
//  Created by Mike Crandall on 7/17/26.
//

import UIKit

class SettingsPopupView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
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
    
    var onClose: (() -> Void)?
    @IBAction func onClose(_ sender: UIButton) {
        print("SettingsPopupView.onClose")
        onClose?()
    }
    
    // MARK: -- tableView
    
    enum SettingsType: CaseIterable {
        case waveform
        case displayData
        
        static func type(for section: Int) -> SettingsType {
            allCases[section]
        }
        
        var headerTitle: String {
            switch self {
            case .waveform:
                return "Waveform"
                
            case .displayData:
                return "Display Data"
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SettingsType.allCases[section] {
        case .waveform:
            return 2
        case .displayData:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let settingType = SettingsType.type(for: section)
        
        let label = UILabel()
        label.text = settingType.headerTitle
        label.font = .boldSystemFont(ofSize: 16)
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
        
        let setting = SettingsType.type(for: indexPath.section)
        switch setting {
        case .waveform:
            let str = indexPath.row == 0 ? "Sine/Noise only" : "All Waveforms"
            cell.titleLabel.text = str
        case .displayData:
            let str = "Show/Hide data"
            cell.titleLabel.text = str
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Selected row \(indexPath.row)")
    }
}
