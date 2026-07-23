//
//  TherescopeController.swift
//  moog
//
//  Created by Mike Crandall on 7/23/26.
//

import UIKit
import SwiftUI

// MARK: - Hosted plot state

private final class HostedPlotState: ObservableObject {
    
    @Published var selectedWave: WaveType = .sine
    @Published var amplitudeScale: CGFloat = 4.0 / 3.0
    
    let minAmplitudeScale: CGFloat = 0.5
    let maxAmplitudeScale: CGFloat = 3.0
    let noiseAmplitudeDefaultScale: CGFloat = 10.0
    
    var noiseScaleFactor: CGFloat {
        guard maxAmplitudeScale > 0 else {
            return noiseAmplitudeDefaultScale
        }
        
        return (amplitudeScale / maxAmplitudeScale)
        * noiseAmplitudeDefaultScale
    }
    
    var amplitudeDisplayValue: Double {
        let minimum = Double(minAmplitudeScale)
        let maximum = Double(maxAmplitudeScale)
        let current = Double(amplitudeScale)
        
        guard maximum > minimum else {
            return 1.0
        }
        
        let normalized =
        (current - minimum) / (maximum - minimum)
        
        let mappedValue =
        1.0 + normalized * 9.0
        
        return (mappedValue * 10).rounded() / 10
    }
}


// MARK: - Single hosted SwiftUI plot

private struct HostedTherescopePlot: View {
    
    @ObservedObject var plotState: HostedPlotState
    @ObservedObject var waveConductor: WaveConductor
    @ObservedObject var noiseConductor: NoiseConductor
    
    var body: some View {
        Group {
            if plotState.selectedWave == .noise {
                RawOutputView1(
                    noiseConductor.tappableNodeB,
                    strokeColor: Color.plotColor,
                    isNormalized: false,
                    scaleFactor: plotState.noiseScaleFactor
                )
            } else {
                WavePlot(
                    waveData: waveConductor.waveData,
                    amplitudeScale: plotState.amplitudeScale,
                    widthScale: 0.25,
                    minAmplitudeThreshold: 0.01,
                    minAmplitudeScale: 0.1,
                    minWidthScale: 0.5
                )
            }
        }
        .background(Color.black)
        .clipped()
    }
}


// MARK: - TherescopeController

