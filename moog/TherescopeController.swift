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
    
    @IBOutlet private weak var topContainerView: UIView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var settingsButton: UIButton!
    
    @IBOutlet private weak var amplitudeSlider: UISlider!

    @IBOutlet private weak var containerButtonStackView1: UIStackView!
    @IBOutlet private weak var innerButtonStackView1: UIStackView!
    @IBOutlet private weak var sineButton1: IconTitleButton!
    @IBOutlet private weak var squareButton1: IconTitleButton!
    @IBOutlet private weak var triangleButton1: IconTitleButton!
    @IBOutlet private weak var sawtoothButton1: IconTitleButton!
    @IBOutlet private weak var noiseButton1: IconTitleButton!


    var currSineOnly: Bool = false
    var currDisplayData: Bool = false

    
    // MARK: Conductors
    private let waveConductor = WaveConductor()
    private let noiseConductor = NoiseConductor()
    
    
    // MARK: Hosted plot
    private let plotState = HostedPlotState()
    private var plotHostingController: UIHostingController<HostedTherescopePlot>?
    
    
    // MARK: Selected wave
    private var selectedWave: WaveType = .sine {
        didSet {
            guard selectedWave != oldValue else {
                return
            }
            
            selectedWaveDidChange()
        }
    }
    
    let popup = SettingsPopupView()
    private var settingsPopupView: SettingsPopupView?
    private var popupDismissView: UIView?
    
    private var popupTimer: Timer?

    let dataPopup = DataPopupView()
    private var dataPopupView: DataPopupView?
    private var dataPopupDismissView: UIView?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        currSineOnly = SettingsDefaults.setting(for: .sineOnly)
        currDisplayData = SettingsDefaults.setting(for: .displayData)

        configureViews()
        embedPlot()
    }
    
    override var prefersStatusBarHidden: Bool {
        true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currSineOnly = SettingsDefaults.setting(for: .sineOnly)
        currDisplayData = SettingsDefaults.setting(for: .displayData)
        self.handleWaveformChange(waveType: self.selectedWave)
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        waveConductor.start()
        noiseConductor.start()
        
        popupTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.dataPopup.updateDataPopup(dataStr: self.dataPopupString)
        }
        
        if currDisplayData {
            self.showDataPopup()
        }else{
            self.hideDataPopup()
        }

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        waveConductor.stop()
        noiseConductor.stop()
        popupTimer?.invalidate()
    }
    
    private var dataPopupString: String {
    """
    Waveform: \(waveConductor.waveformName)
    Frequency: \(String(format: "%.1f", waveConductor.pitch)) Hz
    Period: \(String(format: "%.2f", waveConductor.periodMilliseconds)) ms
    Note: \(waveConductor.detectedNoteName)
    Amplitude: \(String(format: "%.3f", waveConductor.amplitude))
    Wavelength: \(String(format: "%.2f", waveConductor.wavelengthMeters)) m
    Samples/Cycle: \(String(format: "%.1f", waveConductor.samplesPerCycle))
    """
    }
    
    
    // MARK: -- View configuration

    
    private func configureViews() {
        
        topContainerView.backgroundColor = .systemBlue
        
        wavePlotContainerView.layer.cornerRadius = 40
        wavePlotContainerView.clipsToBounds = true
        
        containerButtonStackView1.backgroundColor = .white
        innerButtonStackView1.backgroundColor = .clear

        sineButton1.waveType = .sine
        squareButton1.waveType = .square
        triangleButton1.waveType = .triangle
        sawtoothButton1.waveType = .sawtooth
        noiseButton1.waveType = .noise
        
        configureAmplitudeSlider()
        
        if currSineOnly {
            self.triangleButton1.isHidden = true
            self.squareButton1.isHidden = true
            self.sawtoothButton1.isHidden = true
        }else{
            self.triangleButton1.isHidden = false
            self.squareButton1.isHidden = false
            self.sawtoothButton1.isHidden = false
        }
        
    }
    
    // MARK: - slider
    
    private func configureAmplitudeSlider() {
        amplitudeSlider.minimumValue =
        Float(plotState.minAmplitudeScale)
        
        amplitudeSlider.maximumValue =
        Float(plotState.maxAmplitudeScale)
        
        amplitudeSlider.value =
        Float(plotState.amplitudeScale)
        
        amplitudeSlider.isContinuous = true
    }
    
    
    // MARK: -- Embed SwiftUI plot
    
    private func embedPlot() {
        let hostedPlot = HostedTherescopePlot(
            plotState: plotState,
            waveConductor: waveConductor,
            noiseConductor: noiseConductor
        )
        
        let hostingController = UIHostingController(rootView: hostedPlot)
        
        plotHostingController = hostingController
        
        addChild(hostingController)
        
        guard let hostedView =
                hostingController.view else {
            return
        }
        
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
    
    
    // MARK: Wave button actions
    
    @IBAction func onBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSettings(){
        self.settingsButtonPressed()
    }

    func handleWaveformChange(waveType:WaveType?){
        guard let waveType = waveType else { return }
        let buttons = [sineButton1,squareButton1,triangleButton1,sawtoothButton1,noiseButton1]
        for button in buttons {
            button?.setSelected(isSelected: (button?.waveType == waveType))
        }
    }
    
    @IBAction func onSine1(_ sender: IconTitleButton) {
        selectedWave = .sine
        self.handleWaveformChange(waveType: .sine)
    }
    
    @IBAction func onSquare1(_ sender: IconTitleButton) {
        selectedWave = .square
        self.handleWaveformChange(waveType: .square)
    }
    
    @IBAction func onTriangle1(_ sender: IconTitleButton) {
        selectedWave = .triangle
        self.handleWaveformChange(waveType: .triangle)
    }
    
    @IBAction func onSawtooth1(_ sender: IconTitleButton) {
        selectedWave = .sawtooth
        self.handleWaveformChange(waveType: .sawtooth)
    }
    
    @IBAction func onNoise1(_ sender: IconTitleButton) {
        selectedWave = .noise
        self.handleWaveformChange(waveType: .noise)
    }

    
    // MARK: Wave selection
    
    private func selectedWaveDidChange() {
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
    
    
    // MARK: - data popup
    
    private func showDataPopup() {
        guard dataPopupView == nil else {
            return
        }
        
        dataPopup.onClose = { [weak self] in
            self?.hideDataPopup()
        }
        
        // for now, it is on the plot - make items clear:
        dataPopup.configureWithClear(textColor: .white)
        
        let width: CGFloat = 240
        let f = self.wavePlotContainerView.frame
        let x: CGFloat = f.minX // 20
        let y: CGFloat = f.minY // 140
        
        dataPopup.transform = .identity
        dataPopup.alpha = 1
        dataPopup.translatesAutoresizingMaskIntoConstraints = true
        
        // Update the label before calculating the required height.
        dataPopup.updateDataPopup(dataStr: dataPopupString)
        
        /*
         Give the popup its real width before layout. Otherwise its multiline
         label may calculate its intrinsic height using an old or undefined width.
         */
        dataPopup.frame = CGRect(
            x: x,
            y: y,
            width: width,
            height: 1
        )
        
        view.addSubview(dataPopup)
        
        dataPopup.setNeedsLayout()
        dataPopup.layoutIfNeeded()
        
        let fittingSize = dataPopup.systemLayoutSizeFitting(
            CGSize(
                width: width,
                height: UIView.layoutFittingCompressedSize.height
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        dataPopup.frame = CGRect(
            x: x,
            y: y,
            width: width,
            height: fittingSize.height
        )
        
        dataPopup.layoutIfNeeded()
        
        dataPopup.alpha = 0
        dataPopup.transform = CGAffineTransform(
            translationX: 40,
            y: -20
        ).scaledBy(
            x: 0.75,
            y: 0.75
        )
        
        dataPopupView = dataPopup
        
        UIView.animate(
            withDuration: 0.22,
            delay: 0,
            options: [
                .curveEaseOut,
                .beginFromCurrentState
            ]
        ) {
            self.dataPopup.alpha = 1
            self.dataPopup.transform = .identity
        }
    }
    
    private func hideDataPopup() {
        guard let popup = dataPopupView else {
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
            self?.dataPopupDismissView?.removeFromSuperview()
            
            // Restore the reusable view to its normal state.
            popup.transform = .identity
            popup.alpha = 1
            
            self?.dataPopupView = nil
            self?.dataPopupDismissView = nil
        }
    }
    @objc private func dataDismissViewTapped() {
        hideDataPopup()
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
        
        popup.onClose = { [weak self] in
            print("StageViewController.onClose")
            self?.hideSettingsPopup()
        }
        
        popup.onDisplayData = { [weak self] newValue in
            guard let newValue = newValue else { return }
            print("StageViewController.onDisplayData:\(newValue)")

            self?.currDisplayData = newValue
            if newValue == true {
                self?.showDataPopup()
            }else{
                self?.hideDataPopup()
            }
        }
        
        popup.onSineOnly = { [weak self] newValue in
            guard let newValue = newValue else { return }
            print("StageViewController.onSineOnly:\(newValue)")

            self?.currSineOnly = newValue
            self?.configureViews()

            if newValue == true {
                if self?.selectedWave != .sine || self?.selectedWave != .noise {
                    if let sineButton1 = self?.sineButton1 {
                        self?.onSine1(sineButton1)
                    }
                }
            }else{
                self?.handleWaveformChange(waveType: self?.selectedWave)
            }
            
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
                equalTo: settingsButton.bottomAnchor,
                constant: 0
            ),
            popup.trailingAnchor.constraint(
                equalTo: settingsButton.leadingAnchor,
                constant: 0
            ),
            popup.widthAnchor.constraint(
                equalToConstant: 200
            ),
        ])
        
        /*
         Resolve Auto Layout before applying the animation so the
         transform works from the popup's final location.
         */
        view.layoutIfNeeded()
        
        popup.alpha = 0
        popup.prepareForDisplay()
        
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

