//
//  StageViewController.swift
//  moog
//
//  Created by Mike Crandall on 10/18/23.
//

// https://audiokitpro.com/audiovisualizertutorial/

import UIKit
import SwiftUI

enum DemoType {
    case thereScope
    case waveform
    case multiview
}

class StageViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var demoType: DemoType?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = .black

        var navbarTitle = ""
        var audioKitView: AnyView?
        
        // Create a SwiftUI view and embed it in a UIHostingController
        switch demoType {
        case .thereScope:
            navbarTitle = "ThereScope"
            audioKitView = AnyView(ThereScopeView())
        case .waveform:
            navbarTitle = "Waveforms"
            audioKitView = AnyView(WaveformView())
        case .multiview:
            navbarTitle = "Multi View Demo"
            audioKitView = AnyView(MultiView())
        default:
            break
        }

        self.navigationItem.title = navbarTitle

        let hostingController = UIHostingController(rootView: audioKitView)

        
        // Add the SwiftUI view as a child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // Define the layout constraints for the SwiftUI view
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        hostingController.didMove(toParent: self)
        
    }
    
    @IBAction func onBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
}
