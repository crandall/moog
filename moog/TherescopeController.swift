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

private struct HostedNoisePlot: View {
    @ObservedObject var noiseConductor: NoiseConductor
    
    var amplitudeScale: CGFloat
    
    var body: some View {
        RawOutputView1(
            noiseConductor.tappableNodeB,
            strokeColor: Color.plotColor,
            isNormalized: false,
            scaleFactor: amplitudeScale
        )
        .background(Color.black)
        .clipped()
    }
}


final class TherescopeController: UIViewController {
    
    @IBOutlet private weak var wavePlotContainerView: UIView!

    @IBOutlet weak var waveformButtonStack: UIStackView!
    @IBOutlet weak var sineButton: UIButton!
    @IBOutlet weak var squareButton: UIButton!
    @IBOutlet weak var triangleButton: UIButton!
    @IBOutlet weak var sawtoothButton: UIButton!
    @IBOutlet weak var noiseButton: UIButton!
    @IBOutlet weak var amplitudeSlider: UISlider!

    private let waveConductor = WaveConductor()
    private var wavePlotHostingController: UIHostingController<HostedWavePlot>?
    
    private let noiseConductor = NoiseConductor()
    private var noiseHostingController: UIHostingController<HostedNoisePlot>?
    
    private var selectedWave: WaveType = .sine {
        didSet {
            guard selectedWave != oldValue else {
                return
            }
            selectedWaveDidChange()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureViews()
        embedWavePlot()
        embedNoisePlot()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        waveConductor.start()
        noiseConductor.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        waveConductor.stop()
        noiseConductor.stop()
    }
    
    func configureViews() {
        
        wavePlotContainerView.layer.cornerRadius = 40
        
        waveformButtonStack.backgroundColor = .clear
        
        // the buttons:
        for definition in waveButtons {
            
            let button = definition.button
            
            button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
            button.layer.cornerRadius = 5
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 1
            
            button.setTitle(definition.title, for: .normal)
        }
        
        updateButtons(selectedWave)
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
  
    private func embedNoisePlot() {
        
        let noiseView = HostedNoisePlot(
            noiseConductor: noiseConductor,
            amplitudeScale: 10.0
        )
        
        let hosting = UIHostingController(rootView: noiseView)
        
        noiseHostingController = hosting
        
        addChild(hosting)
        
        let v = hosting.view!
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .black
        v.isHidden = true          // initially hidden
        
        wavePlotContainerView.addSubview(v)
        
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: wavePlotContainerView.topAnchor),
            v.bottomAnchor.constraint(equalTo: wavePlotContainerView.bottomAnchor),
            v.leadingAnchor.constraint(equalTo: wavePlotContainerView.leadingAnchor),
            v.trailingAnchor.constraint(equalTo: wavePlotContainerView.trailingAnchor)
        ])
        
        hosting.didMove(toParent: self)
    }
    
    
    // MARK: -- buttonData
    struct WaveButtonDefinition {
        let button: UIButton
        let waveType: WaveType
        let title: String
    }
    
    private lazy var waveButtons: [WaveButtonDefinition] = [
        .init(button: sineButton,      waveType: .sine,      title: "Sine"),
        .init(button: squareButton,    waveType: .square,    title: "Square"),
        .init(button: triangleButton,  waveType: .triangle,  title: "Triangle"),
        .init(button: sawtoothButton,  waveType: .sawtooth,  title: "Sawtooth"),
        .init(button: noiseButton,     waveType: .noise,     title: "Noise")
    ]
    
    func updateButtons(_ selectedWave: WaveType) {
        
        for definition in waveButtons {
            
            let isSelected = definition.waveType == selectedWave
            
            definition.button.setTitleColor(
                isSelected ? .white : .black,
                for: .normal
            )
            
            definition.button.backgroundColor =
            isSelected ? .systemBlue : .white
        }
    }

    @IBAction func onSine(){
        selectedWave = .sine
        self.updateButtons(selectedWave)
    }
    
    @IBAction func onSquare(){
        selectedWave = .square
        self.updateButtons(selectedWave)
    }

    @IBAction func onTriangle(){
        selectedWave = .triangle
        self.updateButtons(selectedWave)
    }

    @IBAction func onSawtooth(){
        selectedWave = .sawtooth
        self.updateButtons(selectedWave)
    }

    @IBAction func onNoise(){
        selectedWave = .noise
        self.updateButtons(selectedWave)
    }
    
    // MARK: -- wave change should change the WavePlot

    private func selectedWaveDidChange() {
        
        updateButtons(selectedWave)
        
        let showingNoise = selectedWave == .noise
        
        wavePlotHostingController?.view.isHidden = showingNoise
        noiseHostingController?.view.isHidden = !showingNoise
        
        if !showingNoise {
            waveConductor.setupOscillator(waveform: selectedWave)
        }
    }
    
//    private func selectedWaveDidChange() {
//        updateButtons(selectedWave)
//        
//        switch selectedWave {
//        case .noise:
//            // Noise handling will be added separately.
//            break
//            
//        case .sine, .square, .triangle, .sawtooth:
//            waveConductor.setupOscillator(
//                waveform: selectedWave
//            )
//        }
//    }
    
    // MARK: -- slider
    
    @IBAction func amplitudeSliderChanged(_ sender: UISlider) {
        let value = sender.value
        
        print("Amplitude scale = \(value)")
    }
    
}
