//
//  Extensions.swift
//  moog
//
//  Created by Mike Crandall on 11/29/23.
//

import Foundation
import SwiftUI

extension Color {
    static let plotColor1 = Color(red: 66 / 255, green: 110 / 255, blue: 244 / 255)

    static let plotColor = Color(
        red: 25.0/255.0,
        green: 69.0/255.0,
        blue: 128.0/255.0,
    )
    
    static let therescopeBlue = UIColor(
        red: 25.0/255.0,
        green: 69.0/255.0,
        blue: 128.0/255.0,
        alpha: 1.0
    )

}

extension UIFont {
    static func therescopeFont(size:CGFloat)->UIFont?{
        return UIFont(name: "DINCondensed-Bold", size: size)
    }
}