final class TherescopeController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet private weak var wavePlotContainerView: UIView!
    
    @IBOutlet private weak var waveformButtonStack: UIStackView!
    
    @IBOutlet private weak var sineButton: UIButton!
    @IBOutlet private weak var squareButton: UIButton!
    @IBOutlet private weak var triangleButton: UIButton!
    @IBOutlet private weak var sawtoothButton: UIButton!
    @IBOutlet private weak var noiseButton: UIButton!
    
    @IBOutlet private weak var amplitudeSlider: UISlider!
    
    
    // MARK: Conductors
    
    private let waveConductor = WaveConductor()
    private let noiseConductor = NoiseConductor()
    
    
    // MARK: Hosted plot
    
    private let plotState = HostedPlotState()
    
    private var plotHostingController:
    UIHostingController<HostedTherescopePlot>?
    
    
    // MARK: Selected wave
    
    private var selectedWave: WaveType = .sine {
        didSet {
            guard selectedWave != oldValue else {
                return
            }
            
            selectedWaveDidChange()
        }
    }
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        embedPlot()
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
    
    
    // MARK: View configuration
    
    private func configureViews() {
        wavePlotContainerView.layer.cornerRadius = 40
        wavePlotContainerView.clipsToBounds = true
        
        waveformButtonStack.backgroundColor = .clear
        
        for definition in waveButtons {
            let button = definition.button
            
            button.titleLabel?.font =
            UIFont.systemFont(ofSize: 30)
            
            button.layer.cornerRadius = 5
            button.layer.borderColor =
            UIColor.black.cgColor
            
            button.layer.borderWidth = 1
            
            button.setTitle(
                definition.title,
                for: .normal
            )
        }
        
        configureAmplitudeSlider()
        updateButtons(selectedWave)
    }
    
    private func configureAmplitudeSlider() {
        amplitudeSlider.minimumValue =
        Float(plotState.minAmplitudeScale)
        
        amplitudeSlider.maximumValue =
        Float(plotState.maxAmplitudeScale)
        
        amplitudeSlider.value =
        Float(plotState.amplitudeScale)
        
        amplitudeSlider.isContinuous = true
    }
    
    
    // MARK: Embed SwiftUI plot
    
    private func embedPlot() {
        let hostedPlot = HostedTherescopePlot(
            plotState: plotState,
            waveConductor: waveConductor,
            noiseConductor: noiseConductor
        )
        
        let hostingController =
        UIHostingController(rootView: hostedPlot)
        
        plotHostingController = hostingController
        
        addChild(hostingController)
        
        guard let hostedView =
                hostingController.view else {
            return
        }
        
        hostedView.translatesAutoresizingMaskIntoConstraints =
        false
        
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
    
    
    // MARK: Button data
    
    private struct WaveButtonDefinition {
        let button: UIButton
        let waveType: WaveType
        let title: String
    }
    
    private lazy var waveButtons: [WaveButtonDefinition] = [
        .init(
            button: sineButton,
            waveType: .sine,
            title: "Sine"
        ),
        
            .init(
                button: squareButton,
                waveType: .square,
                title: "Square"
            ),
        
            .init(
                button: triangleButton,
                waveType: .triangle,
                title: "Triangle"
            ),
        
            .init(
                button: sawtoothButton,
                waveType: .sawtooth,
                title: "Sawtooth"
            ),
        
            .init(
                button: noiseButton,
                waveType: .noise,
                title: "Noise"
            )
    ]
    
    private func updateButtons(
        _ selectedWave: WaveType
    ) {
        for definition in waveButtons {
            let isSelected =
            definition.waveType == selectedWave
            
            definition.button.setTitleColor(
                isSelected ? .white : .black,
                for: .normal
            )
            
            definition.button.backgroundColor =
            isSelected ? .systemBlue : .white
        }
    }
    
    
    // MARK: Wave button actions
    
    @IBAction private func onSine() {
        selectedWave = .sine
    }
    
    @IBAction private func onSquare() {
        selectedWave = .square
    }
    
    @IBAction private func onTriangle() {
        selectedWave = .triangle
    }
    
    @IBAction private func onSawtooth() {
        selectedWave = .sawtooth
    }
    
    @IBAction private func onNoise() {
        selectedWave = .noise
    }
    
    
    // MARK: Wave selection
    
    private func selectedWaveDidChange() {
        updateButtons(selectedWave)
        
        /*
         Changing this published property causes
         HostedTherescopePlot to switch between
         WavePlot and RawOutputView1.
         */
        plotState.selectedWave = selectedWave
        
        switch selectedWave {
        case .noise:
            // RawOutputView1 uses noiseConductor.
            break
            
        case .sine,
                .square,
                .triangle,
                .sawtooth:
            
            waveConductor.setupOscillator(
                waveform: selectedWave
            )
        }
    }
    
    
    // MARK: Amplitude slider
    
    @IBAction private func amplitudeSliderChanged(
        _ sender: UISlider
    ) {
        /*
         Updating this published property causes the
         hosted SwiftUI plot to redraw automatically.
         */
        plotState.amplitudeScale =
        CGFloat(sender.value)
        
        print(
            "Amplitude scale = \(plotState.amplitudeScale)"
        )
        
        print(
            "Amplitude display value = \(plotState.amplitudeDisplayValue)"
        )
    }
}

