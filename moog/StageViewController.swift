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
    case sineOnly
    case waveform
    case multiview
    case oscillator
    case test
    case tuner
}

class StageViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var demoType: DemoType?
    let popup = SettingsPopupView()
    
    private var settingsPopupView: SettingsPopupView?
    private var popupDismissView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        
        var navbarTitle = ""
        var audioKitView: AnyView?
        
        switch demoType {
        case .thereScope:
            navbarTitle = "ThereScope"
            audioKitView = AnyView(
                TherescopeView(sineOnly: false)
            )
            
        case .sineOnly:
            navbarTitle = "ThereScope"
            audioKitView = AnyView(
                TherescopeView(sineOnly: true)
            )
            
        case .waveform:
            navbarTitle = "Waveforms"
            audioKitView = AnyView(
                WaveformView()
            )
            
        case .multiview:
            navbarTitle = "Multi View Demo"
            audioKitView = AnyView(
                MultiView()
            )
            
        case .oscillator:
            break
            
        case .test:
            navbarTitle = "Popup"
            audioKitView = AnyView(
                TherescopePopupView(sineOnly: false)
            )
            
        case .tuner:
            navbarTitle = "InputDeviceDemo"
            audioKitView = AnyView(
                InputDeviceDemoView()
            )
            
        case .none:
            break
        }
        
        navigationItem.title = navbarTitle
        view.backgroundColor = .clear
        
        guard let audioKitView else {
            return
        }
        
        let hostingController = UIHostingController(
            rootView: audioKitView
        )
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            hostingController.view.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
            hostingController.view.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            hostingController.view.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            )
        ])
        
        hostingController.didMove(toParent: self)
        
//        configureSettingsButton()
    }
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    @IBAction func onBack() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation bar
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBlue
        
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func configureSettingsButton() {
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsButtonPressed)
        )
        
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    // MARK: - Settings popup
    
    @objc private func settingsButtonPressed() {
        if settingsPopupView == nil {
            showSettingsPopup()
        } else {
            hideSettingsPopup()
        }
    }
    
    private func showSettingsPopup() {
        guard settingsPopupView == nil else {
            return
        }
        
        /*
         Transparent view that captures taps outside the popup.
         It sits above the SwiftUI content and below the popup.
         */
        let dismissView = UIView()
        dismissView.backgroundColor = .clear
        dismissView.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissViewTapped)
        )
        
        dismissView.addGestureRecognizer(tapGesture)
        
        view.addSubview(dismissView)
        
        NSLayoutConstraint.activate([
            dismissView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            dismissView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
            dismissView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            dismissView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            )
        ])
        
        popupDismissView = dismissView
        
        popup.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(popup)
        
        NSLayoutConstraint.activate([
            popup.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 8
            ),
            popup.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -12
            ),
            popup.widthAnchor.constraint(
                equalToConstant: 200
            ),
            popup.heightAnchor.constraint(
                equalToConstant: 300
            )
        ])
        
        /*
         Resolve Auto Layout before applying the animation so the
         transform works from the popup's final location.
         */
        view.layoutIfNeeded()
        
        popup.alpha = 0
        
        /*
         Since the popup is constrained to the right edge, this makes
         it appear to open downward and toward the left.
         */
        popup.transform = CGAffineTransform(
            translationX: 40,
            y: -20
        ).scaledBy(
            x: 0.75,
            y: 0.75
        )
        
        settingsPopupView = popup
        
        UIView.animate(
            withDuration: 0.22,
            delay: 0,
            options: [
                .curveEaseOut,
                .beginFromCurrentState
            ]
        ) {
            self.popup.alpha = 1
            self.popup.transform = .identity
        }
    }
    
    private func hideSettingsPopup() {
        guard let popup = settingsPopupView else {
            return
        }
        
        UIView.animate(
            withDuration: 0.18,
            delay: 0,
            options: [
                .curveEaseIn,
                .beginFromCurrentState
            ]
        ) {
            popup.alpha = 0
            
            popup.transform = CGAffineTransform(
                translationX: 40,
                y: -20
            ).scaledBy(
                x: 0.75,
                y: 0.75
            )
            
        } completion: { [weak self] _ in
            popup.removeFromSuperview()
            self?.popupDismissView?.removeFromSuperview()
            
            self?.settingsPopupView = nil
            self?.popupDismissView = nil
        }
    }
    
    @objc private func dismissViewTapped() {
        hideSettingsPopup()
    }
    
    
}
