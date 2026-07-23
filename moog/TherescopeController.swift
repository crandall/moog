//
//  TherescopeController.swift
//  moog
//
//  Created by Mike Crandall on 7/23/26.
//

import UIKit
import SwiftUI

// Bridges WaveConductor's published values into the existing WavePlot.
private struct HostedWavePlot: View {
    @ObservedObject var waveConductor: WaveConductor
    
    var body: some View {
        WavePlot(
            waveData: waveConductor.waveData,
            amplitudeScale: 0.8,
            widthScale: 0.25,
            minAmplitudeThreshold: 0.01,
            minAmplitudeScale: 0.1,
            minWidthScale: 0.5
        )
        .background(Color.black)
        .clipped()
    }
}

final class TherescopeController: UIViewController {
    
    @IBOutlet private weak var wavePlotContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private let waveConductor = WaveConductor()
    
    private var wavePlotHostingController:
    UIHostingController<HostedWavePlot>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        embedWavePlot()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        waveConductor.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        waveConductor.stop()
    }
    
    private func embedWavePlot() {
        let wavePlot = HostedWavePlot(
            waveConductor: waveConductor
        )
        
        let hostingController = UIHostingController(
            rootView: wavePlot
        )
        
        wavePlotHostingController = hostingController
        
        addChild(hostingController)
        
        let hostedView = hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        hostedView.backgroundColor = .black
        
        wavePlotContainerView.addSubview(hostedView)
        
        NSLayoutConstraint.activate([
            hostedView.topAnchor.constraint(
                equalTo: wavePlotContainerView.topAnchor
            ),
            hostedView.bottomAnchor.constraint(
                equalTo: wavePlotContainerView.bottomAnchor
            ),
            hostedView.leadingAnchor.constraint(
                equalTo: wavePlotContainerView.leadingAnchor
            ),
            hostedView.trailingAnchor.constraint(
                equalTo: wavePlotContainerView.trailingAnchor
            )
        ])
        
        hostingController.didMove(toParent: self)
    }
}
