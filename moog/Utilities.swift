//
//  Utilities.swift
//  moog
//
//  Created by Mike Crandall on 7/24/26.
//

import Foundation

enum SettingsDefaults {
    
    static func setting(for type: SettingsType) -> Bool {
        UserDefaults.standard.bool(forKey: type.key)
    }
    
    static func setSetting(_ value: Bool, for type: SettingsType) {
        UserDefaults.standard.set(value, forKey: type.key)
    }
    
    static func registerDefaults() {
        let defaults = Dictionary(
            uniqueKeysWithValues: SettingsType.allCases.map {
                ($0.rawValue, $0.defaultValue)
            }
        )
        
        UserDefaults.standard.register(defaults: defaults)
    }


    //    private enum Keys {
    //        static let sineOnly = "sineOnly"
    //        static let showData = "showData"
    //    }
    

    // MARK: - Waveform
    
    //    static func waveform() -> Bool {
    //        UserDefaults.standard.bool(forKey: Keys.waveform)
    //    }
    //
    //    static func setWaveform(_ value: Bool) {
    //        UserDefaults.standard.set(value, forKey: Keys.waveform)
    //    }
    //
    //    // MARK: - Show Data
    //
    //    static func showData() -> Bool {
    //        UserDefaults.standard.bool(forKey: Keys.showData)
    //    }
    //
    //    static func setShowData(_ value: Bool) {
    //        UserDefaults.standard.set(value, forKey: Keys.showData)
    //    }
    
    // MARK: - Defaults
    
}