//import UIKit
//import SwiftUI
//
//// MARK: - SwiftUI plot state
//
//private final class HostedPlotState: ObservableObject {
//    @Published var selectedWave: WaveType = .sine
//    @Published var amplitudeScale: CGFloat = 4.0 / 3.0
//    
//    let minAmplitudeScale: CGFloat = 0.5
//    let maxAmplitudeScale: CGFloat = 3.0
//    let noiseAmplitudeDefaultScale: CGFloat = 10.0
//    
//    var noiseScaleFactor: CGFloat {
//        guard maxAmplitudeScale > 0 else {
//            return noiseAmplitudeDefaultScale
//        }
//        
//        return (amplitudeScale / maxAmplitudeScale)
//        * noiseAmplitudeDefaultScale
//    }
//}
//
//
//// MARK: - Single hosted SwiftUI plot
//
//private struct HostedTherescopePlot: View {
//    @ObservedObject var plotState: HostedPlotState
//    @ObservedObject var waveConductor: WaveConductor
//    @ObservedObject var noiseConductor: NoiseConductor
//    
//    var body: some View {
//        Group {
//            if plotState.selectedWave == .noise {
//                RawOutputView1(
//                    noiseConductor.tappableNodeB,
//                    strokeColor: Color.plotColor,
//                    isNormalized: false,
//                    scaleFactor: plotState.noiseScaleFactor
//                )
//            } else {
//                WavePlot(
//                    waveData: waveConductor.waveData,
//                    amplitudeScale: plotState.amplitudeScale,
//                    widthScale: 0.25,
//                    minAmplitudeThreshold: 0.01,
//                    minAmplitudeScale: 0.1,
//                    minWidthScale: 0.5
//                )
//            }
//        }
//        .background(Color.black)
//        .clipped()
//    }
//}
//
//
//// MARK: - TherescopeController
//
//final class TherescopeController: UIViewController {
//    
//    // MARK: Outlets
//    
//    @IBOutlet private weak var wavePlotContainerView: UIView!
//    
//    @IBOutlet private weak var waveformButtonStack: UIStackView!
//    
//    @IBOutlet private weak var sineButton: UIButton!
//    @IBOutlet private weak var squareButton: UIButton!
//    @IBOutlet private weak var triangleButton: UIButton!
//    @IBOutlet private weak var sawtoothButton: UIButton!
//    @IBOutlet private weak var noiseButton: UIButton!
//    
//    @IBOutlet private weak var amplitudeSlider: UISlider!
//    
//    
//    // MARK: Conductors
//    
//    private let waveConductor = WaveConductor()
//    private let noiseConductor = NoiseConductor()
//    
//    
//    // MARK: Hosted SwiftUI view
//    
//    private let plotState = HostedPlotState()
//    
//    private var plotHostingController:
//    UIHostingController<HostedTherescopePlot>?
//    
//    
//    // MARK: Wave selection
//    
//    private var selectedWave: WaveType = .sine {
//        didSet {
//            guard selectedWave != oldValue else {
//                return
//            }
//            
//            selectedWaveDidChange()
//        }
//    }
//    
//    
//    // MARK: Lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        configureViews()
//        embedPlot()
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        waveConductor.start()
//        noiseConductor.start()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        waveConductor.stop()
//        noiseConductor.stop()
//    }
//    
//    
//    // MARK: View configuration
//    
//    private func configureViews() {
//        wavePlotContainerView.layer.cornerRadius = 40
//        wavePlotContainerView.clipsToBounds = true
//        
//        waveformButtonStack.backgroundColor = .clear
//        
//        for definition in waveButtons {
//            let button = definition.button
//            
//            button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
//            button.layer.cornerRadius = 5
//            button.layer.borderColor = UIColor.black.cgColor
//            button.layer.borderWidth = 1
//            
//            button.setTitle(definition.title, for: .normal)
//        }
//        
//        configureAmplitudeSlider()
//        updateButtons(selectedWave)
//    }
//    
//    private func configureAmplitudeSlider() {
//        amplitudeSlider.minimumValue =
//        Float(plotState.minAmplitudeScale)
//        
//        amplitudeSlider.maximumValue =
//        Float(plotState.maxAmplitudeScale)
//        
//        amplitudeSlider.value =
//        Float(plotState.amplitudeScale)
//    }
//    
//    
//    // MARK: Embed SwiftUI plot
//    
//    private func embedPlot() {
//        let hostedPlot = HostedTherescopePlot(
//            plotState: plotState,
//            waveConductor: waveConductor,
//            noiseConductor: noiseConductor
//        )
//        
//        let hostingController = UIHostingController(
//            rootView: hostedPlot
//        )
//        
//        plotHostingController = hostingController
//        
//        addChild(hostingController)
//        
//        guard let hostedView = hostingController.view else {
//            return
//        }
//        
//        hostedView.translatesAutoresizingMaskIntoConstraints = false
//        hostedView.backgroundColor = .black
//        
//        wavePlotContainerView.addSubview(hostedView)
//        
//        NSLayoutConstraint.activate([
//            hostedView.topAnchor.constraint(
//                equalTo: wavePlotContainerView.topAnchor
//            ),
//            
//            hostedView.bottomAnchor.constraint(
//                equalTo: wavePlotContainerView.bottomAnchor
//            ),
//            
//            hostedView.leadingAnchor.constraint(
//                equalTo: wavePlotContainerView.leadingAnchor
//            ),
//            
//            hostedView.trailingAnchor.constraint(
//                equalTo: wavePlotContainerView.trailingAnchor
//            )
//        ])
//        
//        hostingController.didMove(toParent: self)
//    }
//    
//    
//    // MARK: Button data
//    
//    private struct WaveButtonDefinition {
//        let button: UIButton
//        let waveType: WaveType
//        let title: String
//    }
//    
//    private lazy var waveButtons: [WaveButtonDefinition] = [
//        .init(
//            button: sineButton,
//            waveType: .sine,
//            title: "Sine"
//        ),
//        
//            .init(
//                button: squareButton,
//                waveType: .square,
//                title: "Square"
//            ),
//        
//            .init(
//                button: triangleButton,
//                waveType: .triangle,
//                title: "Triangle"
//            ),
//        
//            .init(
//                button: sawtoothButton,
//                waveType: .sawtooth,
//                title: "Sawtooth"
//            ),
//        
//            .init(
//                button: noiseButton,
//                waveType: .noise,
//                title: "Noise"
//            )
//    ]
//    
//    private func updateButtons(_ selectedWave: WaveType) {
//        for definition in waveButtons {
//            let isSelected =
//            definition.waveType == selectedWave
//            
//            definition.button.setTitleColor(
//                isSelected ? .white : .black,
//                for: .normal
//            )
//            
//            definition.button.backgroundColor =
//            isSelected ? .systemBlue : .white
//        }
//    }
//    
//    
//    // MARK: Wave button actions
//    
//    @IBAction private func onSine() {
//        selectedWave = .sine
//    }
//    
//    @IBAction private func onSquare() {
//        selectedWave = .square
//    }
//    
//    @IBAction private func onTriangle() {
//        selectedWave = .triangle
//    }
//    
//    @IBAction private func onSawtooth() {
//        selectedWave = .sawtooth
//    }
//    
//    @IBAction private func onNoise() {
//        selectedWave = .noise
//    }
//    
//    
//    // MARK: Wave selection change
//    
//    private func selectedWaveDidChange() {
//        updateButtons(selectedWave)
//        
//        // This causes HostedTherescopePlot to switch between
//        // WavePlot and RawOutputView1.
//        plotState.selectedWave = selectedWave
//        
//        switch selectedWave {
//        case .noise:
//            // RawOutputView1 uses noiseConductor.
//            break
//            
//        case .sine, .square, .triangle, .sawtooth:
//            waveConductor.setupOscillator(
//                waveform: selectedWave
//            )
//        }
//    }
//    
//    
//    // MARK: Amplitude slider
//    
//    @IBAction private func amplitudeSliderChanged(
//        _ sender: UISlider
//    ) {
//        plotState.amplitudeScale =
//        CGFloat(sender.value)
//        
//        print(
//            "Amplitude scale = \(plotState.amplitudeScale)"
//        )
//    }
//}
//
